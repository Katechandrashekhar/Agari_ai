@echo off
echo 🌾 Building AgriAI APK with TensorFlow Lite support...

echo 🧹 Cleaning previous builds...
flutter clean
flutter pub get

echo 📱 Building release APK with proper TensorFlow Lite configuration...
flutter build apk --release --no-tree-shake-icons

if %ERRORLEVEL% EQU 0 (
    echo ✅ APK built successfully!
    echo 📱 APK Location: build\app\outputs\flutter-apk\app-release.apk
    echo 📤 Ready to share!
    
    echo.
    echo 🔗 Your AgriAI app is ready for distribution!
    echo File size: 
    for %%I in (build\app\outputs\flutter-apk\app-release.apk) do echo %%~zI bytes
    
    echo.
    echo 📋 Sharing Options:
    echo 1. Upload to Google Drive
    echo 2. Share via WhatsApp/Email
    echo 3. Upload to GitHub Releases
    echo 4. Copy to USB drive
    
    explorer build\app\outputs\flutter-apk\
) else (
    echo ❌ Build failed! Check the error messages above.
    echo 🔧 Try running: flutter clean && flutter pub get
)

pause