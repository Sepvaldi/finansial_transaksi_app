import 'package:cloud_firestore/cloud_firestore.dart';

class TransactionModel {
  final String id;
  final String type; // 'income' atau 'expense'
  final String title;
  final int amount;
  final String category;
  final DateTime date;

  TransactionModel({
    required this.id,
    required this.type,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
  });

  bool get isIncome => type == 'income';

  // Mengubah dokumen Firestore menjadi objek Dart
  factory TransactionModel.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data()!;
    return TransactionModel(
      id: doc.id,
      type: d['type'] ?? 'expense',
      title: d['title'] ?? '',
      amount: (d['amount'] as num? ?? 0).toInt(),
      category: d['category'] ?? 'Lainnya',
      date: (d['date'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}