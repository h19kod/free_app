<div align="center">

# 🛒 AppMarket Mobile

### سوق المشاريع الرقمية — اشتري وبيع المشاريع الجاهزة

[![Flutter](https://img.shields.io/badge/Flutter-3.0%2B-02569B?logo=flutter)](https://flutter.dev)
[![FastAPI](https://img.shields.io/badge/Backend-FastAPI-009688?logo=fastapi)](https://fastapi.tiangolo.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod-purple)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-MIT-green)](LICENSE)
[![Platform](https://img.shields.io/badge/Platform-Android%20%7C%20iOS%20%7C%20Web-blue)](https://flutter.dev)
[![Analyze](https://img.shields.io/badge/flutter%20analyze-No%20issues%20found-brightgreen)](https://flutter.dev/docs/testing/debugging)

</div>

---

## 📖 نظرة عامة

**AppMarket Mobile** تطبيق سوق رقمي متكامل مبني بـ Flutter يتيح للمستخدمين شراء وبيع المشاريع الجاهزة، نشر أفكار الشركات الناشئة، التواصل مع المطورين، وإدارة المعاملات بأمان — كل ذلك من تجربة موحدة وأنيقة.

---

## ✨ المميزات

### 🔐 المصادقة والأمان
- تسجيل الدخول والتسجيل بالبريد وكلمة المرور
- تخزين آمن للـ token مع إدارة الجلسات
- شاشة Splash مع تسجيل دخول تلقائي

### 🛍️ السوق (Marketplace)
- تصفح المشاريع الرقمية الجاهزة للبيع
- صفحة تفاصيل المشروع مع الوصف والتقييمات
- إنشاء ونشر قوائم المشاريع الخاصة بك
- بحث متقدم وفلترة حسب الفئة والسعر

### 💡 مركز الأفكار (Ideas Hub)
- نشر أفكار الشركات الناشئة
- تصفح أفكار المجتمع وتقديم مقترحات
- عرض تفاصيل الأفكار مع إدارة المقترحات

### 💬 الدردشة الفورية
- رسائل فورية مدعومة بـ WebSocket
- قائمة المحادثات مع سجل الرسائل
- شاشات دردشة منفصلة لكل محادثة

### 💳 المدفوعات والـ Escrow
- نظام **Escrow** آمن — الأموال محتجزة حتى تأكيد التسليم
- تتبع المعاملات وسجل المدفوعات
- حل النزاعات المدمج للصفقات الفاشلة

### ⚖️ إدارة النزاعات
- فتح وتتبع النزاعات على المعاملات
- تدخل المشرف لحل النزاعات
- تحديثات الحالة والإشعارات

### 📊 لوحة التحكم الشخصية
- بطاقات إجراءات سريعة
- نظرة عامة على رصيد Escrow والمعاملات النشطة
- ملخص النزاعات ومؤشرات الحالة

### 👤 الملف الشخصي
- إدارة كاملة لملف المستخدم
- رفع الصورة الشخصية وتعديل البيانات
- تحقق KYC (اعرف عميلك)

### 🔔 الإشعارات
- مركز إشعارات داخل التطبيق
- عداد الإشعارات في التنقل السفلي

### 🔍 البحث
- بحث نصي شامل في المشاريع والأفكار
- نتائج فورية مع Debounce

### 🛠️ لوحة الإدارة (Admin)
- إحصائيات المنصة
- إدارة المستخدمين (عرض، حظر، رفع الحظر)
- مراجعة وقبول طلبات KYC
- واجهة حل النزاعات

### 📱 دعم المنصات
- **Android** (API 21+)
- **iOS** (iOS 12+)
- **Web** (PWA)
- **Windows** Desktop

---

## 🧰 التقنيات المستخدمة

| الطبقة | التقنية |
|--------|---------|
| **Frontend** | Flutter 3.0+ (Dart) |
| **Backend** | FastAPI (Python) |
| **قاعدة البيانات** | PostgreSQL (إنتاج) / SQLite (تطوير) |
| **إدارة الحالة** | Riverpod 2 |
| **التنقل** | GoRouter 13 |
| **HTTP Client** | Dio 5 |
| **Real-time** | WebSocket (web_socket_channel) |
| **المصادقة** | JWT Tokens |
| **التخزين المحلي** | SharedPreferences + flutter_secure_storage |
| **الخطوط** | Google Fonts (Poppins) |
| **الصور** | CachedNetworkImage + ImagePicker |

---

## 🚀 البدء السريع

### المتطلبات
- Flutter SDK `>= 3.0.0`
- Dart SDK `>= 3.0.0`
- Backend يعمل على `http://localhost:8000`

### تثبيت الاعتماديات
```bash
flutter pub get
```

### تشغيل التطبيق
```bash
# Web (Chrome)
flutter run -d chrome

# Android
flutter run

# iOS
flutter run -d ios

# Windows
flutter run -d windows
```

### إعداد الـ API
عدّل `lib/core/services/api_service.dart`:

```dart
// Web / iOS Simulator
const String baseUrl = 'http://localhost:8000/api/v1';

// Android Emulator
const String baseUrl = 'http://10.0.2.2:8000/api/v1';

// جهاز حقيقي (ضع IP جهازك)
const String baseUrl = 'http://192.168.x.x:8000/api/v1';
```

---

## 📁 هيكل المشروع

```
lib/
├── main.dart
├── core/
│   ├── constants/        # ثوابت التطبيق
│   ├── router/           # GoRouter والمسارات
│   ├── services/
│   │   └── api_service.dart   # Dio HTTP client
│   ├── theme/            # الثيم والألوان
│   ├── utils/            # دوال مساعدة
│   └── widgets/          # مكونات قابلة لإعادة الاستخدام
└── features/
    ├── admin/            # لوحة الإدارة
    ├── auth/             # تسجيل الدخول والتسجيل
    ├── chat/             # الدردشة الفورية
    ├── dashboard/        # لوحة التحكم الشخصية
    ├── disputes/         # إدارة النزاعات
    ├── home/             # الشاشة الرئيسية والتنقل
    ├── ideas/            # مركز الأفكار
    ├── kyc/              # التحقق من الهوية
    ├── marketplace/      # السوق والقوائم
    ├── notifications/    # مركز الإشعارات
    ├── profile/          # الملف الشخصي
    └── search/           # البحث الشامل
```

---

## 🔑 بيانات الدخول الافتراضية

> ⚠️ **غيّر هذه البيانات قبل النشر في الإنتاج.**

```
البريد الإلكتروني: admin@appmarket.com
كلمة المرور:       admin123
```

---

## 📦 الاعتماديات الرئيسية

```yaml
dio: ^5.4.0
flutter_riverpod: ^2.4.10
go_router: ^13.0.0
shared_preferences: ^2.2.2
flutter_secure_storage: ^9.0.0
google_fonts: ^6.2.1
image_picker: ^1.0.7
file_picker: ^6.1.1
web_socket_channel: ^2.4.0
cached_network_image: ^3.3.1
flutter_rating_bar: ^4.0.1
shimmer: ^3.0.0
intl: ^0.19.0
url_launcher: ^6.2.5
```

---

## 🤝 المساهمة

1. Fork المستودع
2. أنشئ فرع جديد: `git checkout -b feature/amazing-feature`
3. Commit التغييرات: `git commit -m 'Add amazing feature'`
4. Push للفرع: `git push origin feature/amazing-feature`
5. افتح Pull Request

---

## 📄 الرخصة

هذا المشروع مرخص تحت **MIT License** — راجع ملف [LICENSE](LICENSE) للتفاصيل.

---

<div align="center">
  مبني بـ ❤️ باستخدام Flutter
</div>
