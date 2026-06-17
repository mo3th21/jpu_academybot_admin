# ملخص مشروع JPU AcademyBot Admin

## 📋 نظرة عامة على المشروع

**JPU AcademyBot Admin** هو تطبيق جوال متعدد المنصات مبني بتقنية **Flutter** مخصص لإدارة وتسيير محتوى أكاديمي والأخبار والعمليات الإدارية في جامعة الأميرة جولانة الإسلامية (JPU).

---

## 🎯 الهدف الرئيسي

توفير لوحة تحكم إدارية سهلة الاستخدام لـ:

- إدارة الأخبار والإعلانات الأكاديمية
- إدارة المحتوى الأكاديمي والمواد الدراسية
- التحقق من المستخدمين والإدارة الأمنية
- تخزين واسترجاع الملفات بسهولة

---

## 🛠️ التقنيات المستخدمة

### الإطار الأساسي

- **Flutter**: للتطوير متعدد المنصات (iOS, Android, Web, Windows, Linux, macOS)
- **Dart**: لغة البرمجة
- **SDK**: Dart 3.9.2+

### خدمات الواجهة الخلفية

- **Firebase Core**: ^2.32.0
- **Firebase Authentication**: ^4.20.0
- **Cloud Firestore**: ^4.17.5
- **Firebase Storage**: ^11.7.7

### المكتبات الإضافية

- **HTTP**: للاتصالات الشبكية
- **Image Picker**: لاختيار الصور
- **File Selector**: لاختيار الملفات
- **URL Launcher**: لفتح الروابط
- **Google Fonts**: لخطوط قوقل
- **Cupertino Icons**: رموز iOS

---

## 📁 هيكل المشروع

```
jpu_academybot_admin/
├── lib/
│   ├── main.dart                    # نقطة الدخول الرئيسية
│   ├── login.dart                   # صفحة تسجيل الدخول
│   ├── register.dart                # صفحة التسجيل الجديد
│   ├── home.dart                    # الصفحة الرئيسية
│   ├── news_management.dart         # إدارة الأخبار
│   ├── academic_management.dart     # إدارة المحتوى الأكاديمي
│   │
│   ├── models/                      # النماذج البيانية
│   │   ├── admin.dart              # نموذج المسؤول
│   │   ├── news.dart               # نموذج الخبر
│   │   ├── academic_content.dart   # نموذج المحتوى الأكاديمي
│   │   └── firebase_options.dart   # إعدادات Firebase
│   │
│   ├── services/                    # خدمات الواجهة الخلفية
│   │   ├── news_service.dart       # خدمة إدارة الأخبار
│   │   └── academic_content_service.dart  # خدمة المحتوى الأكاديمي
│   │
│   ├── widgets/                     # المكونات المرئية
│   │   ├── news/                    # مكونات الأخبار
│   │   ├── academic/                # مكونات المحتوى الأكاديمي
│   │   └── home/                    # مكونات الصفحة الرئيسية
│   │
│   ├── theme/
│   │   └── app_theme.dart          # موضوع التطبيق
│   │
│   └── utils/
│       └── firebase_utils.dart      # أدوات Firebase
│
├── android/                         # كود Android الأصلي
├── ios/                            # كود iOS الأصلي
├── web/                            # كود الويب
├── windows/                        # كود Windows
├── linux/                          # كود Linux
├── macos/                          # كود macOS
│
├── pubspec.yaml                    # ملف المتطلبات والإعدادات
├── analysis_options.yaml           # إعدادات تحليل الكود
├── firebase.json                   # إعدادات Firebase
└── README.md                       # التوثيق
```

---

## 🎨 المكونات الرئيسية

### 1. **صفحة تسجيل الدخول (Login Page)**

- تسجيل دخول آمن باستخدام Firebase Authentication
- التحقق من بيانات المسؤول
- إعادة التوجيه للصفحة الرئيسية عند النجاح

### 2. **صفحة التسجيل (Register Page)**

- إنشاء حساب جديد للمسؤولين
- التحقق من البيانات المدخلة
- حفظ البيانات في Firestore

### 3. **الصفحة الرئيسية (Home Page)**

- لوحة التحكم الرئيسية
- قوائم التنقل بين أقسام التطبيق
- عرض الملخصات والإحصائيات

### 4. **إدارة الأخبار (News Management)**

- إضافة أخبار جديدة بعنوان ونص وصورة
- تحرير الأخبار الموجودة
- حذف الأخبار
- عرض قائمة الأخبار
- رفع الصور إلى Firebase Storage

### 5. **إدارة المحتوى الأكاديمي (Academic Management)**

- رفع ملفات دراسية (PDF، صور، إلخ)
- تصنيف المحتوى حسب المادة والتخصص
- تحميل الملفات
- تحرير وحذف المحتوى
- دعم اللغة العربية (RTL)

---

## 📊 النماذج البيانية

### نموذج المسؤول (Admin)

