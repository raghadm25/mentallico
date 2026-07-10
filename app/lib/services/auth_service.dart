import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _db   = FirebaseFirestore.instance;

  static User? get currentUser => _auth.currentUser;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  // ── Email / Password ───────────────────────────────────────────────────────

  static Future<String> signIn(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(), password: password);
    final uid = cred.user!.uid;
    final doc = await _db.collection('users').doc(uid).get();
    final role = doc.data()?['role'] as String? ?? 'patient';

    // Keep therapist profile fresh and mark them as available
    if (role == 'therapist') {
      await _db.collection('therapists').doc(uid).set({
        'name':      doc.data()?['name'] ?? '',
        'uid':       uid,
        'available': true,
        'lastSeen':  FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return role;
  }

  static Future<String> signUp({
    required String name,
    required String email,
    required String password,
    required String role,
  }) async {
    final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(), password: password);
    final uid = cred.user!.uid;
    await cred.user!.updateDisplayName(name);
    await _db.collection('users').doc(uid).set({
      'name':      name,
      'email':     email.trim(),
      'bio':       '',
      'role':      role,
      'createdAt': FieldValue.serverTimestamp(),
    });

    // Register therapist in the public therapists collection so patients can find them
    if (role == 'therapist') {
      await _db.collection('therapists').doc(uid).set({
        'name':      name,
        'uid':       uid,
        'specialty': 'General',
        'bio':       '',
        'available': true,
        'rating':    0.0,
        'reviews':   0,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    return role;
  }

  // ── Google Sign-In ─────────────────────────────────────────────────────────

  static Future<String> signInWithGoogle({String role = 'patient'}) async {
    UserCredential cred;

    if (kIsWeb) {
      final provider = GoogleAuthProvider()
        ..addScope('email')
        ..addScope('profile');
      cred = await _auth.signInWithPopup(provider);
    } else {
      final googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) throw Exception('Google sign-in cancelled.');
      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken:     googleAuth.idToken,
      );
      cred = await _auth.signInWithCredential(credential);
    }

    final user = cred.user!;
    final uid  = user.uid;
    final doc  = await _db.collection('users').doc(uid).get();

    if (!doc.exists) {
      await _db.collection('users').doc(uid).set({
        'name':      user.displayName ?? '',
        'email':     user.email ?? '',
        'bio':       '',
        'role':      role,
        'createdAt': FieldValue.serverTimestamp(),
      });
      if (role == 'therapist') {
        await _db.collection('therapists').doc(uid).set({
          'name':      user.displayName ?? '',
          'uid':       uid,
          'specialty': 'General',
          'bio':       '',
          'available': true,
          'rating':    0.0,
          'reviews':   0,
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return role;
    }

    final existingRole = doc.data()?['role'] as String? ?? 'patient';
    if (existingRole == 'therapist') {
      await _db.collection('therapists').doc(uid).set({
        'name':      doc.data()?['name'] ?? user.displayName ?? '',
        'uid':       uid,
        'available': true,
        'lastSeen':  FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    }

    return existingRole;
  }

  // ── Common ─────────────────────────────────────────────────────────────────

  static Future<void> signOut() async {
    final uid = currentUser?.uid;
    if (uid != null) {
      // Mark therapist as unavailable when they sign out
      try {
        final therapistDoc = await _db.collection('therapists').doc(uid).get();
        if (therapistDoc.exists) {
          await _db.collection('therapists').doc(uid).update({
            'available': false,
            'lastSeen':  FieldValue.serverTimestamp(),
          });
        }
      } catch (_) {}
    }
    await _auth.signOut();
    if (!kIsWeb) {
      await GoogleSignIn().signOut();
    }
  }

  static Future<String> getRole() async {
    final uid = currentUser?.uid;
    if (uid == null) return 'patient';
    final doc = await _db.collection('users').doc(uid).get();
    return doc.data()?['role'] as String? ?? 'patient';
  }
}
