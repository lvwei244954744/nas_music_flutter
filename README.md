# NasMusic

A multi-platform music player for [Navidrome](https://www.navidrome.org/) (Subsonic API).

## Features

- **Browse** — newest albums, random picks, recent plays
- **Library** — artists, albums, songs, playlists with tab navigation
- **Search** — search across artists, albums, and songs
- **Playback** — streaming audio with play/pause, seek, next/previous, shuffle/repeat
- **Player** — mini player bar + full-screen now playing view
- **Playlist management** — create, edit, delete playlists
- **Dark / Light theme** — warm gold accent on deep charcoal (minimal premium design)
- **Cross-platform** — Android, iOS, Windows, macOS, Linux, Web

## Screenshots

<!-- TODO: Add screenshots -->

## Tech Stack

| Component | Tech |
|-----------|------|
| Framework | [Flutter](https://flutter.dev) 3.44+ (Dart 3.12) |
| State Management | [Provider](https://pub.dev/packages/provider) |
| Audio Playback | [audioplayers](https://pub.dev/packages/audioplayers) |
| HTTP Client | [http](https://pub.dev/packages/http) |
| XML Parsing | [xml](https://pub.dev/packages/xml) |
| Fonts | [Google Fonts](https://pub.dev/packages/google_fonts) (Outfit + Inter) |
| Storage | [path_provider](https://pub.dev/packages/path_provider) |

## Getting Started

### Prerequisites

- [Flutter SDK](https://docs.flutter.dev/get-started/install) 3.44+
- Platform-specific toolchains (see build table)

### Install

```bash
git clone https://github.com/lvwei244954744/nas_music_flutter.git
cd loml_nas_music
flutter pub get
```

### Build

| Platform | Command | Required Environment |
|----------|---------|---------------------|
| Android | `flutter build apk --debug` | Android SDK + JDK (bundled with Android Studio) |
| iOS | `flutter build ios --debug` | macOS + Xcode |
| Windows | `flutter build windows --debug` | Visual Studio with Windows SDK |
| macOS | `flutter build macos --debug` | macOS + Xcode |
| Linux | `flutter build linux --debug` | Linux + GTK3 dev libraries |
| Web | `flutter build web` | Any platform + Chrome |

## Configuration

### Network

The app connects to a Navidrome server via the [Subsonic API](http://www.subsonic.org/pages/api.jsp). You will need:

- Server URL (e.g. `https://music.example.com`)
- Username and password

> **Note:** If your Navidrome server uses HTTP (not HTTPS), you may need to configure platform-specific network security:
> - **Android:** `android:usesCleartextTraffic="true"` is already set in `AndroidManifest.xml`
> - **iOS/macOS:** `NSAllowsArbitraryLoads` is already enabled in `Info.plist`
> - **Windows/Linux:** Desktop apps have unrestricted network access by default

### Dark Mode

Dark mode is enabled by default. Toggle between dark/light themes in Settings.

## Architecture

```
lib/
├── core/
│   ├── api/          # Subsonic API client
│   ├── router/       # Named route generator
│   ├── theme/        # Colors and theme config
│   └── utils/        # Formatting utilities
├── data/
│   ├── models/       # Song, Album, Artist, Playlist
│   └── repositories/ # Data access layer
├── features/
│   ├── album/        # Album detail screen
│   ├── artist/       # Artist detail screen
│   ├── auth/         # Login + session management
│   ├── home/         # Home feed (newest/random/recent)
│   ├── library/      # Artist/Album/Song/Playlist tabs
│   ├── player/       # Audio player + mini/now-playing UI
│   ├── playlist/     # Playlist detail + edit screens
│   ├── search/       # Global search
│   └── settings/     # App settings
├── app.dart          # Root widget + navigation shell
└── main.dart         # Entry point + DI setup
```

## Project Info

- **Name:** NasMusic (`loml_nas_music`)
- **Version:** 1.0.0+1
- **Bundle IDs:** `com.loml.loml_nas_music` (Android/Linux), `com.loml.lomlNasMusic` (iOS/macOS)
- **Design System:** [design-system/loml.nas.music/](design-system/loml.nas.music/)
