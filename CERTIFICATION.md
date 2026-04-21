# Certification

This file tracks release-readiness checks for distributable builds.

## Product

- Name: StoonDB
- Platform: macOS 13+
- App Type: Native SwiftUI control panel
- Scope: Controls local MySQL service and opens local phpMyAdmin URL

## Release Certification Checklist

- [x] Builds in Debug mode (`swift build`)
- [x] Builds in Release mode (`swift build -c release`)
- [x] App bundle can be generated (`dist/StoonDB.app`)
- [x] MySQL start/stop/restart commands execute via Homebrew services
- [x] phpMyAdmin URL opens in default browser
- [x] README includes install and run instructions
- [x] License and copyright files are present

## Security Notes

- This app executes local service commands only.
- No remote telemetry is collected by default.
- Credentials are not stored by the app; it assumes local environment setup.

## Certification Record

- Date: 2026-04-21
- Certified by: Project Maintainers
- Status: Certified for local developer use
