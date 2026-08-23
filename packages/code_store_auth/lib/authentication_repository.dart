import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'cache.dart';
import 'user.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/foundation.dart'
    show debugPrint, defaultTargetPlatform, kIsWeb, TargetPlatform;
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

abstract class AuthenticationRepository {}

class FirebaseAuthenticationRepository extends AuthenticationRepository {
  FirebaseAuthenticationRepository({
    CacheClient? cache,
    firebase_auth.FirebaseAuth? firebaseAuth,
  }) : _cache = cache ?? CacheClient(),
       _firebaseAuth = firebaseAuth ?? firebase_auth.FirebaseAuth.instance;

  final CacheClient _cache;
  final firebase_auth.FirebaseAuth _firebaseAuth;

  /// Must be called once before any Google sign-in calls.
  Future<void> initializeGoogleSignIn({String? serverClientId}) async {
    await GoogleSignIn.instance.initialize(
      serverClientId:
          !kIsWeb && defaultTargetPlatform == TargetPlatform.android
              ? serverClientId
              : null,
    );
  }

  static const userCacheKey = '__user_cache_key__';

  Stream<User> get user {
    return _firebaseAuth.authStateChanges().map((firebaseUser) {
      final user = firebaseUser == null ? User.empty : firebaseUser.toUser;
      _cache.write(key: userCacheKey, value: user);
      return user;
    });
  }

  User get currentUser {
    return _cache.read<User>(key: userCacheKey) ?? User.empty;
  }

  Future<void> signUpWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw SignUpWithEmailAndPasswordFailure.fromCode(
        e.code,
        messageString: e.message,
      );
    } catch (_) {
      throw const SignUpWithEmailAndPasswordFailure();
    }
  }

  Future<void> logInWithGoogle() async {
    try {
      final account = await GoogleSignIn.instance.authenticate();
      final authentication = account.authentication;
      final credential = firebase_auth.GoogleAuthProvider.credential(
        idToken: authentication.idToken,
      );
      await _firebaseAuth.signInWithCredential(credential);
    } on GoogleSignInException catch (e) {
      if (e.code == GoogleSignInExceptionCode.canceled) {
        throw const LogInWithGoogleCancelled();
      }
      throw LogInWithGoogleFailure(e.description ?? 'Google sign-in failed.');
    } on PlatformException catch (e) {
      if (e.code == 'popup_closed_by_user') {
        throw const LogInWithGoogleCancelled();
      }
      final message = _friendlyGoogleSignInError(e);
      throw LogInWithGoogleFailure(message);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code, messageString: e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw const LogInWithGoogleFailure();
    }
  }

  String _friendlyGoogleSignInError(Object error) {
    if (error is PlatformException) {
      if (error.code == 'network_error') {
        return 'Google sign-in failed. Check your network and try again.';
      }
    }
    final text = error.toString();
    if (text.contains('signInWithCredential') ||
        text.contains('ApiException: 10') ||
        text.contains('invalid-credential')) {
      return 'Google sign-in failed. Add your app SHA-1 in Firebase Console, '
          'download the new google-services.json, then rebuild and reinstall.';
    }
    return 'Google sign-in failed. Please try again.';
  }

  Future<void> logInWithApple() async {
    try {
      late final firebase_auth.AuthCredential credential;
      if (kIsWeb) {
        final appleProvider = firebase_auth.OAuthProvider('apple.com');
        final userCredential = await _firebaseAuth.signInWithPopup(
          appleProvider,
        );
        credential = userCredential.credential!;
      } else {
        final appleCredential = await SignInWithApple.getAppleIDCredential(
          scopes: [
            AppleIDAuthorizationScopes.email,
            AppleIDAuthorizationScopes.fullName,
          ],
        );
        credential = firebase_auth.OAuthProvider('apple.com').credential(
          idToken: appleCredential.identityToken,
          accessToken: appleCredential.authorizationCode,
        );
      }
      await _firebaseAuth.signInWithCredential(credential);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithGoogleFailure.fromCode(e.code, messageString: e.message);
    } catch (e) {
      debugPrint(e.toString());
      throw const LogInWithGoogleFailure();
    }
  }

  Future<void> logInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw LogInWithEmailAndPasswordFailure.fromCode(
        e.code,
        messageString: e.message,
      );
    } catch (_) {
      throw const LogInWithEmailAndPasswordFailure();
    }
  }

  Future<void> logOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        GoogleSignIn.instance.signOut(),
      ]);
    } catch (_) {
      throw LogOutFailure();
    }
  }

  Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw PasswordResetFailure.fromCode(e.code, messageString: e.message);
    }
  }

  Future<void> deleteAccount() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) {
      throw const DeleteAccountFailure('No signed-in user found.');
    }

    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .delete();
    } catch (_) {}

    try {
      await user.delete();
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw DeleteAccountFailure.fromCode(e.code, messageString: e.message);
    } catch (_) {
      throw const DeleteAccountFailure();
    }
  }
}

