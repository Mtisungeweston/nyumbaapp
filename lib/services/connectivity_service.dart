import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';
import 'dart:developer' as developer;

class ConnectivityService {
  static final ConnectivityService _instance = ConnectivityService._internal();

  factory ConnectivityService() {
    return _instance;
  }

  ConnectivityService._internal() {
    developer.log('[ConnectivityService] Initializing', name: 'ConnectivityService');
  }

  final Connectivity _connectivity = Connectivity();
  final StreamController<bool> _connectionController = StreamController<bool>.broadcast();
  StreamSubscription<List<ConnectivityResult>>? _subscription;
  bool _isConnected = true;

  bool get isConnected => _isConnected;

  Stream<bool> get connectionStatusStream => _connectionController.stream;

  void initialize() {
    developer.log('[ConnectivityService] Starting network monitoring', name: 'ConnectivityService');
    
    // Listen to connectivity changes - returns List<ConnectivityResult>
    _subscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) {
        final connected = !results.contains(ConnectivityResult.none);
        _isConnected = connected;
        _connectionController.add(connected);
        developer.log(
          '[ConnectivityService] Network status: $connected (results: $results)',
          name: 'ConnectivityService',
        );
      },
      onError: (error) {
        developer.log(
          '[ConnectivityService] Stream error: $error',
          name: 'ConnectivityService',
          error: error,
        );
      },
    );

    // Check initial connection status
    _checkInitialConnection();
  }

  Future<void> _checkInitialConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = !results.contains(ConnectivityResult.none);
      _isConnected = connected;
      _connectionController.add(connected);
      developer.log(
        '[ConnectivityService] Initial connection check: $connected (results: $results)',
        name: 'ConnectivityService',
      );
    } catch (e) {
      developer.log(
        '[ConnectivityService] Initial check error: $e',
        name: 'ConnectivityService',
        error: e,
      );
      _isConnected = false;
      _connectionController.add(false);
    }
  }

  Future<bool> hasNetworkConnection() async {
    try {
      final results = await _connectivity.checkConnectivity();
      final connected = !results.contains(ConnectivityResult.none);
      developer.log(
        '[ConnectivityService] Network check: $connected (results: $results)',
        name: 'ConnectivityService',
      );
      return connected;
    } catch (e) {
      developer.log(
        '[ConnectivityService] Network check error: $e',
        name: 'ConnectivityService',
        error: e,
      );
      return false;
    }
  }

  void dispose() {
    _subscription?.cancel();
    _connectionController.close();
  }
}
