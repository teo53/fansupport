# Flutter Stripe SDK
-dontwarn com.stripe.android.pushProvisioning.**
-keep class com.stripe.android.pushProvisioning.** { *; }
-keep class com.reactnativestripesdk.** { *; }

# Keep Stripe classes
-keep class com.stripe.** { *; }
-dontwarn com.stripe.**

# General Flutter rules
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }
