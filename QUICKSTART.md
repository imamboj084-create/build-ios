# 🚀 Quick Start Guide - Build Anichin iOS via GitHub Actions

## Tanpa Mac? No Problem! 

GitHub Actions akan build IPA secara otomatis menggunakan macOS runner cloud.

---

## Step 1️⃣: Setup GitHub Repository

### A. Create New Repository di GitHub

1. Go to https://github.com/new
2. Repository name: `anichin-ios` (atau nama lain)
3. Privacy: Public atau Private (terserah)
4. **JANGAN** initialize with README
5. Click "Create repository"

### B. Upload Code ke GitHub

**Option 1: Using setup script (Recommended)**
```bash
# Make script executable
chmod +x setup-git.sh

# Run setup script dengan GitHub repo URL
./setup-git.sh https://github.com/YOUR-USERNAME/anichin-ios.git
```

**Option 2: Manual commands**
```bash
# Init git
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: Anichin iOS with GitHub Actions"

# Set main branch
git branch -M main

# Add remote (ganti dengan URL repo Anda)
git remote add origin https://github.com/YOUR-USERNAME/anichin-ios.git

# Push
git push -u origin main
```

---

## Step 2️⃣: Wait for Build

1. **Go to Actions tab** di GitHub repo Anda
2. Click workflow "Build iOS App"
3. Wait ~10-15 minutes (GitHub runner akan download Xcode, dependencies, lalu build)
4. Status akan jadi ✅ green checkmark jika berhasil

---

## Step 3️⃣: Download IPA

### Option A: From Actions Artifacts

1. Click on completed workflow run
2. Scroll down ke "Artifacts" section
3. Download "AnichinApp-IPA.zip"
4. Extract → dapat file `AnichinApp.ipa`

### Option B: From Releases (jika push ke main)

1. Go to "Releases" di sidebar kanan
2. Click latest release
3. Download `AnichinApp.ipa` dari Assets

---

## Step 4️⃣: Install ke iPhone

### Method 1: Scarlet (Paling Mudah)

1. **Transfer IPA ke iPhone**
   - AirDrop
   - iCloud Drive
   - Google Drive / Dropbox
   - Email attachment

2. **Install via Scarlet**
   ```
   Open Files → Locate IPA
   → Share → Scarlet
   → Install
   ```

3. **Trust Certificate**
   ```
   Settings → General
   → VPN & Device Management
   → Trust certificate
   ```

4. **Launch App** 🎉

### Method 2: AltStore

1. Install AltStore di Mac/PC
2. Connect iPhone
3. Drag & drop IPA ke AltStore
4. Install to device

### Method 3: Sideloadly

1. Download Sideloadly (Mac/PC/Linux)
2. Connect iPhone via USB
3. Load IPA file
4. Sign with Apple ID
5. Install

---

## 🏷️ Create Versioned Release

Untuk create release dengan version number:

```bash
# Tag version
git tag v1.0.0

# Push tag
git push origin v1.0.0
```

GitHub Actions akan:
- Auto build IPA
- Create GitHub Release
- Upload IPA dengan checksums
- Generate release notes

---

## ♻️ Update App

Setelah modify code:

```bash
# Stage changes
git add .

# Commit
git commit -m "Update: describe your changes"

# Push
git push origin main
```

GitHub Actions akan auto-rebuild! 🔄

---

## 🐛 Troubleshooting

### Build Failed?

**Check workflow logs:**
1. Go to Actions tab
2. Click failed run
3. Expand step yang failed
4. Read error message

**Common Issues:**

❌ **"Could not resolve package dependencies"**
```bash
# Fix: Update Package.swift or check SwiftSoup availability
```

❌ **"No scheme named AnichinApp"**
```bash
# Fix: Ensure AnichinApp.xcodeproj exists
# Check scheme name in Xcode
```

❌ **"xcodebuild exited with code 65"**
```bash
# Fix: Build error in code
# Check syntax errors, missing files, etc.
```

### Download Problems?

**Artifact expired (30 days)?**
- Trigger new build: push any commit
- Or create new tag for release

**IPA too large (over 100MB)?**
- GitHub artifacts max 5GB (no problem)
- Release assets max 2GB (still ok)

---

## 💡 Tips & Tricks

### Enable Actions (if disabled)

```
Settings → Actions → General
→ Allow all actions and reusable workflows
→ Save
```

### View Build Logs Real-time

```
Actions → Click running workflow
→ Click "Build IPA" job
→ Expand steps to see live logs
```

### Build Status Badge

Add to your README:
```markdown
[![Build](https://github.com/username/anichin-ios/actions/workflows/build-ios.yml/badge.svg)](https://github.com/username/anichin-ios/actions)
```

### Schedule Builds

Edit `.github/workflows/build-ios.yml`:
```yaml
on:
  schedule:
    - cron: '0 0 * * 0'  # Every Sunday at midnight
```

---

## 📞 Support

**Issues?**
- Check [Troubleshooting](#-troubleshooting) above
- Review workflow logs in Actions tab
- Create GitHub issue di repo

**Questions?**
- Check README.md untuk full documentation
- Review workflow files di `.github/workflows/`

---

## ✅ Success Checklist

- [ ] GitHub repo created
- [ ] Code pushed to main branch
- [ ] GitHub Actions workflow triggered
- [ ] Build completed successfully ✅
- [ ] IPA downloaded from artifacts/releases
- [ ] Installed via Scarlet/AltStore/Sideloadly
- [ ] Certificate trusted
- [ ] App launched successfully 🎉

**Enjoy streaming donghua!** 🎬
