# دليل إعداد وتشغيل تطبيق الفواتير

## المتطلبات الأساسية

### 1. تثبيت Flutter

```bash
# تحميل Flutter SDK
wget https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_3.24.0-stable.tar.xz
tar xf flutter_linux_3.24.0-stable.tar.xz
export PATH=$PATH:$(pwd)/flutter/bin
```

### 2. التحقق من التثبيت

```bash
flutter --version
dart --version
```

## خطوات الإعداد

### 1. الانتقال إلى مجلد المشروع

```bash
cd invoice_app_flutter
```

### 2. تثبيت المكتبات

```bash
flutter pub get
```

### 3. توليد ملفات JSON Serializable

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

## التشغيل

### تشغيل على جهاز أو محاكي

```bash
flutter run
```

### تشغيل في وضع الإصدار

```bash
flutter run --release
```

## البناء للإنتاج

### بناء APK (ملف التثبيت)

```bash
flutter build apk --release
```

الملف الناتج:
```
build/app/outputs/flutter-apk/app-release.apk
```

### بناء AAB (Android App Bundle)

```bash
flutter build appbundle --release
```

الملف الناتج:
```
build/app/outputs/bundle/release/app-release.aab
```

## هيكل المشروع

```
invoice_app_flutter/
├── lib/
│   ├── main.dart                    # نقطة الدخول
│   ├── models/                      # نماذج البيانات
│   │   ├── invoice.dart
│   │   ├── invoice.g.dart
│   │   ├── invoice_item.dart
│   │   └── invoice_item.g.dart
│   ├── screens/                     # الشاشات الرئيسية
│   │   ├── create_invoice_screen.dart
│   │   ├── invoice_summary_screen.dart
│   │   ├── saved_invoices_screen.dart
│   │   └── invoice_detail_screen.dart
│   ├── services/                    # الخدمات
│   │   └── database_service.dart
│   ├── providers/                   # إدارة الحالة
│   │   └── invoice_provider.dart
│   └── widgets/                     # المكونات المساعدة
│       ├── invoice_item_row.dart
│       └── keyboard_section.dart
├── assets/                          # الأصول
│   ├── images/
│   ├── icons/
│   └── fonts/
├── pubspec.yaml                     # ملف المكتبات
└── README.md                        # التوثيق
```

## المميزات الرئيسية

### 1. إنشاء الفاتورة
- إضافة أصناف متعددة
- حقول الكمية والسعر
- حساب فوري للإجمالي
- لوحة مفاتيح مخصصة

### 2. ملخص الفاتورة
- عرض تفصيلي للأصناف
- إدخال المصروفات المختلفة
- حساب التسويق (40%)
- عرض الصافي النهائي
- حفظ الفاتورة

### 3. الفواتير المحفوظة
- عرض جميع الفواتير
- معلومات سريعة
- عرض التفاصيل الكاملة
- حذف الفواتير

## قاعدة البيانات

### SQLite (التخزين المحلي)
- جميع الفواتير تُحفظ محلياً
- لا حاجة للاتصال بالإنترنت
- سرعة عالية في الوصول

### Hive (التخزين السريع)
- تخزين البيانات المؤقتة
- أداء عالي جداً

### Firebase (جاهز للمزامنة)
- يمكن إضافة المزامنة السحابية
- النسخ الاحتياطية التلقائية

## استكشاف الأخطاء

### المشكلة: flutter: command not found

**الحل:**
```bash
export PATH=$PATH:~/flutter/bin
```

### المشكلة: أخطاء في البناء

**الحل:**
```bash
flutter clean
flutter pub get
flutter pub run build_runner build --delete-conflicting-outputs
```

### المشكلة: مشاكل في قاعدة البيانات

**الحل:**
```bash
# حذف قاعدة البيانات القديمة
rm -rf ~/.local/share/invoice_app/
```

## نصائح مهمة

1. **تحديث المكتبات**: استخدم `flutter pub upgrade` بحذر
2. **الاختبار**: اختبر التطبيق على أجهزة مختلفة
3. **الأداء**: استخدم `--release` للبناء النهائي
4. **الأمان**: لا تشارك مفاتيح Firebase العامة

## الدعم والمساعدة

- توثيق Flutter: https://flutter.dev/docs
- مجتمع Flutter: https://flutter.dev/community
- Stack Overflow: https://stackoverflow.com/questions/tagged/flutter

---

**آخر تحديث:** مارس 2026
**الإصدار:** 1.0.0
