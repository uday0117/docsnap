# DocSnap

**DocSnap** is a production-ready Flutter document scanner and PDF manager — scan, enhance, OCR, sign, merge, and share documents with all core features free.

## Features

### Document Scanner
- Auto edge detection & manual crop
- Multi-page & batch scanning
- Smart scan modes: Document, Receipt, Passport, ID Card, Business Card, Book, Whiteboard
- Camera flash, gallery import, page reorder/delete

### Image Enhancement
- Filters: Original, Auto Enhance, Magic Color, B&W, Grayscale, Color, Document, Receipt
- Adjustments: Brightness, Contrast, Saturation, Sharpness

### PDF Tools
- Generate, merge, split, compress PDFs
- Watermark, digital signature
- Export quality: Low / Medium / High

### OCR
- Image & document text extraction (Google ML Kit)
- Copy, search, multi-language support

### Organization
- Folders, favorites, pinned documents
- Search by filename, OCR text, tags
- Soft-delete trash with restore

### More
- QR & barcode scanner
- Dark / light theme
- Firebase Analytics & Crashlytics
- Google Mobile Ads (non-intrusive — never during scanning)

## Tech Stack

| Layer | Technology |
|-------|------------|
| Framework | Flutter (stable) |
| State / DI | GetX |
| Architecture | MVVM + Clean Architecture |
| Storage | GetStorage (local JSON persistence) |
| PDF | `pdf` package |
| Image | `image` package |
| OCR | Google ML Kit |
| Camera | `camera` |
| Edge detection | Custom OpenCV-style algorithm |
| Ads | Google Mobile Ads |
| Analytics | Firebase Analytics + Crashlytics |

## Project Structure

```
lib/
├── core/           # Config, crashlytics
├── bindings/       # GetX dependency injection
├── controllers/    # ViewModels (business logic)
├── models/         # Data models
├── repositories/   # Data access layer
├── routes/         # Navigation
├── services/       # PDF, image, OCR, ads, analytics
├── themes/         # Material 3 theming
├── translations/   # i18n (10 languages)
├── utils/          # Constants, helpers
├── views/          # UI screens
└── widgets/        # Reusable components
```

## Getting Started

```bash
flutter pub get
flutter run
```

### Firebase (Android)

1. Add `google-services.json` to `android/app/`
2. Enable Analytics and Crashlytics in Firebase Console

### Build release

```bash
flutter build apk --release
flutter build appbundle --release
```

## Architecture

```
View (Screen) → Controller (GetX) → Repository → Service / Storage
```

- **Views**: Material 3 UI only
- **Controllers**: State, user actions, orchestration
- **Repositories**: Document & signature persistence
- **Services**: PDF generation, image processing, OCR, ads, analytics

## License

© UK Solutions. All rights reserved.
