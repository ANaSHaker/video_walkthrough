# Changelog

## 2.0.0

A modernization release. The widget looks and behaves the same, but the code
now builds on current Flutter (Dart 3) and several long-standing bugs are fixed.

### Fixed
- Inactive indicator dots used `indicatorActiveColor`; they now use
  `indicatorInActiveColor`.
- Tapping **Start** without a `pageRoute` crashed (`pageRoute!`). Finishing is
  now null-safe: `onFinish` is called if set, otherwise `pageRoute` is pushed,
  otherwise nothing happens.
- The package no longer compiled on Flutter 3.x because `FlatButton` was
  removed. Buttons now use `TextButton`, `OutlinedButton` and `ElevatedButton`.
- The page slide-in animation was created but never applied; pages now slide
  and fade in.
- The video controller is created once, awaited before playing, and always
  disposed. A missing or broken video no longer throws; the background color is
  shown instead.
- System UI overlays hidden by the walkthrough are restored when it is disposed.

### Changed (breaking)
- Requires Dart `^3.3.0` and Flutter `>=3.19.0`.
- `Walkthrough.title` and `Walkthrough.content` are required `String`s
  (previously untyped). Style fields are typed `TextStyle?`.
- Optional parameters now have non-null defaults (for example
  `dotSize = 8.0`, `skipText = 'Skip'`) instead of nullable types.
- `pageRoute` accepts any `Route` (was `MaterialPageRoute`).
- The public `VideoWalkThrough.skipPage(context)` method was removed; use
  `onFinish` or `pageRoute`.
- The background video now covers the screen (`BoxFit.cover`); `videoScale`
  is an extra zoom on top of that.

### Added
- `onFinish`, `replaceOnFinish`, `backgroundColor`, `hideSystemOverlays`
  parameters, and `textAlign` / `animationDuration` on `Walkthrough`.
- A single import: `package:video_walkthrough/video_walkthrough.dart` exports
  both widgets (`walkthrough.dart` still works).
- Dartdoc on the whole public API, 11 widget tests and a runnable example app.

## 1.0.1

- Fix some issues.

## 1.0.0

- First release.
