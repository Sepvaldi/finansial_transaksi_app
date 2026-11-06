import 'package:flutter/material.dart';

class CustomDialog {
  static Future<String?> askEmail(BuildContext context, {String initial = ''}) {
    final controller = TextEditingController(text: initial);
    return showDialog<String>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Reset Password'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(hintText: 'Masukkan email kamu'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );
  }

  // Sheet konfirmasi hapus (gambar no. 5). Mengembalikan true jika user setuju.
  static Future<bool> confirmDelete(BuildContext context) async {
    final result = await showModalBottomSheet<bool>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (sheetContext) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 5,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 36,
              backgroundColor: Color(0xFFFFD6D6),
              child: Icon(
                Icons.warning_amber_rounded,
                size: 36,
                color: Color(0xFFAA0000),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Hapus Transaksi?',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            const Text.rich(
              TextSpan(
                children: [
                  TextSpan(
                    text: 'Yakin ingin menghapus catatan transaksi ini dari ',
                  ),
                  TextSpan(
                    text: 'Cloud Firestore',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  TextSpan(
                    text:
                        '? Aksi ini akan mengubah saldo rekening dan tidak dapat dibatalkan.',
                  ),
                ],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => Navigator.pop(sheetContext, true),
                icon: const Icon(Icons.delete_outline),
                label: const Text('Ya, Hapus Permanen'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFB30000),
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(sheetContext, false),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFDDF5DD),
                  foregroundColor: Colors.black,
                ),
                child: const Text('Batal & Kembali'),
              ),
            ),
          ],
        ),
      ),
    );
    return result ?? false; // kalau sheet ditutup dengan swipe → dianggap batal
  }

  // Dialog ganti password: mengembalikan [passwordLama, passwordBaru] atau null
  static Future<List<String>?> askPasswords(BuildContext context) {
    final oldC = TextEditingController();
    final newC = TextEditingController();
    return showDialog<List<String>>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Ganti Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: oldC,
              obscureText: true,
              decoration: const InputDecoration(hintText: 'Password lama'),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: newC,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: 'Password baru (min. 6 karakter)',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () =>
                Navigator.pop(dialogContext, [oldC.text, newC.text]),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
  }
}
