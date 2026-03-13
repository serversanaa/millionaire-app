# 🏗️ هيكل مشروع تطبيق مركز المليونير للحلاقة

## 📁 Clean Architecture Structure

```
millionaire_barber/
├── lib/
│   ├── main.dart                           # نقطة دخول التطبيق
│   │
│   ├── app/                                # إعدادات التطبيق العامة
│   │   ├── app.dart                        # التطبيق الرئيسي
│   │   ├── router.dart                     # نظام التنقل
│   │   └── themes/                         # الثيم والألوان
│   │       ├── app_colors.dart             # نظام الألوان المخصص
│   │       └── app_theme.dart              # إعدادات الثيم
│   │
│   ├── core/                               # الوحدات المشتركة
│   │   ├── constants/                      # الثوابت العامة
│   │   │   └── app_constants.dart
│   │   ├── utils/                          # الأدوات المساعدة
│   │   │   ├── responsive_helper.dart      # مساعد التصميم المتجاوب
│   │   │   ├── date_helper.dart
│   │   │   └── validation_helper.dart
│   │   ├── errors/                         # إدارة الأخطاء
│   │   │   ├── failures.dart
│   │   │   └── exceptions.dart
│   │   ├── network/                        # الشبكة
│   │   │   └── network_info.dart
│   │   └── services/                       # الخدمات العامة
│   │       ├── service_locator.dart        # حقن التبعيات
│   │       ├── storage_service.dart
│   │       └── notification_service.dart
│   │
│   ├── shared/                             # المكونات المشتركة
│   │   ├── widgets/                        # ويدجتات مشتركة
│   │   │   ├── responsive/                 # ويدجتات متجاوبة
│   │   │   │   ├── responsive_builder.dart
│   │   │   │   ├── responsive_grid.dart
│   │   │   │   └── responsive_text.dart
│   │   │   ├── custom_app_bar.dart
│   │   │   ├── custom_button.dart
│   │   │   ├── service_card.dart
│   │   │   └── loading_widget.dart
│   │   └── extensions/                     # امتدادات مفيدة
│   │       ├── context_extension.dart
│   │       └── string_extension.dart
│   │
│   └── features/                           # الميزات الأساسية
│       │
│       ├── authentication/                 # ميزة المصادقة
│       │   ├── data/
│       │   │   ├── models/
│       │   │   │   └── user_model.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository_impl.dart
│       │   │   └── datasources/
│       │   │       ├── auth_remote_datasource.dart
│       │   │       └── auth_local_datasource.dart
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   │   └── user.dart
│       │   │   ├── repositories/
│       │   │   │   └── auth_repository.dart
│       │   │   └── usecases/
│       │   │       ├── login_user.dart
│       │   │       └── register_user.dart
│       │   └── presentation/
│       │       ├── bloc/
│       │       │   ├── auth_bloc.dart
│       │       │   ├── auth_event.dart
│       │       │   └── auth_state.dart
│       │       ├── pages/
│       │       │   ├── login_page.dart
│       │       │   └── register_page.dart
│       │       └── widgets/
│       │           └── login_form.dart
│       │
│       ├── home/                           # الصفحة الرئيسية
│       │   ├── data/
│       │   │   ├── models/
│       │   │   ├── repositories/
│       │   │   └── datasources/
│       │   ├── domain/
│       │   │   ├── entities/
│       │   │   ├── repositories/
│       │   │   └── usecases/
│       │   └── presentation/
│       │       ├── bloc/
│       │       ├── pages/
│       │       └── widgets/
│       │
│       ├── services/                       # إدارة الخدمات
│       │   └── [بنفس الهيكل]
│       │
│       ├── booking/                        # نظام الحجز
│       │   └── [بنفس الهيكل]
│       │
│       ├── profile/                        # الملف الشخصي
│       │   └── [بنفس الهيكل]
│       │
│       ├── offers/                         # العروض والخصومات
│       │   └── [بنفس الهيكل]
│       │
│       └── contact/                        # التواصل والمعلومات
│           └── [بنفس الهيكل]
│
├── assets/                                 # الأصول والموارد
│   ├── images/                             # الصور
│   ├── icons/                              # الأيقونات
│   ├── fonts/                              # الخطوط
│   ├── translations/                       # ملفات الترجمة
│   └── animations/                         # الرسوم المتحركة
│
├── database/                               # قاعدة البيانات
│   └── schema.sql                          # مخطط PostgreSQL
│
├── docs/                                   # التوثيق
│   ├── project_structure.md
│   └── api_documentation.md
│
├── test/                                   # الاختبارات
│   ├── unit/                               # اختبار الوحدة
│   └── widget/                             # اختبار الويدجت
│
├── integration_test/                       # اختبار التكامل
│
├── pubspec.yaml                            # إعدادات المشروع
├── analysis_options.yaml                   # قواعد فحص الكود
├── l10n.yaml                              # إعدادات الترجمة
├── .gitignore                             # ملفات Git المتجاهلة
└── README.md                              # دليل المشروع
```

## 🎯 شرح الطبقات

### 📱 Presentation Layer
- **المسؤولية**: واجهة المستخدم وإدارة الحالة
- **المكونات**: BLoC, Pages, Widgets
- **التقنيات**: Flutter BLoC, Responsive Design

### 🏢 Domain Layer
- **المسؤولية**: منطق الأعمال والقواعد
- **المكونات**: Entities, Use Cases, Repository Interfaces
- **الخصائص**: مستقل عن المنصة ومصادر البيانات

### 🗄️ Data Layer
- **المسؤولية**: تنفيذ المستودعات وإدارة البيانات
- **المكونات**: Repository Implementations, Models, Data Sources
- **التقنيات**: Supabase, Hive, SharedPreferences

## ✅ المزايا

- **فصل الاهتمامات**: كل طبقة لها مسؤوليات محددة
- **قابلية الاختبار**: سهولة كتابة اختبارات الوحدة
- **المرونة**: سهولة التغيير والصيانة
- **إعادة الاستخدام**: مكونات قابلة للاستخدام في أجزاء مختلفة
