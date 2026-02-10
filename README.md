# Usage

A macOS menu bar app that tracks time spent on the computer along with location.

Data is stored in simple monthly CSV files.

## Features

- Menu bar icon with current tracking status (suburb and state)
- Automatic location detection via reverse geocoding
- Tracks active/inactive state via screen wake/sleep, lock/unlock, and session changes
- Merges consecutive hours at the same location into single records
- Monthly CSV files stored in `~/Library/Application Support/Usage/`
- Launch at login support
- No Dock icon — runs as a menu bar-only app
- Zero third-party dependencies

## Requirements

- macOS 13 (Ventura) or later
- Swift 5.9+
- Location permission

## Install

```
make install
```

This builds the app, copies it to `~/Applications/Usage.app`, and opens it.

## Uninstall

```
make uninstall
```

## Build

```
make build
```

Build the `.app` bundle without installing:

```
make app
```

The bundle is placed at `build/Usage.app`.

## Data Format

CSV files are stored at `~/Library/Application Support/Usage/usage-YYYY-MM.csv`
with the following columns:

```
begin,end,suburb,state,country
2026-02-10T08:00:00Z,2026-02-10T12:00:00Z,Sydney,New South Wales,Australia
```

Times are in UTC and aligned to hour boundaries.
