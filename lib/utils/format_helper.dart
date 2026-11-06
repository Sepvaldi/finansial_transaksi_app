import 'package:flutter/material.dart';
import '../models/transaction_model.dart';

class Fmt {
  static const _bulan = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _bulanPendek = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  static const categories = ['Gaji', 'Belanja', 'Makanan', 'Utilitas'];

  // 1500000 -> "Rp 1.500.000"
  static String rupiah(int n) {
    final s = n.abs().toString().replaceAllMapped(
      RegExp(r'\B(?=(\d{3})+(?!\d))'),
      (m) => '.',
    );
    return 'Rp $s';
  }

  static String rupiahSigned(int n) => n < 0 ? '-${rupiah(n)}' : rupiah(n);

  static String signed(TransactionModel t) =>
      t.isIncome ? '+${rupiah(t.amount)}' : '-${rupiah(t.amount)}';

  static String monthYear(DateTime d) => '${_bulan[d.month - 1]} ${d.year}';
  static String monthShort(int month) => _bulanPendek[month - 1];

  // "24 Okt 2026 - 08:30"
  static String dateTime(DateTime d) {
    final hh = d.hour.toString().padLeft(2, '0');
    final mm = d.minute.toString().padLeft(2, '0');
    return '${d.day} ${_bulanPendek[d.month - 1]} ${d.year} - $hh:$mm';
  }

  // Ambil angka saja dari teks input: "1.500" -> 1500
  static int parseAmount(String s) =>
      int.tryParse(s.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;

  static IconData categoryIcon(String c) {
    switch (c) {
      case 'Gaji':
        return Icons.account_balance_wallet_outlined;
      case 'Belanja':
        return Icons.shopping_cart_outlined;
      case 'Makanan':
        return Icons.ramen_dining_outlined;
      case 'Utilitas':
        return Icons.bolt;
      default:
        return Icons.receipt_long_outlined;
    }
  }
}