```dart
Admin {
  String adminId,           // معرّف المسؤول الفريد
  String displayName,       // اسم العرض
  String email,            // البريد الإلكتروني
  Timestamp createdAt,     // تاريخ الإنشاء
  Timestamp? lastLoginAt   // آخر تسجيل دخول
}
```

### نموذج الخبر (News)

```dart
News {
  String newsId,           // معرّف الخبر
  String adminId,          // معرّف المسؤول المنشئ
  String title,            // العنوان
  String text,             // المحتوى
  String? imageUrl,        // رابط الصورة
  DateTime timestamp       // تاريخ النشر
}
```

### نموذج المحتوى الأكاديمي (AcademicContent)

```dart
AcademicContent {
  String contractId,       // معرّف المستند
  String adminId,          // معرّف المسؤول
  String downloadUrl,      // رابط التحميل
  String filename,         // اسم الملف
  Timestamp uploadedAt,    // تاريخ الرفع
  String subject,          // المادة الدراسية
  String major,            // التخصص
  String? description      // الوصف
}
```

---

## 🔌 الخدمات والتوابع

### خدمة الأخبار (NewsService)

- إنشاء أخبار جديدة
- استرجاع الأخبار من Firestore
- تحديث الأخبار
- حذف الأخبار

### خدمة المحتوى الأكاديمي (AcademicContentService)

- رفع الملفات إلى Firebase Storage
- حفظ معلومات الملف في Firestore
- استرجاع قائمة المحتوى
- تحديث معلومات المحتوى
- حذف المحتوى

### أدوات Firebase (FirebaseUtils)

- تهيئة Firebase
- عمليات المصادقة
- معالجة الأخطاء

---

## ✨ الميزات الرئيسية

✅ **مصادقة آمنة**: استخدام Firebase Authentication  
✅ **قاعدة بيانات سحابية**: Cloud Firestore للتخزين  
✅ **تخزين الملفات**: Firebase Storage لرفع الصور والملفات  
✅ **واجهة سهلة الاستخدام**: تصميم مشروع Material Design  
✅ **دعم اللغة العربية**: RTL Text Direction  
✅ **متعدد المنصات**: يعمل على جميع المنصات (iOS, Android, Web, إلخ)  
✅ **إدارة الملفات**: اختيار ورفع الملفات بسهولة  
✅ **رابط تحميل آمن**: استخدام URL Launcher لفتح الروابط

---

## 🗺️ المسارات الرئيسية (Routes)

```
/ (root)           → AdminLoginPage       (صفحة تسجيل الدخول)
/register          → RegisterPage          (صفحة التسجيل)
/home              → HomePage              (الصفحة الرئيسية)
/news              → NewsManagementPage    (إدارة الأخبار)
/academic          → AcademicManagementPage (إدارة المحتوى الأكاديمي)
```

---

## 📝 ملفات الإعدادات والتوثيق

- **pubspec.yaml**: ملف المتطلبات والإعدادات
- **analysis_options.yaml**: قواعد تحليل الكود
- **firebase.json**: إعدادات Firebase
- **CORS_FIX_GUIDE.md**: دليل إصلاح مشاكل CORS
- **FIREBASE_STORAGE_FIX.md**: دليل إصلاح مشاكل Firebase Storage
- **NEWS_MANAGEMENT_SUMMARY.md**: ملخص نظام إدارة الأخبار
- **QUICK_START_NEWS.md**: دليل البدء السريع للأخبار

---

## 🔧 المهام المنجزة

- [x] استخراج منطق رفع الملفات المشترك إلى دالة منفصلة
- [x] استبدال PopupMenuButton بصفوف من أزرار الرموز
- [x] تحديث نوافذ الحوار لاستخدام الدوال المشتركة
- [x] إضافة دعم اتجاه النص RTL للغة العربية
- [x] اختبار الكود المعاد تنظيمه

---

## 📱 المنصات المدعومة

- 📲 **iOS** - بواسطة Swift
- 🤖 **Android** - بواسطة Kotlin/Java
- 🌐 **Web** - بواسطة HTML/CSS/JavaScript
- 💻 **Windows** - بواسطة C++
- 🐧 **Linux** - بواسطة C++
- 🍎 **macOS** - بواسطة Swift

---

## 🚀 خطوات البدء

1. **التثبيت**:

   ```bash
   flutter pub get
   ```

2. **تشغيل التطبيق**:

   ```bash
   flutter run
   ```

3. **البناء**:
   - Android: `flutter build apk`
   - iOS: `flutter build ios`
   - Web: `flutter build web`

---

## 📞 الملاحظات والتحسينات المستقبلية

- تحسين واجهة المستخدم بإضافة المزيد من التفاعلات البصرية
- إضافة نظام إشعارات فوري
- تحسين الأداء في عمليات البحث والتصفية
- إضافة نظام الأدوار والصلاحيات المتقدم
- تحسين معالجة الأخطاء والرسائل التوضيحية

---

**آخر تحديث**: 17 يونيو 2026  
**الإصدار**: 1.0.0  
**حالة المشروع**: قيد التطوير والتحسين المستمر
