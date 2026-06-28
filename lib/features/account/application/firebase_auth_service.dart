import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../../../core/config/scanleno_app_config.dart';
import '../../../core/firebase/firebase_bootstrap.dart';
import '../../files/application/local_file_repository.dart';

class ScanLenoAuthException implements Exception {
  const ScanLenoAuthException(this.code, [this.debugCode]);

  final String code;
  final String? debugCode;

  @override
  String toString() => 'ScanLenoAuthException($code, $debugCode)';
}

class ScanLenoUserMetadata {
  const ScanLenoUserMetadata({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.provider,
    required this.isAnonymous,
    required this.plan,
    required this.premiumActive,
    required this.monthlyOcrUsed,
    required this.monthlyOcrLimit,
    required this.scanCredit,
    required this.role,
    required this.disabled,
    this.lastLoginAt,
  });

  final String uid;
  final String? email;
  final String? displayName;
  final String? photoUrl;
  final String provider;
  final bool isAnonymous;
  final String plan;
  final bool premiumActive;
  final int monthlyOcrUsed;
  final int monthlyOcrLimit;
  final int scanCredit;
  final String role;
  final bool disabled;
  final DateTime? lastLoginAt;
}

class FirebaseAuthService extends ChangeNotifier {
  FirebaseAuth? _auth;
  FirebaseFirestore? _firestore;
  bool available = false;
  bool googleInitialized = false;
  bool adminClaimActive = false;
  bool ownerClaimActive = false;
  String? connectionWarning;
  ScanLenoUserMetadata? metadata;

  User? get user => _auth?.currentUser;
  bool get isSignedIn => user != null;
  bool get isAdmin =>
      adminClaimActive ||
      ownerClaimActive ||
      metadata?.role == 'admin' ||
      metadata?.role == 'owner';
  bool get isAnonymous => user?.isAnonymous ?? false;

  Future<void> initialize() async {
    if (!FirebaseBootstrap.initialized) {
      connectionWarning = 'firebase_unavailable';
      available = false;
      notifyListeners();
      return;
    }
    try {
      _auth = FirebaseAuth.instance;
      _firestore = FirebaseFirestore.instance;
      if (!kIsWeb) {
        await _initializeGoogle();
      }
      _auth!.authStateChanges().listen((_) => refreshMetadata());
      await refreshMetadata();
      available = true;
      connectionWarning = null;
    } catch (_) {
      available = false;
      connectionWarning = 'firebase_unavailable';
    }
    notifyListeners();
  }

  Future<void> refreshMetadata() async {
    final current = user;
    if (current == null || _firestore == null) {
      metadata = null;
      adminClaimActive = false;
      ownerClaimActive = false;
      notifyListeners();
      return;
    }
    try {
      final tokenResult = await current.getIdTokenResult(true);
      adminClaimActive = tokenResult.claims?['admin'] == true;
      ownerClaimActive = tokenResult.claims?['owner'] == true;
      await _upsertFirestoreMetadata(current);
      final syncSucceeded = await _syncBackendMetadata(current);
      final snapshot = await _firestore!.collection('users').doc(current.uid).get();
      final data = snapshot.data() ?? const <String, Object?>{};
      metadata = ScanLenoUserMetadata(
        uid: current.uid,
        email: data['email'] as String? ?? current.email,
        displayName: data['displayName'] as String? ?? current.displayName,
        photoUrl: data['photoUrl'] as String? ?? current.photoURL,
        provider: data['provider'] as String? ?? _provider(current),
        isAnonymous: data['isAnonymous'] as bool? ?? current.isAnonymous,
        plan: data['plan'] as String? ?? 'free',
        premiumActive: data['premiumActive'] as bool? ?? false,
        monthlyOcrUsed: data['monthlyOcrUsed'] as int? ?? 0,
        monthlyOcrLimit: data['monthlyOcrLimit'] as int? ?? 500,
        scanCredit: data['scanCredit'] as int? ?? await LocalFileRepository().getScanCredits(),
        role: data['role'] as String? ??
            (ownerClaimActive ? 'owner' : adminClaimActive ? 'admin' : 'user'),
        disabled: data['disabled'] as bool? ?? false,
        lastLoginAt: (data['lastLoginAt'] as Timestamp?)?.toDate(),
      );
      connectionWarning = syncSucceeded ? null : 'backend_unavailable';
    } catch (_) {
      connectionWarning = 'firebase_metadata_unavailable';
    }
    notifyListeners();
  }

