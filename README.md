# ServerSQLPanel

A lightweight native macOS control panel for local MySQL and phpMyAdmin.

## Status

- Native macOS app (SwiftUI)
- Repository includes licensing, contribution docs, issue templates, CI, and release workflow
- Release packaging script creates installable app ZIP artifacts

## What It Does

- Start MySQL via Homebrew services
- Stop MySQL via Homebrew services
- Restart MySQL via Homebrew services
- Open phpMyAdmin in the default browser

This app is a control layer only. It does not install MySQL, phpMyAdmin, Homebrew, or PHP.

## Prerequisites

1. macOS 13 or newer
2. Homebrew installed (app auto-detects common Homebrew paths)
3. MySQL installed as Homebrew formula `mysql`
4. phpMyAdmin served at `http://127.0.0.1:8080`

## Run Locally

```bash
cd /Users/stoon/Desktop/Projects/serverSQL
swift run
```

## Build Release Package

```bash
chmod +x scripts/build-release.sh
./scripts/build-release.sh v1.0.0
```

Generated files:

- `dist/ServerSQLPanel.app`
- `dist/ServerSQLPanel-macOS-v1.0.0.zip`

## Install from Release ZIP

1. Download `ServerSQLPanel-macOS-<version>.zip` from Releases.
2. Unzip it.
3. Move `ServerSQLPanel.app` into `/Applications`.
4. Launch the app.

If macOS blocks first launch:

1. Right-click app and choose Open.
2. Confirm Open.

## Change phpMyAdmin URL

Edit the default URL in `Sources/PhpMyAdminLauncher.swift`:

```swift
init(urlString: String = "http://127.0.0.1:8080")
```

## Troubleshooting

- If MySQL actions fail, verify Homebrew service visibility:
  - `brew services list`
- If phpMyAdmin does not open, verify the local server is reachable:
  - `open http://127.0.0.1:8080`
- To confirm the phpMyAdmin endpoint is up, run:
  - `curl -I http://127.0.0.1:8080/index.php`

## Git and Project Standards

- License: `LICENSE`
- Copyright: `COPYRIGHT`
- Certification checklist: `CERTIFICATION.md`
- Usage guide: `HOW_TO_USE.md`
- Contribution guide: `CONTRIBUTING.md`
- Code of conduct: `CODE_OF_CONDUCT.md`
- Security policy: `SECURITY.md`
- Changelog: `CHANGELOG.md`
- Release process: `RELEASE.md`

## GitHub Automation

- CI workflow: `.github/workflows/ci.yml`
- Release workflow: `.github/workflows/release.yml`
- Issue templates: `.github/ISSUE_TEMPLATE/`
- PR template: `.github/pull_request_template.md`
