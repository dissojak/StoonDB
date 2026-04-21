# Release and Install

## Build a Release Package

From project root:

```bash
chmod +x scripts/build-release.sh
./scripts/build-release.sh v1.0.0
```

This generates:

- `dist/ServerSQLPanel.app`
- `dist/ServerSQLPanel-macOS-v1.0.0.zip`

## Install (End User)

1. Download `ServerSQLPanel-macOS-<version>.zip` from Releases.
2. Unzip the file.
3. Drag `ServerSQLPanel.app` into `/Applications`.
4. Open the app.

If macOS blocks first launch:

1. Right-click the app.
2. Choose Open.
3. Confirm Open.

## Publish a GitHub Release

1. Commit changes.
2. Tag a version:

```bash
git tag v1.0.0
git push origin main --tags
```

3. GitHub Actions workflow `.github/workflows/release.yml` builds and uploads the ZIP.
