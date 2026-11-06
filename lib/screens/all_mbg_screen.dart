import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_services.dart';
import '../utils/app_color.dart';
import '../widgets/mbg_app_bar.dart';
import '../widgets/transaction_tile.dart';
import 'detail_mbg_screen.dart';

class AllMbgScreen extends StatelessWidget {
  const AllMbgScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BackgroundKedua,
      body: Column(
        children: [
          const MbgAppBar(title: 'Semua Transaksi', showBack: true),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: TransactionService().stream(),
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(child: Text('Gagal memuat: ${snap.error}'));
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final list = snap.data!;
                if (list.isEmpty) {
                  return const Center(child: Text('Belum ada transaksi'));
                }
                return ListView.separated(
                  padding: const EdgeInsets.all(20),
                  itemCount: list.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, i) => TransactionTile(
                    trx: list[i],
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => DetailMbgScreen(trx: list[i]),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
