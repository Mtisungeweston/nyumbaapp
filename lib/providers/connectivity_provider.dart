import 'package:flutter/foundation.dart';
import '../services/connectivity_service.dart';
import 'dart:developer' as developer;

class ConnectivityProvider extends ChangeNotifier {
  final ConnectivityService _connectivityService = ConnectivityService();
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  ConnectivityProvider() {
    developer.log('[ConnectivityProvider] Initializing', name: 'ConnectivityProvider');
    _initializeConnectivity();
  }

  void _initializeConnectivity() {
    _connectivityService.initialize();
    
    _connectivityService.connectionStatusStream.listen((isConnected) {
      if (_isConnected != isConnected) {
        _isConnected = isConnected;
        developer.log('[ConnectivityProvider] Network changed: $isConnected', name: 'ConnectivityProvider');
        notifyListeners();
      }
    });
  }

  Future<bool> checkConnection() async {
    return await _connectivityService.hasNetworkConnection();
  }

  @override
  void dispose() {
    _connectivityService.dispose();
    super.dispose();
  }
}
