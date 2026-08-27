# TheTrades

A SwiftUI app for browsing movies, TV shows, and the people who make them, built on [TMDB](https://www.themoviedb.org). Universal for iPhone and iPad.

[![CI](https://github.com/jeffmueller/TheTrades/actions/workflows/ci.yml/badge.svg)](https://github.com/jeffmueller/TheTrades/actions/workflows/ci.yml)

## Features

- **Discover** — Trending This Week, Popular Movies, and Popular TV carousels, fetched concurrently, plus your recently viewed titles and recent searches.
- **Search** — debounced multi-search across movies, TV, and people, with scope filtering and infinite scroll.
- **Detail views** — movies, TV shows, seasons, episodes, and people, with backdrops, genres, cast, and trailers.
- **Age at release** — every cast member's age when the title came out, shown inline on the cast row. This is the feature the app exists for.
- **Spoiler mode** — blurs episode titles, stills, and overviews until you tap. On by default.
- **Watchlist** — save anything, browse it as a list or a poster grid.
- **Adaptive layout** — a tab bar in compact width, a sidebar split view in regular, with per-tab navigation history preserved across the switch.

No account, no tracking, no analytics. Saved data lives in `UserDefaults` on device; the bundled [privacy manifest](TheTrades/PrivacyInfo.xcprivacy) declares no data collection.

## Requirements

- Xcode 16 or later (Swift 6)
- iOS 17.0+
- [XcodeGen](https://github.com/yonaskolb/XcodeGen)

## Getting started

`TheTrades.xcodeproj` is generated from [`project.yml`](project.yml) and is not checked in, so generate it after cloning:

```bash
brew install xcodegen
git clone https://github.com/jeffmueller/TheTrades.git
cd TheTrades
xcodegen generate
open TheTrades.xcodeproj
```

That's the whole setup. The app builds and runs in the simulator, and the test suite passes, with no TMDB token and no Apple Developer account.

### Adding a TMDB token

Without a token the app builds and launches but shows an error card instead of data. To see real content:

1. Create a free account at [themoviedb.org](https://www.themoviedb.org/signup) and open [Settings → API](https://www.themoviedb.org/settings/api).
2. Copy the **API Read Access Token** — the long v4 token, not the short v3 API key.
3. Create your local config and paste it in:

   ```bash
   cp Config/Local.example.xcconfig Config/Local.xcconfig
   ```

   ```
   TMDB_BEARER_TOKEN = eyJhbGciOi...
   ```

`Config/Local.xcconfig` is gitignored. The token is copied into the app's `Info.plist` at build time and read back by [`TMDBConfiguration`](TheTrades/App/TMDBConfiguration.swift), which also honours a `TMDB_BEARER_TOKEN` environment variable if you'd rather set one on the scheme.

### Building for a device

Simulator builds need no signing. For a device, add your own values to `Config/Local.xcconfig`:

```
TT_BUNDLE_ID_PREFIX = com.yourdomain
DEVELOPMENT_TEAM = ABCDE12345
```

## Testing

```bash
xcodebuild -project TheTrades.xcodeproj -scheme TheTrades \
  -destination 'platform=iOS Simulator,name=iPhone 16' test
```

29 tests in 5 suites, written with [Swift Testing](https://developer.apple.com/documentation/testing). They never touch the network: [`MediaFetching`](TheTrades/Services/MediaFetching.swift) is the seam, and [`TestSupport`](TheTradesTests/TestSupport.swift) injects a stub client and an isolated `UserDefaults` suite.

## Architecture

| | |
|---|---|
| **UI** | SwiftUI, `@Observable` state, `NavigationStack` with typed destinations |
| **Concurrency** | Swift 6 with `SWIFT_STRICT_CONCURRENCY: complete`; `TMDBClient` is an `actor` |
| **Networking** | `URLSession` + `Codable`, no networking dependency |
| **Images** | [Nuke](https://github.com/kean/Nuke) / NukeUI |
| **Persistence** | `UserDefaults` |
| **Project** | XcodeGen; `project.yml` is the source of truth |

Roughly 3,100 lines of app code across Views, Models, Services, and Navigation.

```
TheTrades/
├── App/            Entry point, AppState, TMDB configuration
├── Models/         Codable types for movies, shows, people, library items
├── Navigation/     Typed destinations and per-tab navigation stacks
├── Services/       TMDBClient, URL builders, persistence, age calculation
└── Views/          Discover, Search, detail screens, Watchlist, Settings
```

Dependency versions are pinned in [`Package.resolved`](Package.resolved) at the repo root — an unusual location, but its normal home is inside the generated `.xcodeproj`, which isn't tracked. `xcodegen generate` is followed by a copy into place in CI and in the release script.

## Releasing

[`scripts/testflight.sh`](scripts/testflight.sh) archives and uploads to TestFlight in one command, defaulting the build number to the commit count. It reads App Store Connect API credentials from a gitignored `scripts/release.env`; see [`release.env.example`](scripts/release.env.example).

## License

[MIT](LICENSE).

This product uses the TMDB API but is not endorsed or certified by TMDB.
