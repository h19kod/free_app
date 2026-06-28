<div align="center">

# 🛒 AppMarket Mobile

### Global Project Marketplace — Buy, Sell & Build Digital Projects

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)

</div>

---

## 📖 Overview

**AppMarket Mobile** is a full-featured cross-platform marketplace application built with Flutter, allowing users to buy and sell ready-made digital projects, post startup ideas, connect with developers, and manage transactions securely — all from a single, polished mobile/web experience.

---

## ✨ Features

### 🔐 Authentication & Security
- Email & Password login / registration
- **Biometric Authentication** — fingerprint & Face ID support
- **Two-Factor Authentication (2FA)** — TOTP-based extra security layer
- Secure token storage with session management
- Splash screen with auto-login flow
- Full onboarding experience for new users

### 🛍️ Marketplace
- Browse ready-made digital projects and apps for sale
- Detailed project listing pages with screenshots & descriptions
- Create & publish your own project listings
- Advanced search & filtering by category, price, and tags
- Cached network images for fast loading

### 💡 Ideas Hub
- Post startup ideas to attract developer proposals
- Browse community ideas and submit proposals
- Idea detail view with proposal management

### 💬 Real-time Chat
- WebSocket-powered instant messaging
- Chat list with conversation history
- Per-conversation chat screens
- Notification-aware messaging

### 💳 Payments & Escrow
- Secure **Escrow system** — funds held until delivery confirmed
- **Stripe payment integration** for safe transactions
- Payment history and transaction tracking
- Built-in dispute resolution for failed deals

### ⚖️ Dispute Management
- Open and track disputes on transactions
- Admin-mediated resolution flow
- Status updates and notifications per dispute

### 📊 Dashboard
- Personal dashboard with quick-action cards
- Escrow balance & active transaction overview
- Dispute summary and status indicators
- Earnings and spending analytics

### 👤 Profile & Settings
- Full user profile management
- Avatar upload and personal info editing
- KYC (Know Your Customer) verification flow
- Multi-language switcher (6 languages)
- Light / Dark theme toggle

### 🔔 Notifications
- Rich push notification support
- In-app notification center
- Notification badge counts on bottom navigation
- Custom notification handling per event type

### 🔍 Search
- Global full-text search across projects and ideas
- Search history and smart suggestions
- Debounced search with instant results

### 🌍 Internationalization (i18n)
- **6 supported languages:** Arabic (AR), Arabic-SA, English (EN), English-US, French (FR), Spanish (ES)
- RTL support for Arabic
- Runtime language switching without restart

### 🎨 UI & Animations
- Modern Material Design 3 with custom theming
- **Lottie** animations for loading states and empty screens
- **Rive** animations for interactive micro-interactions
- **Flutter Animate** for smooth page transitions
- Staggered list animations & shimmer loading skeletons
- Animated text effects (AnimatedTextKit)
- Google Fonts integration

### 🛠️ Admin Panel
- Admin-only dashboard with platform statistics
- User management (view, ban, unban)
- KYC review and approval flow
- Dispute mediation interface

### 📱 Platform Support
- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (Progressive Web App)
- **Windows** desktop support

---

## 🧰 Tech Stack

| Layer | Technology |
|---|---|
| **Frontend** | Flutter 3.0+ (Dart) |
| **Backend** | FastAPI (Python) |
| **Database** | PostgreSQL (prod) / SQLite (dev) |
| **State Management** | Riverpod 2 + Provider |
| **Navigation** | GoRouter 13 |
| **HTTP Client** | Dio 5 + http |
| **Real-time** | WebSocket (web_socket_channel) |
| **Payments** | Stripe |
| **Auth** | JWT + Biometric + 2FA (TOTP) |
| **Caching** | SharedPreferences + CachedNetworkImage |
| **Animations** | Lottie · Rive · Flutter Animate · Shimmer |
| **i18n** | easy_localization (6 languages) |
| **QR Codes** | qr_flutter + qr_code_scanner |

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`
- Android Studio / Xcode (for mobile targets)
- Backend running at `http://localhost:8000` ([see backend repo](#))

