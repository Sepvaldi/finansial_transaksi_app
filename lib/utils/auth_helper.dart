import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart'
    show kIsWeb, debugPrint; // ← tambahkan ini
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  static bool _googleReady = false;

  // SIGN UP: buat akun di Firebase Auth, lalu simpan profil di Firestore
  Future<String?> register({
    required String username,
    required String email,
    required String password,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await cred.user!.updateDisplayName(username);
      await _db.collection('users').doc(cred.user!.uid).set({
        'username': username,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
      });
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // LOGIN email & password
  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }

  // LOGIN dengan Google (web: popup, Android/iOS: google_sign_in 7.x)
  Future<String?> signInWithGoogle() async {
    try {
      UserCredential result;

      if (kIsWeb) {
        // WEB: Firebase membuka jendela popup login Google
        result = await _auth.signInWithPopup(GoogleAuthProvider());
      } else {
        // ANDROID / iOS: lewat plugin google_sign_in
        if (!_googleReady) {
          await GoogleSignIn.instance.initialize();
          _googleReady = true;
        }
        final googleUser = await GoogleSignIn.instance.authenticate();
        final credential = GoogleAuthProvider.credential(
          idToken: googleUser.authentication.idToken,
        );
        result = await _auth.signInWithCredential(credential);
      }

      // Simpan profil hanya kalau akun Google ini baru pertama kali masuk
      if (result.additionalUserInfo?.isNewUser ?? false) {
        final user = result.user!;
        await _db.collection('users').doc(user.uid).set({
          'username': user.displayName ?? '',
          'email': user.email ?? '',
          'createdAt': FieldValue.serverTimestamp(),
        });
      }
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user' ||
          e.code == 'cancelled-popup-request') {
        return 'Login Google dibatalkan';
      }
      return _errorMessage(e);
    } catch (e) {
      debugPrint('Google sign-in error: $e'); // tampil di Debug Console
      return 'Login Google gagal: $e'; // pesan sekarang menyertakan penyebab
    }
  }

  // LUPA PASSWORD: Firebase mengirim email berisi link reset
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return null;
    } on FirebaseAuthException catch (e) {
      return _errorMessage(e);
    }
  }

  Future<void> logout() async {
    await _auth.signOut();
  }

  // Terjemahkan kode error Firebase jadi pesan yang ramah
  String _errorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Format email tidak valid';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email atau password salah';
      case 'email-already-in-use':
        return 'Email sudah terdaftar';
      case 'weak-password':
        return 'Password minimal 6 karakter';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet';
      case 'requires-recent-login':
        return 'Sesi sudah lama, silakan login ulang lalu coba lagi';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan. Tunggu beberapa menit lalu coba lagi';
      default:
        return 'Error: ${e.message}';
    }
  }

  // Ganti password. Firebase mewajibkan verifikasi ulang dengan password lama.
  Future<String?> changePassword(String oldPass, String newPass) async {
    try {
      final user = _auth.currentUser!;

      // Akun yang daftar lewat Google tidak punya password di Firebase
      final hasPassword = user.providerData.any(
        (p) => p.providerId == 'password',
      );
      if (!hasPassword) {
        return 'Akun Google tidak memiliki password. Kelola password di akun Google kamu.';
      }

      final cred = EmailAuthProvider.credential(
        email: user.email!,
        password: oldPass,
      );
      await user.reauthenticateWithCredential(
        cred,
      ); // 1) buktikan ini benar pemiliknya
      await user.updatePassword(newPass); // 2) baru ganti
      return null;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password' || e.code == 'invalid-credential') {
        return 'Password lama salah';
      }
      return _errorMessage(e);
    } catch (e) {
      return 'Terjadi kesalahan: $e';
    }
  }
}
