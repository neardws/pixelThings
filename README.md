# Pixel Things

A cross-platform pixel clock and screensaver application built with Flutter.

## Features

- **Pixel Clock Display**: Retro-style LED matrix clock with circular pixels
- **8 Animation Effects**: Fire, Matrix, Rainbow, Game of Life, Worm, Plasma, Starfield, Snow
- **6 Color Themes**: Matrix Green, Cyber Blue, Sunset Orange, Neon Pink, Pure White, Retro Amber
- **Screensaver Mode**: Desktop idle detection with auto-activation
- **Date Display**: Alternating time/date display modes
- **Persistent Settings**: All preferences saved locally

## Platforms

| Platform | Status |
|----------|--------|
| Android | ✅ |
| iOS | ✅ |
| macOS | ✅ |
| Windows | ✅ |
| Linux | ✅ |

## Getting Started

```bash
# Install dependencies
flutter pub get

# Run on connected device
flutter run

# Build for specific platform
flutter build apk      # Android
flutter build ios      # iOS
flutter build macos    # macOS
flutter build windows  # Windows
flutter build linux    # Linux
```

## Project Structure

```
lib/
├── main.dart                    # Entry point
├── app.dart                     # App configuration
├── core/
│   ├── models/                  # Data models
│   ├── fonts/                   # Pixel fonts (5x7, 8x12)
│   └── utils/                   # Color & date utilities
├── plugins/                     # Animation effect plugins
├── widgets/                     # Pixel canvas renderer
├── screens/                     # Main & settings screens
├── providers/                   # State management (Riverpod)
└── platform/                    # Platform-specific code
    ├── desktop/                 # Window, tray, screensaver
    └── mobile/                  # Keep screen on
```

## Controls

### Desktop
- `Space` - Toggle effect
- `Esc` - Clock only mode
- `S` - Open settings
- `Arrow keys` - Switch effects

### Mobile
- Single tap - Next effect
- Double tap - Clock only mode
- Long press - Open settings

## License

MIT
