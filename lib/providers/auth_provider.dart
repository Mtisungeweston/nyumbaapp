import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import 'dart:developer' as developer;

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _phoneNumber;
  bool _isLoading = false;
  String? _error;
  bool _otpSent = false;

  // Getters
  User? get user => _user;
  String? get phoneNumber => _phoneNumber;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _authService.isAuthenticated;
  bool get otpSent => _otpSent;

  AuthProvider() {
    developer.log('[AuthProvider] Initializing AuthProvider', name: 'AuthProvider');
    _authService.authStateChanges.listen((user) {
      _user = user;
      developer.log('[AuthProvider] Auth state changed, user: ${user?.phoneNumber}', name: 'AuthProvider');
      notifyListeners();
    });
  }

  // Request OTP
  Future<void> requestOTP(String phoneNumber) async {
    developer.log('[AuthProvider] Requesting OTP for: $phoneNumber', name: 'AuthProvider');
    _isLoading = true;
    _error = null;
    _phoneNumber = phoneNumber;
    notifyListeners();

    try {
      developer.log('[AuthProvider] Calling signUpWithPhone', name: 'AuthProvider');
      await _authService.signUpWithPhone(phoneNumber);
      developer.log('[AuthProvider] signUpWithPhone completed successfully', name: 'AuthProvider');
      _otpSent = true;
    } catch (e, stackTrace) {
      developer.log('[AuthProvider] Error requesting OTP: $e', name: 'AuthProvider', error: e, stackTrace: stackTrace);
      _error = e.toString();
      _otpSent = false;
    } finally {
      _isLoading = false;
      developer.log('[AuthProvider] OTP request finished, otpSent: $_otpSent', name: 'AuthProvider');
      notifyListeners();
    }
  }

  // Verify OTP
  Future<bool> verifyOTP(String otp) async {
    developer.log('[AuthProvider] Verifying OTP', name: 'AuthProvider');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.verifyOTP(otp);
      developer.log('[AuthProvider] OTP verified successfully', name: 'AuthProvider');
      return true;
    } catch (e, stackTrace) {
      developer.log('[AuthProvider] OTP verification failed: $e', name: 'AuthProvider', error: e, stackTrace: stackTrace);
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resend OTP
  Future<void> resendOTP() async {
    if (_phoneNumber == null) {
      developer.log('[AuthProvider] Cannot resend OTP: phone number not set', name: 'AuthProvider');
      _error = 'Phone number not set';
      notifyListeners();
      return;
    }

    developer.log('[AuthProvider] Resending OTP for: $_phoneNumber', name: 'AuthProvider');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _authService.resendOTP(_phoneNumber!);
      developer.log('[AuthProvider] OTP resent successfully', name: 'AuthProvider');
      _otpSent = true;
    } catch (e, stackTrace) {
      developer.log('[AuthProvider] OTP resend failed: $e', name: 'AuthProvider', error: e, stackTrace: stackTrace);
      _error = e.toString();
      _otpSent = false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Sign out
  Future<void> signOut() async {
    _isLoading = true;
    _error = null;
    _phoneNumber = null;
    _otpSent = false;
    notifyListeners();

    try {
      await _authService.signOut();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
