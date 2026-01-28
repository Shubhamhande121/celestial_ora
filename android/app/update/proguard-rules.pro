# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# For more details, see:
#   http://developer.android.com/guide/developing/tools/proguard.html

# Flutter specific rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.**  { *; }
-keep class io.flutter.util.**  { *; }
-keep class io.flutter.view.**  { *; }
-keep class io.flutter.**  { *; }
-keep class io.flutter.plugins.**  { *; }
-keep class dev.flutter.**  { *; }

# Keep native methods
-keepclasseswithmembernames class * {
    native <methods>;
}

# Razorpay rules
-keep class com.razorpay.**  {*;}
-dontwarn com.razorpay.**
-keep class * extends com.google.gson.TypeAdapter
-keep class * implements org.json.JSONObject { *; }

# Gson rules
-keepattributes Signature
-keepattributes *Annotation*
-keep class sun.misc.Unsafe { *; }
-keep class com.google.gson.stream.** { *; }

# OkHttp rules
-keep class okhttp3.** { *; }
-keep interface okhttp3.** { *; }
-dontwarn okhttp3.**

# Retrofit rules
-dontwarn retrofit2.**
-keep class retrofit2.** { *; }
-keepattributes Signature
-keepattributes Exceptions

# AndroidX rules
-keep class androidx.** { *; }
-dontwarn androidx.**