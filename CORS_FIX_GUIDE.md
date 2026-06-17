# حل مشكلة CORS في Firebase Storage

## المشكلة
عند محاولة تحميل الصور من Firebase Storage على Web، يحدث خطأ CORS:
```
Failed to fetch, statusCode: 0
```

## الحل الأساسي: تحديث Firebase Storage Security Rules

### خطوات الحل:

1. **افتح Firebase Console**
   - اذهب إلى https://console.firebase.google.com
   - اختر مشروعك `jpuacademybot`

2. **اذهب إلى Storage → Rules**
   - من القائمة الجانبية، اضغط على **Storage**
   - اختر تبويب **Rules**

3. **استبدل القواعس بالتالي:**

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // السماح للجميع بقراءة الملفات العامة
    match /{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

4. **اضغط Publish** ✅

---

## الحل الإضافي: تفعيل CORS على Google Cloud

إذا استمرت المشكلة:

```bash
# تأكد من تسجيل الدخول
gcloud auth login

# اختر المشروع
gcloud config set project jpuacademybot

# طبّق CORS
gsutil cors set cors.json gs://jpuacademybot.firebasestorage.app

# تحقق من التطبيق
gsutil cors get gs://jpuacademybot.firebasestorage.app
```

---

## ملف cors.json
```json
[
  {
    "origin": ["*"],
    "method": ["GET", "HEAD", "DELETE"],
    "responseHeader": ["Content-Type"],
    "maxAgeSeconds": 3600
  }
]
```

---

## اختبار سريع

بعد تطبيق التغييرات:
1. أعد تشغيل التطبيق: `flutter run -d chrome`
2. الصور ستظهر بدون أخطاء ✅

---

## 🚀 الملاحظات المهمة

- **Security Rules** هي الحل الأساسي والأهم
- **CORS** يحتاج فقط إذا كانت الطلبات من نطاق مختلف
- تأكد من حفظ التغييرات بـ **Publish** في Firebase Console
