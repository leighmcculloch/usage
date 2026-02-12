# Usage

A macOS menu bar app that tracks time spent on the computer along with location. It detects active/inactive state via screen wake/sleep, lock/unlock, and session changes, and records hourly usage with your physical location to simple monthly CSV files.

## Install

### Homebrew

```
brew tap leighmcculloch/usage
brew install --HEAD leighmcculloch/usage/usage
```

To upgrade:

```
brew upgrade --fetch-head leighmcculloch/usage/usage
```

## Use

Usage runs as a menu bar-only app (no Dock icon). It automatically tracks when the computer is active and records the current location via reverse geocoding.

Data is stored as monthly CSV files in `~/Library/Application Support/Usage/`:

```
begin,end,suburb,state,country
2026-02-10T08:00:00Z,2026-02-10T12:00:00Z,Sydney,New South Wales,Australia
```

Times are in UTC and aligned to hour boundaries. Consecutive hours at the same location are merged into single records.

## Options

- **Launch at Login** — available in the menu bar dropdown.
- **Open Data Folder** — opens the CSV data directory in Finder.
