import 'package:firebase_auth/firebase_auth.dart';
import 'dart:async';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _firebaseAuth.currentUser;

  // Phone verification ID
  String? _verificationId;
  int? _resendToken;
  
  // Completer for handling async phone verification
  late Completer<void> _verificationCompleter;

  // Sign up with phone number
  Future<void> signUpWithPhone(String phoneNumber) async {
    try {
      developer.log('[AuthService] Starting phone verification for: $phoneNumber', name: 'AuthService');
      
      _verificationCompleter = Completer<void>();
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('[AuthService] Verification completed automatically', name: 'AuthService');
          try {
            await _firebaseAuth.signInWithCredential(credential);
            if (!_verificationCompleter.isCompleted) {
              _verificationCompleter.complete();
            }
          } catch (e) {
            if (!_verificationCompleter.isCompleted) {
              _verificationCompleter.completeError(e);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          developer.log('[AuthService] Verification failed: ${e.message}', name: 'AuthService', error: e);
          if (!_verificationCompleter.isCompleted) {
            _verificationCompleter.completeError(Exception('Phone verification failed: ${e.message}'));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          developer.log('[AuthService] Code sent successfully', name: 'AuthService');
          _verificationId = verificationId;
          _resendToken = resendToken;
          // Complete the completer - OTP screen will now show
          if (!_verificationCompleter.isCompleted) {
            _verificationCompleter.complete();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log('[AuthService] Code auto-retrieval timeout', name: 'AuthService');
          _verificationId = verificationId;
        },
        timeout: const Duration(minutes: 2),
      );
      
      // Wait for the completer to complete (either by codeSent, verificationCompleted, or verificationFailed)
      await _verificationCompleter.future;
    } catch (e, stackTrace) {
      developer.log('[AuthService] Exception during phone verification: $e', name: 'AuthService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Verify OTP code
  Future<UserCredential> verifyOTP(String otp) async {
    if (_verificationId == null) {
      developer.log('[AuthService] Verification ID not found', name: 'AuthService');
      throw Exception('Verification ID not found');
    }

    try {
      developer.log('[AuthService] Verifying OTP code', name: 'AuthService');
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: otp,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      developer.log('[AuthService] OTP verified successfully', name: 'AuthService');
      return userCredential;
    } catch (e, stackTrace) {
      developer.log('[AuthService] OTP verification failed: $e', name: 'AuthService', error: e, stackTrace: stackTrace);
      throw Exception('OTP verification failed: $e');
    }
  }

  // Resend OTP
  Future<void> resendOTP(String phoneNumber) async {
    try {
      developer.log('[AuthService] Resending OTP for: $phoneNumber', name: 'AuthService');
      
      _verificationCompleter = Completer<void>();
      
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (PhoneAuthCredential credential) async {
          developer.log('[AuthService] Auto-verification on resend', name: 'AuthService');
          try {
            await _firebaseAuth.signInWithCredential(credential);
            if (!_verificationCompleter.isCompleted) {
              _verificationCompleter.complete();
            }
          } catch (e) {
            if (!_verificationCompleter.isCompleted) {
              _verificationCompleter.completeError(e);
            }
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          developer.log('[AuthService] Resend verification failed: ${e.message}', name: 'AuthService', error: e);
          if (!_verificationCompleter.isCompleted) {
            _verificationCompleter.completeError(Exception('Phone verification failed: ${e.message}'));
          }
        },
        codeSent: (String verificationId, int? resendToken) {
          developer.log('[AuthService] Code resent successfully', name: 'AuthService');
          _verificationId = verificationId;
          _resendToken = resendToken;
          if (!_verificationCompleter.isCompleted) {
            _verificationCompleter.complete();
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          developer.log('[AuthService] Resend code auto-retrieval timeout', name: 'AuthService');
          _verificationId = verificationId;
        },
        forceResendingToken: _resendToken,
        timeout: const Duration(minutes: 2),
      );
      
      await _verificationCompleter.future;
    } catch (e, stackTrace) {
      developer.log('[AuthService] Resend OTP error: $e', name: 'AuthService', error: e, stackTrace: stackTrace);
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  // Check if user is authenticated
  bool get isAuthenticated => _firebaseAuth.currentUser != null;

  // Get auth state stream
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();
}
