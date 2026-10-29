# 🌾 AgriAI - Smart Agriculture Mobile App

A comprehensive Flutter-based mobile application designed to revolutionize farming through AI-powered crop recommendations, disease detection, and smart agricultural insights.

## 📱 Features

### 🤖 AI-Powered Agriculture
- **Crop Recommendation System**: ML-based recommendations with 2200+ crop data records
- **Disease Detection**: TensorFlow Lite integration for real-time crop disease identification
- **Smart Analytics**: Data-driven insights for better farming decisions

### 🔐 Authentication & User Management
- Firebase Authentication integration
- Google Sign-In support
- Secure user profile management
- Multi-platform authentication

### 📸 Image Processing & Camera
- Real-time camera integration with CameraX
- Image capture for crop analysis
- Photo gallery integration
- Advanced image processing capabilities

### 🗣️ Voice & Speech Features
- Speech-to-Text functionality for hands-free interaction
- Text-to-Speech for accessibility
- Voice commands for app navigation

### 🌍 Location & Weather Services
- GPS-based location services
- Weather integration for farming insights
- Geotagging for crop data
- Location-based recommendations

### ☁️ Cloud Integration
- Firebase Firestore for real-time data sync
- Cloud Storage for images and documents
- Offline data synchronization
- Cross-device data access

## 🛠️ Technical Stack

### Frontend
- **Framework**: Flutter 3.38.1
- **Language**: Dart
- **UI**: Material Design components

### Backend & Services
- **Database**: Firebase Firestore
- **Authentication**: Firebase Auth
- **Storage**: Firebase Cloud Storage
- **Analytics**: Firebase Analytics

### AI & Machine Learning
- **ML Framework**: TensorFlow Lite
- **Model**: Custom crop disease detection model
- **Data**: 2200+ crop recommendation records

### Key Dependencies
```yaml
dependencies:
  flutter_tts: ^4.2.3          # Text-to-Speech
  speech_to_text: ^7.3.0       # Speech Recognition
  camera_android_camerax: ^0.6.21+1  # Camera Integration
  geolocator: ^12.0.0          # Location Services
  firebase_auth: ^5.7.0        # Authentication
  cloud_firestore: ^5.6.12     # Database
  firebase_storage: ^12.4.10   # File Storage
  image_picker: ^1.2.0         # Image Selection
  tflite_flutter: ^0.11.0      # AI/ML Models
  google_sign_in: ^6.3.0       # Google Authentication
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.38.1 or higher
- Dart SDK
- Android Studio / VS Code
- Android device or emulator
- Firebase project setup

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/Katechandrashekhar/AgriAi-App.git
   cd AgriAi-App
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project
   - Add your `google-services.json` to `android/app/`
   - Configure Firebase services (Auth, Firestore, Storage)

4. **Run the app**
   ```bash
   flutter run
   ```

## 📁 Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/                   # Data models
├── screens/                  # UI screens
├── services/                 # Business logic & APIs
├── widgets/                  # Reusable UI components
└── firebase_options.dart     # Firebase configuration

assets/
├── images/                   # App images & icons
├── models/                   # AI/ML model files
│   ├── crop_disease_model.tflite
│   └── crop_disease_labels.txt
└── fonts/                    # Custom fonts

android/                      # Android-specific files
ios/                         # iOS-specific files
web/                         # Web-specific files
```

## 🤖 AI Model Details

### Crop Disease Detection
- **Model Type**: TensorFlow Lite
- **Input**: Camera images of crops
- **Output**: Disease classification with confidence scores
- **Labels**: Multiple crop diseases supported

### Recommendation System
- **Dataset**: 2200+ crop records
- **Features**: Weather, soil, location-based recommendations
- **Algorithm**: Machine learning-based decision system

## 🔧 Build & Deployment

### Android Build
```bash
# Debug build
flutter build apk --debug

# Release build
flutter build apk --release
```

### Development Commands
```bash
# Clean build
flutter clean && flutter pub get

# Run with verbose logging
flutter run -v

# Hot reload
r (in running app)

# Hot restart
R (in running app)
```

## 🌟 Key Features Walkthrough

### 1. **Smart Crop Recommendations**
- Input soil type, weather conditions, and location
- Get AI-powered crop suggestions
- View detailed farming guidelines

### 2. **Disease Detection**
- Capture or select crop images
- Real-time AI analysis
- Get treatment recommendations

### 3. **Voice Interaction**
- Voice commands for navigation
- Speech-to-text for data input
- Audio feedback for accessibility

### 4. **Weather Integration**
- Location-based weather data
- Farming-specific weather insights
- Crop-weather correlation analysis

## 🐛 Troubleshooting

### Common Issues

**Build Errors:**
```bash
# Clean and rebuild
flutter clean
dart pub cache clean
flutter pub get
```

**Kotlin Compilation Issues:**
```bash
# Clean Gradle cache
cd android
./gradlew clean
cd ..
flutter clean && flutter pub get
```

**Firebase Connection:**
- Verify `google-services.json` is in correct location
- Check Firebase project configuration
- Ensure internet connectivity

## 📊 Performance

- **App Size**: ~45-50 MB (optimized)
- **Build Time**: 12-45 seconds depending on cache
- **Startup Time**: Fast with splash screen
- **Memory Usage**: Optimized for mobile devices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📱 Platform Support

- ✅ **Android**: Full support (Primary platform)
- ⚠️ **iOS**: Basic support (requires additional setup)
- ⚠️ **Web**: Limited support (some features may not work)

## 🔐 Privacy & Security

- Secure Firebase authentication
- Local data encryption
- GDPR compliant data handling
- User privacy protection

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase for backend services
- TensorFlow Lite for AI capabilities
- Open source community for various packages


---

**Made with ❤️ for farmers and agriculture communities**

*Empowering agriculture through AI and technology* 🌱
