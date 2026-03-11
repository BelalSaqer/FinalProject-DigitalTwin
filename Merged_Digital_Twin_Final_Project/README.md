# Merged Digital Twin + Final Project

تم دمج واجهة `Final_Project` مع مسار البيانات الحي الموجود في مشروع `digital_twin_app` بحيث يصبح التدفق كالتالي:

`publisher_engine1.py` → `MQTT` → `Flutter App` → `FastAPI /predict` → `RUL Prediction`

## ما الذي تم دمجه؟

- نقل منطق الاشتراك في **MQTT** إلى `AppState` داخل مشروع Flutter النهائي.
- إضافة **sliding window** بحجم 30 رسالة قبل إرسالها إلى الـ backend.
- ربط شاشة **Machines** و **Dashboard** بالبيانات الحية بدل الاعتماد فقط على بيانات ثابتة.
- إصلاح الـ backend ليستخدم الملف الموجود فعليًا `calibrated_model.tflite` بدل `calibrated_model.keras`.
- تحديث الـ publisher لإرسال `engine_id` و `cycle` مع الرسائل لعرضها داخل الواجهة.
- إصلاح الرسوم البيانية لتتحدث مع الـ live data (`shouldRepaint`).

## الملفات المهمة

### Flutter
- `lib/app/state.dart`
- `lib/screens/machines_screen.dart`
- `lib/screens/dashboard_screen.dart`
- `lib/widgets/charts.dart`
- `lib/config/live_pipeline_config.dart`
- `lib/models/telemetry_sample.dart`
- `lib/data/machine_catalog.dart`

### Python / MQTT pipeline
- `backend/main.py`
- `backend/calibrated_model.tflite`
- `publisher_engine1.py`
- `test_FD004.txt`
- `python_requirements.txt`

## تشغيل الـ backend والـ publisher

```bash
pip install -r python_requirements.txt
python backend/main.py
```

في Terminal آخر:

```bash
python publisher_engine1.py
```

## تشغيل Flutter

نزّل dependencies أولًا:

```bash
flutter pub get
```

ثم شغّل التطبيق مع تحديد رابط الـ backend.

### Android Emulator
```bash
flutter run --dart-define=BACKEND_URL=http://10.0.2.2:8000/predict
```

### جهاز موبايل على نفس الشبكة
استبدل الـ IP بعنوان جهاز الكمبيوتر الذي يعمل عليه الـ backend:

```bash
flutter run --dart-define=BACKEND_URL=http://192.168.X.X:8000/predict
```

### تخصيص MQTT إذا احتجت
يمكنك أيضًا تغيير الـ broker أو الـ topic من خلال `dart-define`:

```bash
flutter run \
  --dart-define=BACKEND_URL=http://192.168.X.X:8000/predict \
  --dart-define=MQTT_BROKER=broker.hivemq.com \
  --dart-define=MQTT_PORT=1883 \
  --dart-define=MQTT_TOPIC=ahmed/elhadyy/engine1
```

## ملاحظات مهمة

- الآلة الحية داخل التطبيق اسمها **Engine 1 Digital Twin**.
- لو الـ MQTT اشتغل والـ backend لم يشتغل، ستظهر الرسائل الحية لكن قيمة `RUL` لن تتحدث.
- لو أردت ربط أكثر من Engine أو أكثر من Topic، فأسهل خطوة تالية هي توسيع `AppState` ليحتفظ بأكثر من pipeline بدل Pipeline واحد فقط.
