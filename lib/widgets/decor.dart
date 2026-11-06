import 'dart:math';
import 'package:flutter/material.dart';

// Warna lingkaran (sebelum diberi transparansi)
class DecorColor {
  static const Color green = Color(0xFFB9F5B9); // hijau muda, untuk latar hijau
  static const Color gray = Color(0xFFBDBDBD);  // abu-abu muda, untuk latar abu-abu
}

/// Kotak berlatar warna + lingkaran acak transparan di belakang isinya.
class DecorBox extends StatelessWidget {
  final Widget child;
  final Color color;        // warna latar kotak
  final Color circleColor;  // DecorColor.green atau DecorColor.gray
  final double opacity;     // 0.3 = 30%
  final int seed;           // ganti angka ini untuk mengacak ulang pola
  final int count;          // jumlah lingkaran
  final EdgeInsetsGeometry padding;
  final BorderRadius? borderRadius;

  const DecorBox({
    super.key,
    required this.child,
    required this.color,
    required this.circleColor,
    this.opacity = 0.3,
    this.seed = 1,
    this.count = 7,
    this.padding = EdgeInsets.zero,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      clipBehavior: Clip.antiAlias, // potong lingkaran yang keluar dari kotak
      decoration: BoxDecoration(color: color, borderRadius: borderRadius),
      child: Stack(
        children: [
          // Lapisan lingkaran (di belakang isi)
          Positioned.fill(
            child: IgnorePointer( // supaya tidak menghalangi sentuhan/klik
              child: LayoutBuilder(
                builder: (context, c) {
                  final rnd = Random(seed);
                  final circles = <Widget>[];
                  for (var i = 0; i < count; i++) {
                    final size = 40 + rnd.nextDouble() * 120; // diameter 40-160
                    final cx = rnd.nextDouble() * c.maxWidth;
                    final cy = rnd.nextDouble() * c.maxHeight;
                    circles.add(
                      Positioned(
                        left: cx - size / 2,
                        top: cy - size / 2,
                        child: Container(
                          width: size,
                          height: size,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: circleColor.withValues(alpha: opacity),
                          ),
                        ),
                      ),
                    );
                  }
                  return Stack(children: circles);
                },
              ),
            ),
          ),
          // Lapisan isi (di depan)
          Padding(padding: padding, child: child),
        ],
      ),
    );
  }
}