import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../domain/models/user_model.dart';

final authServiceProvider = Provider<AuthService>((ref) => AuthService());

final authStateProvider = StreamProvider<User?>((ref) {
  return ref.watch(authServiceProvider).authStateChanges;
});

final currentUserProvider = StreamProvider<UserModel?>((ref) {
  final authState = ref.watch(authStateProvider);
  return authState.when(
    data: (user) {
      if (user == null) return Stream.value(null);
      return ref.watch(authServiceProvider).getUserStream(user.uid);
    },
    loading: () => Stream.value(null),
    error: (_, __) => Stream.value(null),
  );
});

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Stream<User?> get authStateChanges => _auth.authStateChanges();

  User? get currentUser => _auth.currentUser;

  Stream<UserModel?> getUserStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromFirestore(doc) : null);
  }

  Future<UserModel?> getUserData(String uid) async {
    final doc = await _firestore.collection('users').doc(uid).get();
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<UserCredential> signInWithEmail(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );
  }

  Future<UserModel> signUpWithEmail({
    required String email,
    required String password,
    required UserType userType,
    String? displayName,
    String? baroRegistrationNumber,
  }) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email.trim(),
      password: password,
    );

    final user = UserModel(
      uid: credential.user!.uid,
      email: email.trim(),
      userType: userType,
      displayName: displayName?.trim(),
      createdAt: DateTime.now(),
      baroRegistrationNumber: baroRegistrationNumber?.trim(),
    );

    await _firestore
        .collection('users')
        .doc(user.uid)
        .set(user.toFirestore());

    return user;
  }

  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
  }

  Future<void> resetPassword(String email) async {
    await _auth.sendPasswordResetEmail(email: email.trim());
  }

  Future<UserCredential> signInWithGoogle() async {
    // Trigger the authentication flow
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    
    if (googleUser == null) {
      throw Exception('Google sign in aborted');
    }

    // Obtain the auth details from the request
    final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

    // Create a new credential
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    // Sign in to Firebase with the Google credential
    final userCredential = await _auth.signInWithCredential(credential);

    // Check if user exists in Firestore, if not create
    final userDoc = await _firestore.collection('users').doc(userCredential.user!.uid).get();
    
    if (!userDoc.exists) {
      final newUser = UserModel(
        uid: userCredential.user!.uid,
        email: userCredential.user!.email!,
        userType: UserType.individual, // Default to individual for Google sign-in
        displayName: userCredential.user!.displayName,
        photoUrl: userCredential.user!.photoURL,
        createdAt: DateTime.now(),
      );
      await _firestore.collection('users').doc(newUser.uid).set(newUser.toFirestore());
    }

    return userCredential;
  }
}
