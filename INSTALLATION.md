# دليل التثبيت والإعداد

## المتطلبات

- Flutter 3.5.0+
- Dart 3.5.0+
- Android SDK

## خطوات الإعداد

### 1. تثبيت المكتبات

```bash
flutter pub get
```

### 2. توليد الملفات المولدة

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

### 3. التشغيل

```bash
flutter run
```

## البناء للإنتاج

### بناء APK

```bash
flutter build apk --release
```

### بناء AAB

```bash
flutter build appbundle --release
```

## الملفات المهمة

- `lib/main.dart` - نقطة الدخول
- `lib/models/` - نماذج البيانات
- `lib/screens/` - الشاشات الرئيسية
- `lib/services/` - خدمات قاعدة البيانات
- `lib/providers/` - إدارة الحالة
- `pubspec.yaml` - المكتبات والإعدادات

## استكشاف الأخطاء

إذا واجهت مشاكل:

```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```
