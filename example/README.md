# video_walkthrough example

A three-page onboarding with a looping background video, a logo, custom dot
colors and a Start button that replaces the walkthrough with a home screen.

```bash
flutter pub get
flutter run            # Android / iOS
flutter run -d chrome  # Web
```

`assets/intro.mp4` is an abstract gradient clip generated with FFmpeg's
`gradients` source for this example, and `assets/logo.png` is a simple
play-icon drawn for it. Both ship under the package's MIT license.
