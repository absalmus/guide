# دليل الكنيسة الذكي | Smart Church Guide

منصة Flutter ذكية للعثور على الكنائس القبطية، مواعيد القداسات والاجتماعات، حجز الفعاليات، والأديرة — مع دعم كامل للعربية RTL.

## الميزات

- شاشة بداية مع أنيميشن
- تسجيل دخول (بريد، Google، هاتف)
- استكمال الملف الشخصي مع الفئات العمرية
- الصفحة الرئيسية مع أقرب الكنائس والقداسات والاجتماعات
- استكشاف الكنائس مع فلترة حسب المحافظة
- خريطة Google Maps مع فلترة الإيبارشية
- تفاصيل الكنيسة (معلومات، مواعيد، اجتماعات، خدمات، معرض)
- نظام حجز (مؤتمر، رحلة، خلوة) مع QR Code
- الإشعارات
- المساعد الذكي AI
- قسم الأديرة
- الملف الشخصي مع Dark/Light Mode

## التشغيل

```bash
flutter pub get
flutter run
```

## الإعداد للإنتاج

### 1. Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

ثم فعّل في Firebase Console:
- Authentication (Email, Google, Phone)
- Cloud Firestore

### 2. Maps

- التطبيق يستخدم `flutter_map` مع OpenStreetMap، فلا يحتاج API Key من Google Maps.

### 3. Google Sign-In

أضف SHA-1 fingerprint في Firebase Console لمشروع Android.

## الوضع التجريبي

التطبيق يعمل في **وضع تجريبي** بدون إعداد Firebase:
- أي بريد/كلمة مرور للدخول
- رمز الهاتف: `123456`
- بيانات كنائس وأديرة تجريبية مدمجة

## هيكل المشروع

```
lib/
├── core/          # الثيم، التوجيه، الأدوات
├── data/          # البيانات التجريبية
├── models/        # نماذج البيانات
├── providers/     # إدارة الحالة
├── screens/       # الشاشات
├── services/      # Firebase، الموقع، AI
└── widgets/       # مكونات مشتركة
```

## التقنيات

- Flutter Material 3
- Provider + GoRouter
- Firebase Auth + Firestore
- Google Maps + Geolocator
- QR Flutter
- دعم RTL عربي كامل