extension on firebase_auth.User {
  User get toUser =>
      User(id: uid, email: email, name: displayName, photo: photoURL);
}

class SignUpWithEmailAndPasswordFailure implements Exception {
  const SignUpWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
    this.code = 'unknown',
  ]);

  factory SignUpWithEmailAndPasswordFailure.fromCode(
    String code, {
    String? messageString,
  }) {
    switch (code) {
      case 'invalid-email':
        return SignUpWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
          code,
        );
      case 'email-already-in-use':
        return SignUpWithEmailAndPasswordFailure(
          'An account already exists for that email.',
          code,
        );
      case 'weak-password':
        return SignUpWithEmailAndPasswordFailure(
          'Please enter a stronger password.',
          code,
        );
      case 'operation-not-allowed':
        return SignUpWithEmailAndPasswordFailure(
          'Operation is not allowed. Please contact support.',
          code,
        );
      default:
        return SignUpWithEmailAndPasswordFailure(
          messageString ?? 'An unknown error occurred.',
        );
    }
  }

  final String message;
  final String code;
}

class LogInWithEmailAndPasswordFailure implements Exception {
  const LogInWithEmailAndPasswordFailure([
    this.message = 'An unknown error occurred.',
  ]);

  factory LogInWithEmailAndPasswordFailure.fromCode(
    String code, {
    String? messageString,
  }) {
    switch (code) {
      case 'invalid-credential':
        return const LogInWithEmailAndPasswordFailure(
          'Wrong email or password, please try again.',
        );
      case 'invalid-email':
        return const LogInWithEmailAndPasswordFailure(
          'Email is not valid or badly formatted.',
        );
      case 'user-not-found':
        return const LogInWithEmailAndPasswordFailure(
          'No account found with this email.',
        );
      case 'wrong-password':
        return const LogInWithEmailAndPasswordFailure(
          'Incorrect password, please try again.',
        );
      case 'user-disabled':
        return const LogInWithEmailAndPasswordFailure(
          'This user has been disabled. Please contact support.',
        );
      default:
        return LogInWithEmailAndPasswordFailure(
          messageString ?? 'An unknown error occurred.',
        );
    }
  }

  final String message;
}

class LogInWithGoogleCancelled implements Exception {
  const LogInWithGoogleCancelled();
}

class LogInWithGoogleFailure implements Exception {
  const LogInWithGoogleFailure([this.message = 'An unknown error occurred.']);

  factory LogInWithGoogleFailure.fromCode(
    String code, {
    String? messageString,
  }) {
    switch (code) {
      case 'account-exists-with-different-credential':
        return const LogInWithGoogleFailure(
          'Account exists with different credentials.',
        );
      case 'invalid-credential':
        return const LogInWithGoogleFailure(
          'The credential received is malformed or has expired.',
        );
      case 'user-disabled':
        return const LogInWithGoogleFailure(
          'This user has been disabled. Please contact support.',
        );
      default:
        return LogInWithGoogleFailure(
          messageString ?? 'An unknown error occurred.',
        );
    }
  }

  final String message;
}

class LogOutFailure implements Exception {
  const LogOutFailure([this.message = 'An unknown error occurred.']);
  final String message;
}

class PasswordResetFailure implements Exception {
  const PasswordResetFailure([
    this.message = 'An unknown error occurred.',
    this.code = 'unknown',
  ]);

  factory PasswordResetFailure.fromCode(String code, {String? messageString}) {
    switch (code) {
      case 'invalid-email':
        return PasswordResetFailure(
          'Email is not valid or badly formatted.',
          code,
        );
      case 'user-not-found':
        return PasswordResetFailure(
          'No account found with this email address.',
          code,
        );
      default:
        return PasswordResetFailure(
          messageString ?? 'An unknown error occurred.',
        );
    }
  }

  final String message;
  final String code;
}

class DeleteAccountFailure implements Exception {
  const DeleteAccountFailure([this.message = 'Could not delete account.']);

  factory DeleteAccountFailure.fromCode(String code, {String? messageString}) {
    switch (code) {
      case 'requires-recent-login':
        return const DeleteAccountFailure(
          'For security, please sign in again and retry deleting your account.',
        );
      case 'user-not-found':
        return const DeleteAccountFailure('Account was already removed.');
      default:
        return DeleteAccountFailure(
          messageString ?? 'Could not delete account.',
        );
    }
  }

  final String message;
}
