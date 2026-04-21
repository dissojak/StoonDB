# How To Use

## 1. Install Prerequisites

Install Homebrew packages:

```bash
brew install mysql php phpmyadmin
```

Start MySQL:

```bash
brew services start mysql
```

## 2. Serve phpMyAdmin Locally

Start phpMyAdmin on `127.0.0.1:8080`:

```bash
php -S 127.0.0.1:8080 -t /opt/homebrew/share/phpmyadmin
```

If you already configured a launch agent, ensure it is running.

## 3. Run the App in Development

```bash
swift run
```

## 4. Use the Controls

- Start MySQL: starts Homebrew MySQL service.
- Stop MySQL: stops Homebrew MySQL service.
- Restart MySQL: restarts Homebrew MySQL service.
- Open phpMyAdmin: opens `http://127.0.0.1:8080` in your default browser.

## 5. Build a Double-Clickable App Bundle

```bash
./scripts/build-release.sh
open dist/StoonDB.app
```

## 6. Troubleshooting

- If MySQL actions fail, run `brew services list` and verify `mysql` exists.
- If phpMyAdmin does not open, check `http://127.0.0.1:8080/index.php` directly.
- If the app cannot find Homebrew from Finder launch, ensure Homebrew is installed in `/opt/homebrew/bin/brew` or `/usr/local/bin/brew`.
