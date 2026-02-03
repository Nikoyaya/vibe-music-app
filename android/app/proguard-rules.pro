# Flutter 应用的 ProGuard 规则

# 保留 Flutter 包装器类
-keep class io.flutter.app.** {
    *;
}
-keep class io.flutter.plugin.**  {
    *;
}
-keep class io.flutter.util.**  {
    *;
}
-keep class io.flutter.view.**  {
    *;
}
-keep class io.flutter.**  {
    *;
}
-keep class io.flutter.plugins.**  {
    *;
}

# 保留基本类型的包装类
-keep class java.lang.Integer {
    *;
}
-keep class java.lang.Long {
    *;
}
-keep class java.lang.Float {
    *;
}
-keep class java.lang.Double {
    *;
}
-keep class java.lang.Boolean {
    *;
}
-keep class java.lang.String {
    *;
}

# 保留 Android 基本组件
-keep public class * extends android.app.Activity
-keep public class * extends android.app.Application
-keep public class * extends android.app.Service
-keep public class * extends android.content.BroadcastReceiver
-keep public class * extends android.content.ContentProvider

# 保留构造函数
-keepclasseswithmembers class * {
    public <init>(android.content.Context, android.util.AttributeSet);
}

# 保留带有回调的类
-keepclasseswithmembers class * {
    public void *(android.view.View);
}

# 保留枚举类
-keepclassmembers enum * {
    public static **[] values();
    public static ** valueOf(java.lang.String);
}

# 保留 Parcelable 实现
-keepclassmembers class * implements android.os.Parcelable {
    public static final android.os.Parcelable$Creator CREATOR;
}

# 保留 Serializable 实现
-keepclassmembers class * implements java.io.Serializable {
    private static final java.io.ObjectStreamField[] serialPersistentFields;
    private void writeObject(java.io.ObjectOutputStream);
    private void readObject(java.io.ObjectInputStream);
    java.lang.Object writeReplace();
    java.lang.Object readResolve();
}

# 保留 Just Audio 相关类
-keep class com.google.android.exoplayer2.** {
    *;
}
-keep class com.ryanheise.** {
    *;
}

# 保留 Dio 网络库相关类
-keep class com.dio.** {
    *;
}

# 保留 Provider 状态管理相关类
-keep class com.provider.** {
    *;
}

# 保留 Cached Network Image 相关类
-keep class com.cachednetworkimage.** {
    *;
}

# 保留 Image Picker 相关类
-keep class com.imagepicker.** {
    *;
}

# 保留 Carousel Slider 相关类
-keep class com.carouselslider.** {
    *;
}

# 保留 Flutter Dotenv 相关类
-keep class com.flutterdotenv.** {
    *;
}

# 保留 Freezed 相关类
-keep class com.freezed.** {
    *;
}

# 保留 Logger 相关类
-keep class com.logger.** {
    *;
}

# 保留 Audio Session 相关类
-keep class com.audiosession.** {
    *;
}

# 保留 Flutter Native Splash 相关类
-keep class com.flutternativesplash.** {
    *;
}

# 保留 Google Play Core 相关类
-dontwarn com.google.android.play.core.**
-keep class com.google.android.play.core.** { *; }
