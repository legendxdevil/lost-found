import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:lost_and_found/core/errors/exceptions.dart';
import 'package:lost_and_found/features/auth/data/models/user_dto.dart';
import 'package:lost_and_found/core/constants/app_constants.dart';

abstract class AuthRemoteDatasource {
  Future<UserDTO> signInWithEmail(String email, String password);
  Future<UserDTO> signInWithGoogle();
  Future<UserDTO> signUp(String name, String email, String password);
  Future<void> signOut();
  Stream<UserDTO?> get authStateChanges;
  Future<UserDTO?> getCurrentUser();
  Future<void> updateFcmToken(String uid, String token);
}

class AuthRemoteDatasourceImpl implements AuthRemoteDatasource {
  final FirebaseAuth _auth;
  final FirebaseFirestore _db;

  AuthRemoteDatasourceImpl(this._auth, this._db);

  @override
  Future<UserDTO> signInWithEmail(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) throw const AuthException('User not found');
      
      final doc = await _db.collection(AppConstants.usersCollection).doc(credential.user!.uid).get();
      if (!doc.exists) throw const AuthException('User data not found in Firestore');
      
      return UserDTO.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Auth Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserDTO> signUp(String name, String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (credential.user == null) throw const AuthException('Sign up failed');
      
      final userDto = UserDTO(
        uid: credential.user!.uid,
        name: name,
        email: email,
        isAdmin: false,
        createdAt: DateTime.now(),
      );
      
      await _db.collection(AppConstants.usersCollection).doc(credential.user!.uid).set(userDto.toMap());
      
      return userDto;
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Auth Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<UserDTO> signInWithGoogle() async {
    try {
      final googleSignIn = GoogleSignIn(
        clientId: '199896400103-q06iu0vbkamtuul7lo8c7qtirinnn8r5.apps.googleusercontent.com',
      );
      final googleUser = await googleSignIn.signIn();
      if (googleUser == null) throw const AuthException('Google Sign-In cancelled');

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final firebaseUserCredential = await _auth.signInWithCredential(credential);
      final user = firebaseUserCredential.user;

      if (user == null) throw const AuthException('Firebase Sign-In failed');

      final doc = await _db.collection(AppConstants.usersCollection).doc(user.uid).get();
      
      if (!doc.exists) {
        // Create new user profile if it doesn't exist
        final userDto = UserDTO(
          uid: user.uid,
          name: user.displayName ?? 'New User',
          email: user.email ?? '',
          isAdmin: false,
          createdAt: DateTime.now(),
        );
        await _db.collection(AppConstants.usersCollection).doc(user.uid).set(userDto.toMap());
        return userDto;
      }

      return UserDTO.fromFirestore(doc);
    } on FirebaseAuthException catch (e) {
      throw AuthException(e.message ?? 'Auth Error');
    } catch (e) {
      throw ServerException(e.toString());
    }
  }

  @override
  Future<void> signOut() async {
    await _auth.signOut();
  }

  @override
  Stream<UserDTO?> get authStateChanges => _auth.authStateChanges().asyncMap((user) async {
    if (user == null) return null;
    final doc = await _db.collection(AppConstants.usersCollection).doc(user.uid).get();
    if (!doc.exists) return null;
    return UserDTO.fromFirestore(doc);
  });

  @override
  Future<UserDTO?> getCurrentUser() async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final doc = await _db.collection(AppConstants.usersCollection).doc(user.uid).get();
    if (!doc.exists) return null;
    return UserDTO.fromFirestore(doc);
  }

  @override
  Future<void> updateFcmToken(String uid, String token) async {
    await _db.collection(AppConstants.usersCollection).doc(uid).update({
      'fcmToken': token,
    });
  }
}
