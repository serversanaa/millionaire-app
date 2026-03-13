# ═══════════════════════════════════════════════════════════════
# image_gallery_saver_plus
# ═══════════════════════════════════════════════════════════════

-keep class io.github.mrjoechen.image_gallery_saver_plus.** { *; }
-dontwarn io.github.mrjoechen.image_gallery_saver_plus.**

# ═══════════════════════════════════════════════════════════════
# MediaStore & File Operations
# ═══════════════════════════════════════════════════════════════

-keep class android.provider.MediaStore { *; }
-keep class android.content.ContentResolver { *; }
-keep class android.content.ContentValues { *; }
-keep class java.io.File { *; }
-keep class java.nio.file.Files { *; }

# ═══════════════════════════════════════════════════════════════
# permission_handler
# ═══════════════════════════════════════════════════════════════

-keep class com.baseflow.permissionhandler.** { *; }
-dontwarn com.baseflow.permissionhandler.**

# ═══════════════════════════════════════════════════════════════
# device_info_plus
# ═══════════════════════════════════════════════════════════════

-keep class dev.fluttercommunity.plus.device_info.** { *; }
-dontwarn dev.fluttercommunity.plus.device_info.**

# ═══════════════════════════════════════════════════════════════
# Flutter Core (مهم!)
# ═══════════════════════════════════════════════════════════════

-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
-dontwarn io.flutter.**

# ═══════════════════════════════════════════════════════════════
# Attributes
# ═══════════════════════════════════════════════════════════════

-keepattributes *Annotation*
-keepattributes Signature
-keepattributes Exception
-keepattributes InnerClasses
-keepattributes EnclosingMethod
