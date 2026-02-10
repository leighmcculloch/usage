import Foundation

final class CSVStore {
    let directory: URL

    private static let fileFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "yyyy-MM"
        f.timeZone = TimeZone(identifier: "UTC")
        return f
    }()

    init() {
        let appSupport = FileManager.default.homeDirectoryForCurrentUser
            .appendingPathComponent("Library/Application Support/Usage")
        self.directory = appSupport
        try? FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)
    }

    func fileName(for date: Date) -> String {
        return "usage-\(CSVStore.fileFormatter.string(from: date)).csv"
    }

    func filePath(for date: Date) -> URL {
        return directory.appendingPathComponent(fileName(for: date))
    }

    func readRecords(for date: Date) -> [UsageRecord] {
        return readRecords(from: filePath(for: date))
    }

    func readRecords(from url: URL) -> [UsageRecord] {
        guard let content = try? String(contentsOf: url, encoding: .utf8) else { return [] }
        let lines = content.components(separatedBy: "\n")
        var records: [UsageRecord] = []
        for line in lines.dropFirst() { // skip header
            let trimmed = line.trimmingCharacters(in: .whitespacesAndNewlines)
            if trimmed.isEmpty { continue }
            if let record = UsageRecord.fromCSVLine(trimmed) {
                records.append(record)
            }
        }
        return records
    }

    func writeRecords(_ records: [UsageRecord], for date: Date) {
        writeRecords(records, to: filePath(for: date))
    }

    func writeRecords(_ records: [UsageRecord], to url: URL) {
        let sorted = records.sorted { $0.begin < $1.begin }
        var content = UsageRecord.csvHeader + "\n"
        for record in sorted {
            content += record.toCSVLine() + "\n"
        }
        try? content.write(to: url, atomically: true, encoding: .utf8)
    }

    /// Record a used hour. If the hour is already covered by an existing record,
    /// do nothing. If the last record can be extended (same location, end touches
    /// this hour), extend it. Otherwise append.
    func recordHour(hour: Date, suburb: String, state: String, country: String) {
        let url = filePath(for: hour)
        var records = readRecords(from: url)
        let hourEnd = hour.addingTimeInterval(3600)

        // Check if this hour is already covered by any existing record
        for record in records {
            if record.begin <= hour && record.end >= hourEnd {
                return
            }
        }

        // Try to extend the last record if it's contiguous with same location
        if let lastIdx = records.indices.last {
            let last = records[lastIdx]
            if last.suburb == suburb &&
               last.state == state &&
               last.country == country &&
               last.end == hour {
                records[lastIdx].end = hourEnd
                writeRecords(records, to: url)
                return
            }
        }

        let record = UsageRecord(
            begin: hour, end: hourEnd,
            suburb: suburb, state: state, country: country
        )
        records.append(record)
        writeRecords(records, to: url)
    }

    /// Update the location on all records in the current session that have blank
    /// location. A "session" is the contiguous tail of records ending at or after `since`.
    func updateLocationForCurrentSession(suburb: String, state: String, country: String, since: Date) {
        let url = filePath(for: since)
        var records = readRecords(from: url)
        guard !records.isEmpty else { return }

        var changed = false
        var i = records.count - 1
        while i >= 0 {
            let r = records[i]
            guard r.end >= since else { break }
            if r.suburb.isEmpty && r.state.isEmpty && r.country.isEmpty {
                records[i].suburb = suburb
                records[i].state = state
                records[i].country = country
                changed = true
            }
            if i > 0 && records[i - 1].end < r.begin {
                break
            }
            i -= 1
        }

        if changed {
            writeRecords(records, to: url)
        }
    }
}
