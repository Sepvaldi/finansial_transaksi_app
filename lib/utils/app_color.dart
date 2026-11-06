import 'package:flutter/material.dart';

class AppColor {
  static const Color BackgroundUtama = Color(0xFF009900);
  static const Color BackgroundKedua = Color(0xFFEFEFEF);
  static const Color primary = Color(0xFFFFFFFF);
  static const Color hint = Color.fromRGBO(204, 204, 204, 1);
  static const Color link = Color.fromRGBO(75, 144, 200, 1);
  static const Color deepGreen = Color(0xFF006633); // tombol "Simpan"
  static const Color incomeSoft = Color(0xFFCCF5CC); // hijau muda
  static const Color income = Color.fromARGB(255, 188, 255, 188); // tulisan soft
  static const Color expense = Color(0xFFCC0000); // merah
  static const Color expenseSoft = Color(0xFFFF9999); // merah muda
  static const List<BoxShadow> shadow = [
    BoxShadow(
      color: Color.fromRGBO(0, 0, 0, 0.08),
      blurRadius: 12,
      offset: Offset(0, 4),
    ),
  ];
}
