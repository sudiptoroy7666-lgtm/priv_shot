
# 🛡️ PrivShot
**Privacy-First Screenshot Sanitizer for Android**

Detect sensitive information, calculate privacy risk, redact PII, strip metadata, and share safely — **100% offline, zero internet permission, no backend.**

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?logo=dart)](https://dart.dev)
[![Android](https://img.shields.io/badge/Android-API_21+-3DDC84?logo=android)](https://developer.android.com)
[![Offline](https://img.shields.io/badge/Privacy-100%25_Offline-success)](#)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)

---

## ✨ Key Features

| Feature | Description |
|:---|:---|
| 🔍 **On-Device PII Detection** | Uses bundled Google ML Kit to detect emails, phones, credit cards, addresses, IDs, OTPs, IPs, and more. |
| 🎨 **Interactive Redact Canvas** | Draw custom redaction boxes, dismiss false positives, and toggle between **Draw** & **Zoom/Pan** modes. |
| 📊 **Privacy Risk Score** | 0–100 weighted scoring system with real-time breakdown and risk status (`Low` / `Medium` / `High`). |
| ⚡ **Smart Presets** | One-tap redaction modes: `Social Media`, `Financial`, `Full Privacy`. |
| 🕵️ **Metadata Stripping** | Automatically destroys EXIF, GPS, device model, and timestamp data on export. |
| 🔒 **100% Offline & Private** | Zero `INTERNET` permission. No backend, no analytics, no cloud processing. All ML runs locally. |
| 📤 **Share Intent Integration** | Acts as a secure middle-man. Share images from any app → PrivShot redacts → forwards safely. |
| 🌙 **Premium Dark UI** | Modern glassmorphism design with adaptive theming and smooth animations. |

---

## 📱 Screenshots
 'https://github.com/.../Screenshot%202026-06-06%20115510.png?raw=true',
    'https://github.com/.../Screenshot%202026-06-06%20115429.png?raw=true',
    'https://github.com/.../Screenshot%202026-05-30%20161859.png?raw=true'
  ]
},

        
        
      {label:'Vault List', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v6.png?raw=true'},
      {label:'Add Entry', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v7.png?raw=true'},
      {label:'Signup', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v1.jpg?raw=true'},
      {label:'Login', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v2.jpg?raw=true'},
      {label:'Reset Password', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v3.jpg?raw=true'},
      {label:'Master Password', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v4.png?raw=true'},
      {label:'Password View PIN', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v5.png?raw=true'},
      {label:'Password View', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v8.png?raw=true'},
      {label:'Import Backup', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v9.jpg?raw=true'},
      {label:'Export Data', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v10.jpg?raw=true'},
      {label:'Settings', url:'https://github.com/sudiptoroy7666-lgtm/portfolio/blob/main/assets/screenshots/vaultx/v11.png?raw=true'}
    ],


---

## 🧠 How It Works

1. **Image Input:** User selects an image or shares one from another app via Android's `ACTION_SEND` intent.
2. **OCR & PII Detection:** ML Kit extracts text blocks on-device. Regex patterns match 9 PII types with false-positive rejection (Luhn check, private IP filtering, test domain blocking).
3. **Scoring & Presets:** A weighted algorithm calculates a 0–100 privacy score. Presets instantly toggle redaction states based on context.
4. **Canvas Interaction:** Users can draw custom boxes, dismiss auto-detections, and zoom for precision. Coordinate transformation ensures pixel-perfect alignment.
5. **Redaction & Export:** Selected regions are filled with solid black using `dart:ui`. The image is re-encoded to strip all EXIF/GPS metadata before sharing or saving.

---

## 🛠️ Tech Stack

| Layer | Technology |
|:---|:---|
| **Framework** | Flutter 3.x + Dart 3.x |
| **State Management** | `ChangeNotifier` / `Provider` |
| **OCR Engine** | `google_mlkit_text_recognition` (on-device) |
| **Image Processing** | `dart:ui` (canvas), `image` (metadata stripping) |
| **File & Sharing** | `path_provider`, `share_plus`, `gal`, `receive_sharing_intent` |
| **Testing** | `flutter_test`, `mockito` (70+ unit tests) |

---

## 📦 Installation & Setup

### Prerequisites
- Flutter SDK `>=3.3.0`
- Dart SDK `>=3.0.0`
- Android Studio / VS Code with Flutter extensions
- Android device or emulator (API 21+)

### Steps
```bash
# 1. Clone the repository
git clone https://github.com/yourusername/priv_shot.git
cd priv_shot

# 2. Fetch dependencies
flutter pub get

# 3. Configure Android
# Open android/app/build.gradle.kts and ensure:
# minSdk = 21

# 4. Run the app
flutter run
```

> ⚠️ **Important:** The app intentionally **does not declare** the `INTERNET` permission in the `AndroidManifest.xml`. All processing happens locally. 

---

## 📖 Usage Guide

### 🏠 Normal Launch
1. Open PrivShot from your app drawer.
2. Tap **Select Screenshot** to pick an image from your gallery.
3. Review detected PII, adjust boxes, or apply a preset.
4. Tap **Share Safe** or **Save** to export the redacted, metadata-free image.

### 🔄 Share Intent (Middle-Man Mode)
1. Open any app (Gallery, WhatsApp, Twitter, etc.).
2. Select an image and tap the native **Share** button.
3. Choose **PrivShot** from the share sheet.
4. The app will auto-scan, allow quick adjustments, and forward the safe image back to your target app.

### 🎨 Canvas Controls
- **Draw Mode:** Drag to create custom blue redaction boxes.
- **Zoom/Pan Mode:** Pinch to zoom, drag to pan for precision.
- **Dismiss:** Tap the red `✕` button on auto-detected boxes to ignore false positives.
- **Toggle:** Tap any detection chip to enable/disable redaction.

---

## 📁 Project Structure

```text
lib/
├── main.dart                 # App entry & share intent routing
├── core/                     # Theme, constants, utilities
├── models/                   # Data classes (RedactBox, PrivacyScore, ReviewState)
├── domain/                   # Business logic (PiiMatcher, PrivacyScorer, PresetManager)
├── services/                 # Engine layer (OcrEngine, BitmapRedactor, ImageService)
├── widgets/                  # Reusable UI components (Canvas, ScoreCard, Presets, Chips)
└── screens/                  # App screens (Home, Review, Result, Settings)

test/
├── pii_matcher_test.dart     # 50+ regex & false-positive tests
├── privacy_scorer_test.dart  # 15+ scoring & breakdown tests
├── preset_manager_test.dart  # 12+ preset rule tests
└── bitmap_redactor_test.dart # 8+ redaction & bounds tests
```

---

## 🧪 Testing

PrivShot includes **70+ unit tests** covering core logic, edge cases, and false-positive rejection.

```bash
# Run all tests
flutter test

# Run with coverage
flutter test --coverage
```

**Test Coverage Highlights:**
- ✅ Email/Phone/Card/IP/Address/OTP regex validation
- ✅ Luhn algorithm & private IP rejection
- ✅ Weighted scoring clamping & status labels
- ✅ Preset rule application & toggling
- ✅ Canvas coordinate bounds & zero-size box handling
- ✅ Metadata stripping verification

---

## 🔒 Privacy & Security Model

PrivShot is designed with a **privacy-by-default** architecture:
- 🚫 **No Internet Permission:** The manifest explicitly omits `android.permission.INTERNET`. Data cannot leave the device.
- 📱 **On-Device ML:** Google ML Kit's text recognition model is bundled in the APK (~7MB) and runs entirely locally.
- 🗑️ **Metadata Destruction:** Exported images are decoded and re-encoded, permanently stripping EXIF, GPS, timestamps, and device fingerprints.
- 📦 **No Third-Party Analytics:** Zero tracking SDKs, zero crash reporters, zero backend calls.

---

## 📦 Building for Release

### Generate App Bundle (Recommended for Play Store)
```bash
flutter build appbundle --release
```
*Output: `build/app/outputs/bundle/release/app.aab`*

### Generate APK
```bash
flutter build apk --release --split-per-abi
```

---

## 🤝 Contributing

Contributions are welcome! Please follow these steps:
1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

**Guidelines:**
- Maintain the existing folder structure
- Add unit tests for new domain logic
- Keep the app 100% offline (no network calls)
- Follow Dart/Flutter linting standards (`flutter analyze`)

---

## 📜 License

This project is licensed under the **MIT License**. See the [LICENSE](LICENSE) file for details.

---

**Built with ❤️ using Flutter & Dart. Your screenshots deserve privacy.** 🛡️
```
