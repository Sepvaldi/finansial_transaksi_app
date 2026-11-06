import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../utils/app_color.dart';
import '../utils/auth_helper.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/mbg_app_bar.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = AuthService();
  final _user = FirebaseAuth.instance.currentUser!;
  late final DocumentReference<Map<String, dynamic>> _doc = FirebaseFirestore
      .instance
      .collection('users')
      .doc(_user.uid);

  // Pilih gambar dari galeri / file di perangkat
  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 400, // dikecilkan supaya muat di Firestore
      maxHeight: 400,
      imageQuality: 70,
    );
    if (picked == null) return; // user batal memilih

    final bytes = await picked.readAsBytes();
    await _doc.set({
      'avatarBase64': base64Encode(bytes),
    }, SetOptions(merge: true));
    if (!mounted) return;
    CustomSnackbar.show(context, 'Avatar diperbarui');
  }

  // Hapus foto -> kembali memakai huruf awal nama
  Future<void> _removeAvatar() async {
    await _doc.set({
      'avatarBase64': FieldValue.delete(),
    }, SetOptions(merge: true));
    if (!mounted) return;
    CustomSnackbar.show(context, 'Avatar dihapus, memakai huruf awal');
  }

  void _avatarOptions() {
    showModalBottomSheet<void>(
      context: context,
      builder: (sheetContext) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Pilih dari galeri / file'),
              onTap: () {
                Navigator.pop(sheetContext);
                _pickAvatar();
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Gunakan huruf awal nama'),
              onTap: () {
                Navigator.pop(sheetContext);
                _removeAvatar();
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _changePassword() async {
    final result = await CustomDialog.askPasswords(context);
    if (result == null || !mounted) return;

    final oldPass = result[0];
    final newPass = result[1];
    if (oldPass.isEmpty || newPass.length < 6) {
      CustomSnackbar.show(
        context,
        'Isi password lama dan password baru minimal 6 karakter',
        isError: true,
      );
      return;
    }

    final error = await _auth.changePassword(oldPass, newPass);
    if (!mounted) return;
    CustomSnackbar.show(
      context,
      error ?? 'Password berhasil diganti',
      isError: error != null,
    );
  }

  Future<void> _logout() async {
    await _auth.logout();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BackgroundKedua,
      body: Column(
        children: [
          const MbgAppBar(
            title: 'Profil Saya',
            showBack: true,
            showProfile: false,
          ),
          Expanded(
            child: StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
              stream: _doc.snapshots(),
              builder: (context, snap) {
                final data = snap.data?.data();
                final name =
                    (data?['username'] ??
                            _user.displayName ??
                            _user.email?.split('@').first ??
                            'User')
                        as String;
                final avatar = data?['avatarBase64'] as String?;

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      Container(
                        width: double.infinity,
                        color: AppColor.BackgroundUtama,
                        padding: const EdgeInsets.fromLTRB(24, 48, 24, 48),
                        child: Column(
                          children: [
                            _avatar(name, avatar),
                            const SizedBox(height: 16),
                            Text(
                              name,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 22,
                                fontFamily: 'DaysOne',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _user.email ?? '',
                              style: const TextStyle(
                                color: Color.fromRGBO(255, 255, 255, 0.8),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        color: AppColor.BackgroundUtama, // ← ganti jadi hijau
                        child: Container(
                          width: double.infinity,
                          padding: const EdgeInsets.fromLTRB(
                            30,
                            70,
                            30,
                            32,
                          ), // ← 80 diganti 28
                          decoration: const BoxDecoration(
                            color: AppColor.BackgroundKedua, // abu-abu tetap
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(50),
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _sectionLabel('Edit Profil'),
                              _optionTile(
                                Icons.edit_note,
                                'Ganti avatarmu disini',
                                _avatarOptions,
                              ),
                              const SizedBox(height: 20),
                              _sectionLabel('Keamanan'),
                              _optionTile(
                                Icons.lock,
                                'Ganti password barumu disini',
                                _changePassword,
                              ),
                              const SizedBox(height: 40),
                              Center(
                                child: ElevatedButton(
                                  onPressed: _logout,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColor.expenseSoft,
                                    foregroundColor: AppColor.expense,
                                    minimumSize: const Size(250, 44),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    ),
                                  ),
                                  child: const Text(
                                    'Log Out',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 16,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // Jika ada foto -> tampilkan foto. Jika tidak -> huruf awal nama (kapital)
  Widget _avatar(String name, String? base64Str) {
    final initial = name.isNotEmpty ? name[0].toUpperCase() : '?';
    return GestureDetector(
      onTap: _avatarOptions,
      child: CircleAvatar(
        radius: 60,
        backgroundColor: Colors.white,
        backgroundImage: base64Str != null
            ? MemoryImage(base64Decode(base64Str))
            : null,
        child: base64Str == null
            ? Text(
                initial,
                style: const TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w900,
                  color: AppColor.BackgroundUtama,
                ),
              )
            : null,
      ),
    );
  }

  Widget _sectionLabel(String text) => Padding(
    padding: const EdgeInsets.only(left: 4, bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );

  Widget _optionTile(IconData icon, String text, VoidCallback onTap) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(30),
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Row(
            children: [
              Icon(icon),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  text,
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
