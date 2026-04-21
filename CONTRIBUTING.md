# Contributing

Thanks for contributing to StoonDB.

## Development Setup

1. Install Xcode command line tools.
2. Install dependencies:

```bash
brew install mysql php phpmyadmin
```

3. Build:

```bash
swift build
```

## Coding Guidelines

- Keep the UI lightweight and focused.
- Avoid introducing Electron or Chromium dependencies.
- Keep shell command execution restricted to required local operations.
- Preserve Swift concurrency safety.

## Pull Request Process

1. Create a branch from `main`.
2. Ensure `swift build` succeeds.
3. Update documentation for behavior changes.
4. Open a PR with a clear summary and testing notes.
