import 'dart:io';

/// Service to check network connectivity
class ConnectivityService {
  
  /// Check if device has internet connectivity
  static Future<bool> hasInternetConnection() async {
    try {
      // Try to reach Google DNS - it's reliable and fast
      final result = await InternetAddress.lookup('google.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  /// Check if Firebase services are reachable
  static Future<bool> canReachFirebase() async {
    try {
      // Try to reach Firebase Auth
      final result = await InternetAddress.lookup('firebase.googleapis.com')
          .timeout(const Duration(seconds: 5));
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException catch (_) {
      return false;
    } catch (_) {
      return false;
    }
  }
  
  /// Get network status message
  static Future<String> getNetworkStatus() async {
    final hasInternet = await hasInternetConnection();
    if (!hasInternet) {
      return 'No internet connection detected. Please check your network settings.';
    }
    
    final canReachFirebase = await ConnectivityService.canReachFirebase();
    if (!canReachFirebase) {
      return 'Internet connected but cannot reach Firebase services. Please try again.';
    }
    
    return 'Network connection is good.';
  }
}