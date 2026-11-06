import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../utils/app_color.dart';
import '../utils/format_helper.dart';

class TransactionTile extends StatelessWidget {
  final TransactionModel trx;
  final VoidCallback onTap;

  const TransactionTile({super.key, required this.trx, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = trx.isIncome ? AppColor.BackgroundUtama : AppColor.expense;
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: trx.isIncome
                      ? AppColor.incomeSoft
                      : AppColor.expenseSoft,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Fmt.categoryIcon(trx.category),
                  color: color,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      trx.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                    Text(
                      Fmt.dateTime(trx.date),
                      style: const TextStyle(fontSize: 11),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    Fmt.signed(trx),
                    style: TextStyle(fontWeight: FontWeight.bold, color: color),
                  ),
                  Text(
                    trx.isIncome ? 'Pemasukan' : 'Pengeluaran',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: color,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
