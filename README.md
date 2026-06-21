# Anichin iOS - Donghua Streaming App

[![Build iOS App](https://github.com/yourusername/anichin-ios/actions/workflows/build-ios.yml/badge.svg)](https://github.com/yourusername/anichin-ios/actions/workflows/build-ios.yml)
[![Release](https://img.shields.io/github/v/release/yourusername/anichin-ios)](https://github.com/yourusername/anichin-ios/releases)
[![Platform](https://img.shields.io/badge/platform-iOS%2017%2B-blue)](https://developer.apple.com/ios/)
[![Swift](https://img.shields.io/badge/swift-5.9-orange)](https://swift.org)
[![License](https://img.shields.io/badge/license-Personal%20Use-green)](LICENSE)

Aplikasi streaming donghua iOS native dengan SwiftUI yang mengambil konten dari Anichin.moe. Dirancang dengan Netflix-style UI dan liquid glass effect untuk pengalaman menonton yang premium.

> **🚀 Tanpa Mac?** Build via GitHub Actions! → [Quick Start Guide](QUICKSTART.md)

## ✨ Features

### 🎬 Core Features
- **Browse** - Jelajahi donghua by genre, status, popularity
- **Search** - Cari donghua favorit dengan filter advanced
- **Daily Schedule** - Jadwal rilis per hari (Senin-Minggu)
- **Streaming** - Multiple server support dengan auto quality
- **Download** - Simpan episode untuk offline viewing
- **Bookmark** - Tandai donghua favorit
- **History** - Track semua yang pernah ditonton
- **Continue Watching** - Lanjut dari terakhir berhenti
- **Notifications** - Alert episode baru otomatis

### 🎨 UI/UX
- Netflix-style interface dengan smooth transitions
- Liquid glass/glassmorphism effects (iOS 17+)
- Dark mode optimized untuk mata
- Native iOS gestures & animations
- Responsive layout (iPhone & iPad)
- Landscape video player support

### 🎥 Video Player
- Multiple streaming sources
- Auto-play next episode
- Resume from last position
- Picture-in-Picture support
- Gesture controls (swipe, pinch)
- Custom controls dengan glassmorphism

## 🛠 Tech Stack

- **SwiftUI** - Modern declarative UI framework
- **SwiftData** - Persistent storage (iOS 17+)
- **AVKit/AVPlayer** - Native video playback
- **SwiftSoup** - HTML parsing untuk scraping
- **URLSession** - Network dengan caching
- **BackgroundTasks** - Background refresh
- **UserNotifications** - Push notifications

## 📁 Project Structure

```
AnichinApp/
├── AnichinApp.swift          # App entry point
├── ContentView.swift          # Main tab view
├── Models/                    # Data models
│   ├── Donghua.swift
│   ├── Episode.swift
│   ├── Bookmark.swift
│   └── WatchHistory.swift
├── Services/                  # Business logic
│   ├── NetworkService.swift
│   ├── ScraperService.swift
│   ├── DownloadService.swift
│   └── NotificationService.swift
├── ViewModels/               # MVVM ViewModels
│   ├── HomeViewModel.swift
│   ├── DetailViewModel.swift
│   ├── PlayerViewModel.swift
│   └── SearchViewModel.swift
├── Views/                    # SwiftUI Views
│   ├── Home/
│   ├── Detail/
│   ├── Player/
│   ├── Search/
│   ├── Favorites/
│   ├── History/
│   ├── Downloads/
│   ├── Settings/
│   └── Components/
└── Utils/                    # Helpers & Extensions
    ├── Constants.swift
    ├── CacheManager.swift
    ├── BackgroundTaskManager.swift
    └── Extensions/
```

## 🚀 Quick Start

### Requirements
- macOS dengan Xcode 15.0+ (untuk local build)
- iOS 17.0+ device/simulator
- Swift 5.9+
- Apple Developer Account (free/paid) - optional untuk local

### Option 1: GitHub Actions (Recommended - No Mac Required!)

**Automatic Build via GitHub Actions:**

1. **Fork/Clone Repository**
   ```bash
   git clone https://github.com/yourusername/anichin-ios.git
   cd anichin-ios
   ```

2. **Push to GitHub**
   ```bash
   git add .
   git commit -m "Initial commit"
   git push origin main
   ```

3. **Download IPA**
   - Go to Actions tab di GitHub
   - Pilih workflow "Build iOS App"
   - Download artifact "AnichinApp-IPA"
   - Extract dan dapat IPA file

**Auto Release (dengan versioning):**
```bash
# Create & push tag untuk auto release
git tag v1.0.0
git push origin v1.0.0

# IPA akan otomatis di-release di GitHub Releases
```

### Option 2: Local Build (Requires Mac)

1. **Clone & Open**
   ```bash
   cd AnichinApp
   open AnichinApp.xcodeproj
   ```

2. **Configure Signing** (Optional untuk unsigned IPA)
   - Select AnichinApp target
   - Signing & Capabilities tab
   - Change Bundle ID: `com.yourname.anichin`
   - Select your Team

3. **Build untuk Device**
   ```bash
   # Make build script executable
   chmod +x build_ipa.sh
   
   # Run build script
   ./build_ipa.sh
   ```

4. **Install via Scarlet**
   - Transfer IPA ke iPhone
   - Open Scarlet app
   - Import & install IPA
   - Trust certificate di Settings

## 📱 Installation

### Via Xcode (Development)
1. Connect iPhone via USB
2. Select your device di Xcode
3. Click Run (⌘R)
4. App installed & launched

### Via Scarlet (Sideloading)
1. Build IPA dengan script atau Xcode archive
2. Transfer IPA file ke iPhone
3. Open Scarlet → Library → Import IPA
4. Install → Trust certificate
5. Launch Anichin!

## ⚙️ Configuration

### App Settings
- Video quality (Auto/1080p/720p/480p/360p)
- Download quality preferences
- Auto-play next episode
- Notification schedules
- Cache management

### Permissions Required
- **Network** - Untuk streaming & fetching data
- **Storage** - Untuk download episodes
- **Notifications** - Episode baru alerts

## 🎯 Features Detail

### Home Screen
- Hero banner dengan featured donghua
- Continue watching carousel
- Today's schedule
- Latest episodes list
- Popular donghua grid
- Recommendations

### Detail Screen
- Full synopsis & info
- Episode list dengan progress
- One-tap play/continue
- Bookmark toggle
- Share & more options

### Video Player
- Full screen controls
- Quality selection
- Server switching
- Previous/Next episode
- Progress tracking
- Auto-save position

### Search & Browse
- Real-time search
- Filter by genre/status/type
- Sort options
- Grid view results

### Downloads
- Queue management
- Storage usage info
- Quality selection
- Batch delete
- Offline playback

### History & Favorites
- Watch progress tracking
- Quick resume
- Swipe to delete
- Sort by date
- Filter completed

## 🔧 Development

### GitHub Actions CI/CD

Project ini menggunakan GitHub Actions untuk automated builds:

**Workflows:**
1. **build-ios.yml** - Auto build pada push/PR
   - Runs on: Push to main/develop, PR ke main
   - Output: IPA artifact (30 days retention)
   - Auto release untuk main branch push

2. **release.yml** - Release build dengan versioning
   - Runs on: Git tag push (v*.*.*)
   - Output: GitHub Release dengan IPA
   - Include checksums untuk verification

**Trigger Build:**
```bash
# Auto build (push to main)
git push origin main

# Create release
git tag v1.0.1
git push origin v1.0.1
```

**Download Build Artifacts:**
- Go to Actions tab
- Select workflow run
- Download "AnichinApp-IPA" artifact
- Or download from Releases page (for tagged builds)

### Local Development

### Run Tests
```bash
xcodebuild test -project AnichinApp.xcodeproj -scheme AnichinApp
```

### Clean Build
```bash
xcodebuild clean -project AnichinApp.xcodeproj
```

### Debug Logging
Check Console.app untuk app logs saat development.

## 📝 Notes

- **Konten**: Semua konten dari Anichin.moe (unofficial)
- **Legal**: Personal use only
- **Updates**: Scraper mungkin perlu update jika struktur HTML berubah
- **Storage**: Downloads memakan storage, manage via settings

## 🐛 Troubleshooting

**App tidak bisa build?**
- Reset SPM: `rm -rf ~/Library/Developer/Xcode/DerivedData`
- Clean build folder

**Video tidak play?**
- Check internet connection
- Try different server
- Check URL masih valid

**Download gagal?**
- Check storage space
- Verify network stable
- Check permissions

## 📄 License

Personal use only. Konten © Anichin.moe

## 🙏 Credits

- Konten: Anichin.moe
- Framework: Apple SwiftUI
- HTML Parser: SwiftSoup
