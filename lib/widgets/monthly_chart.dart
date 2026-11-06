import 'package:flutter/material.dart';
import '../utils/app_color.dart';

class MonthlyChart extends StatelessWidget {
  final List<String> labels;
  final List<int> incomes;
  final List<int> expenses;

  const MonthlyChart({
    super.key,
    required this.labels,
    required this.incomes,
    required this.expenses,
  });

  static const _maxHeight = 120.0;

  @override
  Widget build(BuildContext context) {
    // Nilai terbesar dari semua batang, jadi patokan 100% tinggi
    final maxValue = [
      ...incomes,
      ...expenses,
    ].fold<int>(1, (a, b) => a > b ? a : b).toDouble();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: AppColor.shadow,
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Flexible(
                child: Text(
                  'Statik Keuangan Bulanan',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppColor.incomeSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '6 Bln Terakhir',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _legend(AppColor.income, 'Pemasukan'),
              const SizedBox(width: 24),
              _legend(AppColor.expense, 'Pengeluaran'),
            ],
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 160,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(labels.length, (i) {
                final isLast = i == labels.length - 1; // bulan ini lebih gelap
                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        _bar(
                          incomes[i],
                          maxValue,
                          isLast ? AppColor.deepGreen : const Color(0xFF4C9A6A),
                        ),
                        const SizedBox(width: 4),
                        _bar(
                          expenses[i],
                          maxValue,
                          isLast
                              ? const Color(0xFFB30000)
                              : const Color(0xFFD65C5C),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: isLast ? FontWeight.bold : FontWeight.w500,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _bar(int value, double maxValue, Color color) {
    final h = value == 0
        ? 0.0
        : (value / maxValue * _maxHeight).clamp(4.0, _maxHeight).toDouble();
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 12,
      height: h,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(6),
      ),
    );
  }

  Widget _legend(Color color, String text) {
    return Row(
      children: [
        CircleAvatar(radius: 6, backgroundColor: color),
        const SizedBox(width: 6),
        Text(
          text,
          style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }
}
