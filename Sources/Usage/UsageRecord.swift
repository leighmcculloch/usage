import Foundation

struct UsageRecord {
    var begin: Date
    var end: Date
    var suburb: String
    var state: String
    var country: String

    static let csvHeader = "begin,end,suburb,state,country"

    private static let formatter: ISO8601DateFormatter = {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime]
        return f
    }()

    func toCSVLine() -> String {
        let b = UsageRecord.formatter.string(from: begin)
        let e = UsageRecord.formatter.string(from: end)
        return "\(b),\(e),\(csvEscape(suburb)),\(csvEscape(state)),\(csvEscape(country))"
    }

    static func fromCSVLine(_ line: String) -> UsageRecord? {
        let fields = parseCSVLine(line)
        guard fields.count >= 5 else { return nil }
        guard let b = formatter.date(from: fields[0]),
              let e = formatter.date(from: fields[1]) else { return nil }
        return UsageRecord(
            begin: b, end: e,
            suburb: fields[2], state: fields[3],
            country: fields[4]
        )
    }

    private func csvEscape(_ value: String) -> String {
        if value.contains(",") || value.contains("\"") || value.contains("\n") {
            return "\"\(value.replacingOccurrences(of: "\"", with: "\"\""))\""
        }
        return value
    }

    private static func parseCSVLine(_ line: String) -> [String] {
        var fields: [String] = []
        var current = ""
        var inQuotes = false
        var chars = line.makeIterator()
        while let c = chars.next() {
            if inQuotes {
                if c == "\"" {
                    if let next = chars.next() {
                        if next == "\"" {
                            current.append("\"")
                        } else {
                            inQuotes = false
                            if next == "," {
                                fields.append(current)
                                current = ""
                            } else {
                                current.append(next)
                            }
                        }
                    } else {
                        inQuotes = false
                    }
                } else {
                    current.append(c)
                }
            } else {
                if c == "\"" {
                    inQuotes = true
                } else if c == "," {
                    fields.append(current)
                    current = ""
                } else {
                    current.append(c)
                }
            }
        }
        fields.append(current)
        return fields
    }
}

extension UsageRecord {
    static func floorToHour(_ date: Date) -> Date {
        let cal = Calendar(identifier: .gregorian)
        var components = cal.dateComponents(in: TimeZone(identifier: "UTC")!, from: date)
        components.minute = 0
        components.second = 0
        components.nanosecond = 0
        return cal.date(from: components)!
    }

    static func ceilToHour(_ date: Date) -> Date {
        let floored = floorToHour(date)
        if floored == date {
            return date
        }
        return floored.addingTimeInterval(3600)
    }
}