### Install Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d ios

# Web browser
flutter run -d chrome

# Windows desktop
flutter run -d windows
```

### API Configuration
Edit `lib/core/services/api_service.dart` to set your backend URL:

```dart
// Android emulator
const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// iOS simulator / Web
const String baseUrl = 'http://localhost:8000/api/v1';

// Real device (replace with your machine's local IP)
const String baseUrl = 'http://192.168.x.x:8000/api/v1';
```

---

## 📁 Project Structure

```
lib/
├── main.dart
├── core/
│   ├── constants/          # App-wide constants
│   ├── router/             # GoRouter navigation & route definitions
│   ├── theme/              # Material theme, colors & typography
│   ├── utils/              # Shared utility functions
│   ├── widgets/            # Reusable UI components
│   └── services/
│       ├── api_service.dart          # Dio HTTP client & interceptors
│       ├── animation_service.dart    # Animation helpers
│       ├── biometric_service.dart    # Fingerprint / Face ID
│       ├── cache_service.dart        # Local caching layer
│       ├── file_service.dart         # File handling utilities
│       ├── localization_service.dart # i18n runtime switching
│       ├── notification_service.dart # Push & in-app notifications
│       ├── payment_service.dart      # Stripe payment flows
│       ├── profile_service.dart      # User profile CRUD
│       ├── search_service.dart       # Global search logic
│       └── two_factor_service.dart   # 2FA / TOTP management
└── features/
    ├── auth/               # Login, Register, Splash
    ├── onboarding/         # First-launch onboarding screens
    ├── home/               # Main scaffold + bottom navigation
    ├── marketplace/        # Project listings — browse, detail, create
    ├── ideas/              # Ideas — browse, detail, create, proposals
    ├── chat/               # Chat list & real-time chat screen
    ├── dashboard/          # Escrow, earnings, quick actions
    ├── payment/            # Stripe checkout & payment history
    ├── disputes/           # Dispute filing & tracking
    ├── notifications/      # Notification center
    ├── search/             # Global search UI
    ├── profile/            # User profile & avatar
    ├── kyc/                # KYC identity verification
    ├── settings/           # App settings & preferences
    ├── theme/              # Theme switcher
    └── admin/              # Admin panel — stats, users, KYC review
```

---

## 🌐 Supported Languages

| Code | Language |
|------|----------|
| `en` | English |
| `en-US` | English (US) |
| `ar` | Arabic (العربية) |
| `ar-SA` | Arabic — Saudi Arabia |
| `fr-FR` | French (Français) |
| `es-ES` | Spanish (Español) |

---

## 🔑 Default Admin Account

> ⚠️ **Change these credentials before deploying to production.**

```
Email:    admin@appmarket.com
Password: admin123
```

---

## 📦 Key Dependencies

```yaml
# Networking
dio: ^5.4.0
web_socket_channel: ^2.4.0

# State & Navigation
flutter_riverpod: ^2.4.10
go_router: ^13.0.0

# UI & Animations
flutter_animate: ^4.2.0
lottie: ^2.7.0
rive: ^0.11.17
shimmer: ^3.0.0
animated_text_kit: ^4.2.2
flutter_staggered_animations: ^1.1.1
google_fonts: ^6.2.1

# Utilities
easy_localization: ^3.0.2
flutter_rating_bar: ^4.0.1
cached_network_image: ^3.3.1
qr_flutter: ^4.1.0
intl: ^0.20.2
```

---

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch: `git checkout -b feature/amazing-feature`
3. Commit your changes: `git commit -m 'Add amazing feature'`
4. Push to the branch: `git push origin feature/amazing-feature`
5. Open a Pull Request

---

## 📄 License

This project is licensed under the **MIT License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">
  Built with ❤️ using Flutter
</div>