  Future<String?> idToken({bool forceRefresh = false}) {
    return user?.getIdToken(forceRefresh) ?? Future<String?>.value();
  }

  Future<void> signInAnonymously() async {
    await _requireAuth().signInAnonymously();
    await refreshMetadata();
  }

  Future<void> registerWithEmail(String email, String password) async {
    await _requireAuth().createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    await refreshMetadata();
  }

  Future<void> signInWithEmail(String email, String password) async {
    await _requireAuth().signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    await refreshMetadata();
  }

  Future<void> resetPassword(String email) {
    return _requireAuth().sendPasswordResetEmail(email: email);
  }

  Future<void> signInWithGoogle() async {
    _debugAuth('Google Sign-In started on ${kIsWeb ? 'web' : defaultTargetPlatform.name}');
    if (kIsWeb) {
      await _signInWithGoogleWeb();
      return;
    }
    await _signInWithGoogleNative();
  }

  Future<void> signInWithApple() async {
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: [
        AppleIDAuthorizationScopes.email,
        AppleIDAuthorizationScopes.fullName,
      ],
    );
    final oauth = OAuthProvider('apple.com').credential(
      idToken: credential.identityToken,
      accessToken: credential.authorizationCode,
    );
    await _requireAuth().signInWithCredential(oauth);
    await refreshMetadata();
  }

  Future<void> signOut() async {
    if (!kIsWeb) {
      await GoogleSignIn.instance.signOut();
    }
    await _auth?.signOut();
    metadata = null;
    notifyListeners();
  }

  FirebaseAuth _requireAuth() {
    final auth = _auth;
    if (auth == null) throw StateError('firebase_unavailable');
    return auth;
  }

  Future<void> _initializeGoogle() async {
    if (googleInitialized) return;
    try {
      await GoogleSignIn.instance.initialize();
      googleInitialized = true;
    } catch (_) {
      googleInitialized = false;
    }
  }

  Future<void> _upsertFirestoreMetadata(User current) async {
    final reference = _firestore!.collection('users').doc(current.uid);
    final snapshot = await reference.get();
    final now = FieldValue.serverTimestamp();
    final base = <String, Object?>{
      'uid': current.uid,
      'email': current.email,
      'displayName': current.displayName,
      'photoUrl': current.photoURL,
      'provider': _provider(current),
      'isAnonymous': current.isAnonymous,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
      'lastLoginAt': now,
      'updatedAt': now,
    };
    if (!snapshot.exists) {
      await reference.set({
        ...base,
        'plan': 'free',
        'premiumActive': false,
        'premiumExpiresAt': null,
        'monthlyOcrUsed': 0,
        'monthlyOcrLimit': 0,
        'scanCredit': 0,
        'createdAt': now,
        'disabled': false,
        'role': 'user',
      });
      return;
    }
    await reference.set({
      'displayName': current.displayName,
      'photoUrl': current.photoURL,
      'lastLoginAt': now,
      'updatedAt': now,
    }, SetOptions(merge: true));
  }

  Future<bool> _syncBackendMetadata(User current) async {
    final token = await current.getIdToken();
    final body = <String, Object?>{
      'email': current.email,
      'displayName': current.displayName,
      'photoUrl': current.photoURL,
      'provider': _provider(current),
      'isAnonymous': current.isAnonymous,
      'platform': kIsWeb ? 'web' : defaultTargetPlatform.name,
    };
    try {
      final response = await http
          .post(
            _backendUri('/api/account/sync'),
            headers: {
              'content-type': 'application/json; charset=utf-8',
              if (token != null) 'authorization': 'Bearer $token',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 8));
      final success = response.statusCode >= 200 && response.statusCode < 300;
      _debugAuth('Account sync ${success ? 'succeeded' : 'failed with HTTP ${response.statusCode}'}');
      return success;
    } catch (_) {
      connectionWarning = 'backend_unavailable';
      _debugAuth('Account sync failed');
      return false;
    }
  }

  Future<void> _signInWithGoogleWeb() async {
    try {
      _debugAuth('Using FirebaseAuth.signInWithPopup for Google web sign-in');
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      await _requireAuth().signInWithPopup(provider);
      await refreshMetadata();
    } on FirebaseAuthException catch (error) {
      _debugAuth('FirebaseAuthException during Google web sign-in: ${error.code}');
      throw ScanLenoAuthException(_mapFirebaseAuthError(error.code), error.code);
    } catch (error) {
      _debugAuth('Unexpected Google web sign-in error: ${error.runtimeType}');
      throw const ScanLenoAuthException('googleSignInFailed');
    }
  }

  Future<void> _signInWithGoogleNative() async {
    try {
      await _initializeGoogle();
      final account = await GoogleSignIn.instance.authenticate(
        scopeHint: const ['email', 'profile'],
      );
      _debugAuth('Google native account returned');
      final idToken = account.authentication.idToken;
      if (idToken == null) {
        _debugAuth('Google native idToken was null');
        throw const ScanLenoAuthException('googleSignInConfigError', 'missing_id_token');
      }
      String? accessToken;
      try {
        final authorization =
            await account.authorizationClient.authorizationForScopes(
              const ['email', 'profile'],
            ) ??
            await account.authorizationClient.authorizeScopes(
              const ['email', 'profile'],
            );
        accessToken = authorization.accessToken;
        _debugAuth('Google native access token was obtained');
      } on GoogleSignInException catch (error) {
        _debugAuth('Google access token authorization skipped: ${error.code.name}');
      }
      final credential = GoogleAuthProvider.credential(
        idToken: idToken,
        accessToken: accessToken,
      );
      await _requireAuth().signInWithCredential(credential);
      await refreshMetadata();
    } on ScanLenoAuthException {
      rethrow;
    } on GoogleSignInException catch (error) {
      _debugAuth('GoogleSignInException during native sign-in: ${error.code.name}');
      throw ScanLenoAuthException(_mapGoogleSignInError(error.code), error.code.name);
    } on FirebaseAuthException catch (error) {
      _debugAuth('FirebaseAuthException during Google native sign-in: ${error.code}');
      throw ScanLenoAuthException(_mapFirebaseAuthError(error.code), error.code);
    } catch (error) {
      _debugAuth('Unexpected Google native sign-in error: ${error.runtimeType}');
      throw const ScanLenoAuthException('googleSignInFailed');
    }
  }

  String _mapGoogleSignInError(GoogleSignInExceptionCode code) {
    return switch (code) {
      GoogleSignInExceptionCode.canceled => 'googleSignInCancelled',
      GoogleSignInExceptionCode.clientConfigurationError ||
      GoogleSignInExceptionCode.providerConfigurationError => 'googleSignInConfigError',
      GoogleSignInExceptionCode.uiUnavailable => 'googleSignInUiUnavailable',
      GoogleSignInExceptionCode.interrupted => 'googleSignInInterrupted',
      _ => 'googleSignInFailed',
    };
  }

  String _mapFirebaseAuthError(String code) {
    return switch (code) {
      'popup-closed-by-user' || 'web-context-cancelled' => 'googleSignInCancelled',
      'popup-blocked' => 'googleSignInPopupBlocked',
      'unauthorized-domain' => 'googleSignInUnauthorizedDomain',
      'network-request-failed' => 'networkError',
      'invalid-credential' || 'invalid-oauth-client-id' => 'googleSignInConfigError',
      'account-exists-with-different-credential' => 'accountExistsWithDifferentCredential',
      _ => 'googleSignInFailed',
    };
  }

  void _debugAuth(String message) {
    if (kDebugMode) {
      debugPrint('[ScanLenoAuth] $message');
    }
  }

  Uri _backendUri(String path) {
    return scanLenoConfig.backendUri(path);
  }

  String _provider(User current) {
    if (current.isAnonymous) return 'anonymous';
    if (current.providerData.any((item) => item.providerId == 'google.com')) {
      return 'google';
    }
    if (current.providerData.any((item) => item.providerId == 'apple.com')) {
      return 'apple';
    }
    if (current.providerData.any((item) => item.providerId == 'password')) {
      return 'password';
    }
    return current.providerData.isEmpty
        ? 'local'
        : current.providerData.first.providerId;
  }
}

final firebaseAuthService = FirebaseAuthService();
