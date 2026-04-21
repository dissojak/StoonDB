# 🚀 Release & Installation Guide

Welcome to the **ServerSQLPanel** release documentation! This guide explains how to build the application from source, generate a standard macOS App Bundle (`.app`), and publish new releases to GitHub.

---

## 🎨 Adding a Custom App Icon

If you want to add an icon to your app before distributing it:

1. Place your desired app image (e.g., `my-custom-icon.png`) anywhere on your Mac. (Ideally a 1024x1024 square PNG).
2. Run the included generator script (it uses built-in macOS image tools to automatically generate the `.icns` bundle):
   ```bash
   ./scripts/generate-icon.sh path/to/my-custom-icon.png
   ```
3. The script will automatically create `assets/AppIcon.icns`. The build script handles the rest!


## 🛠️ Building a Release Package Locally

To manually compile the Swift project and build a standalone, double-clickable macOS App bundle, we use the included packaging script.

From the project root directory, run:

```bash
chmod +x scripts/build-release.sh
./scripts/build-release.sh v1.0.1
```

**This process will generate:**
- 📦 `dist/ServerSQLPanel.app` (The native macOS app)
- 🗜️ `dist/ServerSQLPanel-macOS-v1.0.1.zip` (The compressed archive for distribution)

---

## 📥 Installation (For End Users)

Share these instructions with anyone who wants to use your app:

1. Download the latest `ServerSQLPanel-macOS-<version>.zip` from the **[Releases](https://github.com/dissojak/StoonDB/releases)** page.
2. Extract the ZIP file.
3. Drag and drop **ServerSQLPanel.app** into your `/Applications` folder.
4. Double-click to open.

> ⚠️ **macOS Security Prompt ("Unidentified Developer")**
> Since this app is not signed through the Apple Developer Program:
> 1. **Right-click** (or Control-click) `ServerSQLPanel.app` in your Applications folder.
> 2. Select **Open** from the context menu.
> 3. Click **Open** again on the security warning. You only need to do this once!

---

## 🌎 Publishing to GitHub Releases

This repository is equipped with fully automated GitHub Actions CI/CD to generate public releases for downloading automatically.

### Triggering an Automated Release
You don't need to build manually for the public. Just push a `v*` tag to remote, and GitHub will do it for you!

```bash
# 1. Commit all your changes (like adding the new icon)
git add .
git commit -m "Feature: Added custom brand icon"

# 2. Tag the commit with the new version number
git tag v1.0.1

# 3. Push the tag to GitHub (Triggers the Release Workflow)
git push origin v1.0.1
```

Once pushed, the `.github/workflows/release.yml` workflow will automatically build the `.app`, zip it, and attach it to a brand new release on your GitHub repository page!
