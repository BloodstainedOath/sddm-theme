# Lightweight SDDM Theme

A modern, lightweight SDDM theme with extensive features and minimal dependencies.

## Features

### Appearance
- Auto-detection of screen resolution
- Light/dark theme with automatic mode based on system settings
- Customizable colors for light and dark themes
- Background image support with fit/fill options
- Random wallpaper selection from folder
- Rounded corners support
- Form transparency control
- Multiple avatar shapes (circle, square, rounded)

### User Interface
- User list with remembering last user
- Password field with customizable echo mode
- Session selection
- Keyboard layout selection
- Form transparency control
- Custom avatar shapes
- Customizable placeholders

### Power Options
- Shutdown, restart, suspend and hibernate buttons
- Configurable button visibility and position
- Custom icons and tooltips

### Accessibility
- High contrast mode
- Large print mode
- Screen reader support
- Reduced animations
- Tab navigation help
- Focus highlighting
- Virtual keyboard support

### Security & Privacy
- Login attempt limits with lockout
- Option to hide usernames
- Blurring of private information
- Login timeout

### Performance Optimization
- Disable blur effects for lower-end hardware
- Low performance mode disabling advanced effects
- Animation speed control
- Network connectivity checking with timeout

### Advanced Features
- Debug mode for troubleshooting
- Custom CSS and JavaScript support
- Network connection status indicator

## Requirements

This theme has extremely minimal requirements compared to other themes:

- SDDM (Simple Desktop Display Manager)
- Qt 5.12+ (no need for Qt 6)
- No QtGraphicalEffects dependency
- Standard system fonts (no special fonts required)
- Working with standard icon sets
- No external dependencies or special modules

## Installation

1. Copy this theme folder to `/usr/share/sddm/themes/` or `~/.local/share/sddm/themes/`
2. Edit `/etc/sddm.conf` and set `Current=lightweight` under the `[Theme]` section

## Configuration

All settings can be configured in the `theme.conf` file. Most settings have sensible defaults.

## License

This theme is licensed under GPL v3. 