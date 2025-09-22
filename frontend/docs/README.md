# QR Scanner App Documentation

## Overview
This Flutter app scans QR codes using the device camera. It uses the latest `qr_code_scanner` package for cross-platform support.

## Structure
- `lib/main.dart`: App entry point, launches the QR scanner.
- `lib/qr_scanner.dart`: Contains the QR scanner widget and logic.
- `pubspec.yaml`: Lists dependencies.
- `docs/`: Project documentation.

## Usage
- Run `flutter pub get` to install dependencies.
- Launch the app on a device/emulator.
- Grant camera permissions when prompted.
- Point the camera at a QR code to scan.

## Decisions & Trade-offs
- Chose `qr_code_scanner` for its active maintenance and multi-platform support.
- Logging is done via `print` statements for simplicity; consider a logging package for production.
- The app is modular: scanner logic is separated from the main entry point.

## Edge Cases
- Handles camera permission errors.
- Displays scan result or prompts user to scan.

## Future Improvements
- Add support for flashlight toggle.
- Add scan history.
- Improve error handling and UI feedback.

---
For more details, see code comments and inline documentation.
