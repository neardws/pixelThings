# App Icon Resources

Place the following icon files in this directory:

## Required Files

| File | Size | Format | Usage |
|------|------|--------|-------|
| `app_icon.png` | 256x256 | PNG | General use, macOS |
| `app_icon.ico` | Multi-size | ICO | Windows app icon |
| `tray_icon.png` | 22x22 | PNG | System tray |

## Icon Design Guidelines

- **Style**: Pixel art / retro digital clock
- **Background**: Transparent
- **Colors**: Green (#00FF00) on black or transparent
- **Content**: Simplified clock digits "12:34" or pixel grid pattern

## Recommended Design

```
Simple pixel clock face:
┌────────────┐
│  ██ ██     │
│  ██ ██     │
│     ██     │
│  ██ ██     │
│  ██ ██     │
└────────────┘
```

## How to Generate

You can use any pixel art editor like:
- Aseprite
- Piskel (free online)
- GIMP

Or generate programmatically with Flutter/Dart using the `image` package.
