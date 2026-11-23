# Monster-Energy-TCG

![Scan a can, get a card](docs/banner.png)

An Android app (built with Flutter) that scans your Monster Energy can and turns it into a trading card for your virtual collection.

> **Status:** early development. The concept art above is illustrative only, not a screenshot.

## How it works

1. **Scan** – point the camera at the barcode on the can.
2. **Identify** – the barcode is matched to a flavor. The first time you scan an unknown barcode, you pick the flavor and the app remembers it.
3. **Generate** – a card is created procedurally and deterministically from the flavor's data, so the same flavor always gives the same card.
4. **Collect** – the card is saved to your local collection. Scanning the same flavor again adds a duplicate copy.

## Card stats

| Stat | Derived from |
| --- | --- |
| Rarity | Product line (Rehab → Ultra → Original → Juice → Java) |
| Attack / Speed | Caffeine content |
| Defense | Sugar content |
| Energy cost | Calories |
| Ability | Product line, picked deterministically |

## Tech stack

- Flutter (Android target)
- [`mobile_scanner`](https://pub.dev/packages/mobile_scanner) for barcode scanning
- [`sqflite`](https://pub.dev/packages/sqflite) for local storage, no account or backend required

## Roadmap

- [x] Project setup and design decisions
- [x] Flavor catalog and procedural card generator
- [x] Barcode scan flow with barcode-to-flavor linking (not yet tested on a device)
- [x] Collection screen with duplicate counts (not yet tested on a device)
- [ ] Photo-based can recognition
- [ ] Real card artwork

## Themes

Both the app and the website ship a dark theme (default) and a **Monster Ultra White** theme, with its own white/silver/ice-blue palette, Barlow Condensed headings ([SIL OFL](assets/fonts/OFL.txt)) and a bright banner ([docs/banner-ultra-white.png](docs/banner-ultra-white.png), AI-generated concept art). Use the sun/moon button in the app bar, or the "Ultra White" button in the website nav. The choice is remembered (in the local database in the app, in `localStorage` on the site).

## Website

The promo site is [index.html](index.html), a single file with no build step, published with GitHub Pages at **https://gaymer404.github.io/Monster-Energy-TCG/**.

It is deployed from the `main` branch, `/ (root)` (Settings → Pages). To preview it locally, open `index.html` in a browser.

## Posting on X

The **Promote on X** workflow posts daily at 16:00 UTC. Manual runs default to a dry run; disable `dry_run` to publish.

For live posts, configure an X developer app with OAuth 1.0a and Read and write permissions. In GitHub, add its API key and secret as Actions secrets `X_API_KEY` and `X_API_SECRET`, and its user access token and secret as `X_ACCESS_TOKEN` and `X_ACCESS_TOKEN_SECRET` (Settings → Secrets and variables → Actions). All four must belong to the same app and authorized account; regenerate the access token after changing app permissions.

If a live run fails with HTTP 401, verify the keys and tokens in the X developer portal, regenerate them if needed, and update the corresponding GitHub Actions secrets. Run the workflow manually with `dry_run` disabled to verify authentication. A dry run does not validate credentials or publish a post.

## Project structure

| Path | Purpose |
| --- | --- |
| `lib/models/` | Flavor catalog and card model |
| `lib/services/card_generator.dart` | Deterministic card generation |
| `lib/services/collection_db.dart` | SQLite collection and barcode links |
| `lib/screens/` | Scan and collection screens |
| `lib/theme.dart` | Dark and Ultra White themes, theme toggle |
| `lib/widgets/card_view.dart` | Card rendering |
| `test/` | Unit tests for the generator |

## Getting started

Requires the [Flutter SDK](https://docs.flutter.dev/get-started/install) and an Android device or emulator.

```bash
flutter pub get
flutter test
flutter run
```

The Android project is already generated. The camera permission is declared in `android/app/src/main/AndroidManifest.xml`.

## Disclaimer

This is an unofficial fan project. It is not affiliated with, endorsed by, or sponsored by Monster Beverage Corporation. Monster Energy and related marks are trademarks of their respective owners.