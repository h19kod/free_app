# AppMarket Mobile — Flutter App

Global Project Marketplace for buying, selling, and building digital projects.

## Features
- Authentication (Email/Password)
- Marketplace — Browse & buy ready-made projects
- Ideas — Post startup ideas & receive developer proposals
- Real-time Chat — WebSocket messaging
- Reviews & Ratings
- Escrow & Payments (Stripe)
- Disputes
- Admin Panel
- Dashboard

## Tech Stack
- **Frontend:** Flutter (iOS + Android)
- **Backend:** FastAPI (Python)
- **Database:** PostgreSQL / SQLite (dev)
- **State Management:** Riverpod
- **Navigation:** GoRouter
- **HTTP:** Dio

## Setup

### Prerequisites
- Flutter SDK >= 3.0.0
- Android Studio / Xcode
- Backend running at `http://localhost:8000`

### Install
```bash
flutter pub get
```

### Run
```bash
# Android emulator
flutter run

# iOS simulator
flutter run -d ios
```

### API Configuration
Edit `lib/core/services/api_service.dart`:
```dart
// Android emulator
const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// iOS simulator
const String baseUrl = 'http://localhost:8000/api/v1';

// Real device (use your machine's IP)
const String baseUrl = 'http://192.168.x.x:8000/api/v1';
```

## Project Structure
```
lib/
├── main.dart
├── core/
│   ├── theme/         # App theme & colors
│   ├── router/        # GoRouter navigation
│   └── services/      # API service (Dio)
└── features/
    ├── auth/          # Login, Register, Splash
    ├── home/          # Main scaffold with bottom nav
    ├── marketplace/   # Listings browse, detail, create
    ├── ideas/         # Ideas browse, detail, create
    ├── chat/          # Chat list, chat screen
    ├── dashboard/     # Escrow, disputes, quick actions
    ├── profile/       # User profile & settings
    └── admin/         # Admin panel (stats, users, KYC)
```

## Admin Account
```
Email: admin@appmarket.com
Password: admin123
```
