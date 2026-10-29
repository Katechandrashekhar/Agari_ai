# Add project specific ProGuard rules here.
# You can control the set of applied configuration files using the
# proguardFiles setting in build.gradle.

# TensorFlow Lite rules to prevent R8 issues
-keep class org.tensorflow.lite.** { *; }
-keep class org.tensorflow.lite.gpu.** { *; }
-keep class org.tensorflow.lite.nnapi.** { *; }
-keep class org.tensorflow.lite.support.** { *; }

# Keep TensorFlow Lite GPU delegate
-keep class org.tensorflow.lite.gpu.GpuDelegate { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory { *; }
-keep class org.tensorflow.lite.gpu.GpuDelegateFactory$Options { *; }

# Keep all TensorFlow Lite classes from obfuscation
-dontwarn org.tensorflow.lite.**
-dontwarn org.tensorflow.lite.gpu.**
-dontwarn org.tensorflow.lite.nnapi.**
-dontwarn org.tensorflow.lite.support.**

# Firebase rules
-keep class com.google.firebase.** { *; }
-keep class com.google.android.gms.** { *; }

# Flutter rules
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }

# Camera and image processing
-keep class androidx.camera.** { *; }
-dontwarn androidx.camera.**

# Speech to text and TTS
-keep class com.csdcorp.speech_to_text.** { *; }
-keep class com.tundralabs.fluttertts.** { *; }

# Geolocator
-keep class com.baseflow.geolocator.** { *; }

# Image picker
-keep class io.flutter.plugins.imagepicker.** { *; }

# Google Sign In
-keep class com.google.android.gms.auth.** { *; }

# Google Play Core rules for split installs and dynamic delivery
-keep class com.google.android.play.core.** { *; }
-keep class com.google.android.play.core.splitcompat.** { *; }
-keep class com.google.android.play.core.splitinstall.** { *; }
-keep class com.google.android.play.core.tasks.** { *; }
-dontwarn com.google.android.play.core.**

# Flutter Play Store split application
-keep class io.flutter.embedding.android.FlutterPlayStoreSplitApplication { *; }
-keep class io.flutter.embedding.engine.deferredcomponents.** { *; }

# Additional Play Core classes
-keep class com.google.android.play.core.appupdate.** { *; }
-keep class com.google.android.play.core.review.** { *; }
-keep class com.google.android.play.core.common.** { *; }