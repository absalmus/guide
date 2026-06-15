import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:stitch_smart_church_guide/models/user_profile.dart';
import 'package:stitch_smart_church_guide/services/firestore_service.dart';
import 'package:stitch_smart_church_guide/services/notification_service.dart';

class AuthService extends ChangeNotifier {
  AuthService({FirestoreService? firestore})
    : _firestore = firestore ?? FirestoreService();

  final FirestoreService _firestore;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String? _verificationId;
  UserProfile? _currentProfile;

  User? get firebaseUser => _auth.currentUser;
  UserProfile? get currentProfile => _currentProfile;

  bool get isAuthenticated => _auth.currentUser != null;

  Future<void> init() async {
    // No demo mode: initialize auth state if user is already signed in
    if (_auth.currentUser != null) {
      await _loadProfile(_auth.currentUser!.uid);
    }
  }

  Future<UserProfile?> signInWithEmail(String email, String password) async {
    final credential = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = await _loadProfile(credential.user!.uid);
    if (profile != null) {
      await NotificationService.instance.linkTokenToUser(profile.id);
    }
    return profile;
  }

  Future<UserProfile?> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    final profile = UserProfile(
      id: credential.user!.uid,
      name: name,
      email: email,
      profileComplete: false,
    );
    await _firestore.saveUserProfile(profile);
    _currentProfile = profile;
    notifyListeners();
    await NotificationService.instance.linkTokenToUser(profile.id);
    return profile;
  }

  Future<void> signInWithPhone(String phone, String code) async {
    if (_verificationId == null) {
      throw StateError(
        'No verification id. Call startPhoneVerification first.',
      );
    }

    final credential = PhoneAuthProvider.credential(
      verificationId: _verificationId!,
      smsCode: code,
    );

    final result = await _auth.signInWithCredential(credential);
    final profile = await _loadProfile(result.user!.uid);
    if (profile != null) {
      await NotificationService.instance.linkTokenToUser(profile.id);
    }
  }

  Future<void> startPhoneVerification(
    String phone, {
    required Function(String verificationId) codeSent,
    required Function(Exception) onFailed,
  }) async {
    await _auth.verifyPhoneNumber(
      phoneNumber: phone,
      verificationCompleted: (PhoneAuthCredential credential) async {
        final result = await _auth.signInWithCredential(credential);
        await _loadProfile(result.user!.uid);
      },
      verificationFailed: (e) => onFailed(Exception(e.message)),
      codeSent: (verificationId, _) {
        _verificationId = verificationId;
        codeSent(verificationId);
      },
      codeAutoRetrievalTimeout: (verificationId) =>
          _verificationId = verificationId,
    );
  }

  Future<UserProfile?> _loadProfile(String uid) async {
    var profile = await _firestore.getUserProfile(uid);
    profile ??= UserProfile(
      id: uid,
      name: _auth.currentUser?.displayName ?? '',
      email: _auth.currentUser?.email ?? '',
      profileComplete: false,
    );
    _currentProfile = profile;
    notifyListeners();
    return profile;
  }

  Future<void> updateProfile(UserProfile profile) async {
    final updated = profile.copyWith(profileComplete: true);
    await _firestore.saveUserProfile(updated);
    _currentProfile = updated;
    notifyListeners();
  }

  Future<void> signOut() async {
    await _auth.signOut();
    _currentProfile = null;
    notifyListeners();
  }

  Future<UserProfile?> getCurrentProfile() async {
    if (_currentProfile != null) return _currentProfile;
    final user = _auth.currentUser;
    if (user == null) return null;
    return _loadProfile(user.uid);
  }
}
