import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/transaction_model.dart';

class TransactionService {
  final _db = FirebaseFirestore.instance;

  // Alamat koleksi transaksi milik user yang sedang login
  CollectionReference<Map<String, dynamic>> get _col {
    final uid = FirebaseAuth.instance.currentUser!.uid;
    return _db.collection('users').doc(uid).collection('transactions');
  }

  // Stream = data "hidup": setiap ada perubahan di Firestore, otomatis dikirim lagi
  Stream<List<TransactionModel>> stream() {
    return _col
        .orderBy('date', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(TransactionModel.fromDoc).toList());
  }

  Future<String?> add({
    required String type,
    required String title,
    required int amount,
    required String category,
  }) async {
    try {
      await _col.add({
        'type': type,
        'title': title,
        'amount': amount,
        'category': category,
        'date': Timestamp.now(),
      });
      return null;
    } catch (e) {
      return 'Gagal menyimpan: $e';
    }
  }

  Future<String?> update(
    String id, {
    required String type,
    required String title,
    required int amount,
  }) async {
    try {
      await _col.doc(id).update({
        'type': type,
        'title': title,
        'amount': amount,
      });
      return null;
    } catch (e) {
      return 'Gagal memperbarui: $e';
    }
  }

  Future<String?> delete(String id) async {
    try {
      await _col.doc(id).delete();
      return null;
    } catch (e) {
      return 'Gagal menghapus: $e';
    }
  }
}
