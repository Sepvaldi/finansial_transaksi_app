import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/transaction_model.dart';
import '../services/transaction_services.dart';
import '../utils/app_color.dart';
import '../utils/format_helper.dart';
import '../widgets/add_transaction_sheet.dart';
import '../widgets/mbg_app_bar.dart';
import '../widgets/monthly_chart.dart';
import '../widgets/transaction_tile.dart';
import 'detail_mbg_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Stream dibuat sekali saja, supaya tidak "subscribe ulang" tiap rebuild
  late final Stream<List<TransactionModel>> _stream = TransactionService()
      .stream();

  int _sum(Iterable<TransactionModel> list, {required bool income}) => list
      .where((t) => t.isIncome == income)
      .fold<int>(0, (s, t) => s + t.amount);

  String get _name {
    final u = FirebaseAuth.instance.currentUser;
    final n = u?.displayName;
    if (n != null && n.isNotEmpty) return n;
    return u?.email?.split('@').first ?? 'User';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColor.BackgroundKedua,
      body: Column(
        children: [
          const MbgAppBar(title: 'Dashboard'),
          Expanded(
            child: StreamBuilder<List<TransactionModel>>(
              stream: _stream,
              builder: (context, snap) {
                if (snap.hasError) {
                  return Center(
                    child: Text(
                      'Gagal memuat data:\n${snap.error}',
                      textAlign: TextAlign.center,
                    ),
                  );
                }
                if (!snap.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final all = snap.data!;
                final now =
                    DateTime.now(); // "real time": selalu bulan sekarang

                // 1) Saldo = semua pemasukan - semua pengeluaran
                final balance =
                    _sum(all, income: true) - _sum(all, income: false);

                // 2) Ringkasan bulan ini
                final thisMonth = all
                    .where(
                      (t) =>
                          t.date.year == now.year && t.date.month == now.month,
                    )
                    .toList();

                // 3) Data bagan: 6 bulan terakhir (termasuk bulan ini)
                final months = List.generate(
                  6,
                  (i) => DateTime(now.year, now.month - 5 + i),
                );
                final incomes = <int>[];
                final expenses = <int>[];
                for (final m in months) {
                  final list = all.where(
                    (t) => t.date.year == m.year && t.date.month == m.month,
                  );
                  incomes.add(_sum(list, income: true));
                  expenses.add(_sum(list, income: false));
                }

                return SingleChildScrollView(
                  child: Column(
                    children: [
                      _header(balance),
                      // Trik lengkungan: wrapper hijau + isi abu-abu bersudut bulat
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
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text(
                                    'Ringkasan Bulan Ini',
                                    style: TextStyle(
                                      fontFamily: 'DaysOne',
                                      fontSize: 10,
                                    ),
                                  ),
                                  Flexible(
                                    child: Text(
                                      '${Fmt.monthYear(now)} - ${thisMonth.length} Transaksi',
                                      style: const TextStyle(fontSize: 8),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              _summaryCard(
                                'Pemasukan',
                                _sum(thisMonth, income: true),
                                AppColor.BackgroundUtama,
                                AppColor.incomeSoft,
                                Icons.arrow_downward,
                              ),
                              _summaryCard(
                                'Pengeluaran',
                                _sum(thisMonth, income: false),
                                AppColor.expense,
                                AppColor.expenseSoft,
                                Icons.arrow_upward,
                              ),
                              const SizedBox(height: 4),
                              MonthlyChart(
                                labels: months
                                    .map((m) => Fmt.monthShort(m.month))
                                    .toList(),
                                incomes: incomes,
                                expenses: expenses,
                              ),
                              const SizedBox(height: 24),
                              Row(
                                children: const [
                                  CircleAvatar(
                                    radius: 7,
                                    backgroundColor: AppColor.BackgroundUtama,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Riwayat Transaksi Terkini',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w900,
                                      fontSize: 18,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              if (all.isEmpty)
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 24),
                                  child: Center(
                                    child: Text(
                                      'Belum ada transaksi.\nTekan tombol Pemasukan atau Pengeluaran di atas.',
                                      textAlign: TextAlign.center,
                                    ),
                                  ),
                                )
                              else
                                ...all
                                    .take(4)
                                    .map(
                                      (t) => Padding(
                                        padding: const EdgeInsets.only(
                                          bottom: 12,
                                        ),
                                        child: TransactionTile(
                                          trx: t,
                                          onTap: () => Navigator.push(
                                            context,
                                            MaterialPageRoute(
                                              builder: (_) =>
                                                  DetailMbgScreen(trx: t),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                              Center(
                                child: TextButton(
                                  onPressed: () =>
                                      Navigator.pushNamed(context, '/all'),
                                  child: const Text(
                                    'Lihat Semua >',
                                    style: TextStyle(
                                      color: AppColor.BackgroundUtama,
                                      fontWeight: FontWeight.bold,
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

  Widget _header(int balance) {
    return Container(
      width: double.infinity,
      color: AppColor.BackgroundUtama,
      padding: const EdgeInsets.fromLTRB(25, 35, 25, 60),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Halo, $_name!',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontFamily: 'DaysOne',
            ),
          ),
          const Text(
            'How are u today? welcome to MBG',
            style: TextStyle(
              color: AppColor.incomeSoft,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 40),
          Center(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: const Color.fromRGBO(255, 255, 255, 0.25),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircleAvatar(
                        radius: 4,
                        backgroundColor: Colors.greenAccent,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'AKUN AKTIF . MBG',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontFamily: 'DaysOne',
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Total Saldo Dompet Anda',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontFamily: 'DaysOne',
                  ),
                ),
                Text(
                  Fmt.rupiahSigned(balance),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 27,
                    fontFamily: 'DaysOne',
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColor.BackgroundKedua,
              borderRadius: BorderRadius.circular(50),
            ),
            child: Row(
              children: [
                Expanded(
                  child: _actionButton(
                    label: 'Pemasukan',
                    icon: Icons.add,
                    bg: AppColor.BackgroundUtama,
                    fg: Colors.white,
                    iconBg: const Color.fromRGBO(255, 255, 255, 0.3),
                    isIncome: true,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _actionButton(
                    label: 'Pengeluaran',
                    icon: Icons.remove,
                    bg: AppColor.incomeSoft,
                    fg: AppColor.expense,
                    iconBg: AppColor.expense,
                    isIncome: false,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required String label,
    required IconData icon,
    required Color bg,
    required Color fg,
    required Color iconBg,
    required bool isIncome,
  }) {
    return Material(
      color: bg,
      borderRadius: BorderRadius.circular(30),
      elevation: isIncome ? 3 : 0,
      child: InkWell(
        borderRadius: BorderRadius.circular(30),
        onTap: () => AddTransactionSheet.show(context, isIncome: isIncome),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 12,
                backgroundColor: iconBg,
                child: Icon(icon, size: 14, color: Colors.white),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  color: fg,
                  fontFamily: 'DaysOne',
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _summaryCard(
    String label,
    int value,
    Color color,
    Color iconBg,
    IconData icon,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppColor.shadow,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontFamily: 'DaysOne', fontSize: 16),
                ),
                const SizedBox(height: 5),
                Text(
                  Fmt.rupiah(value),
                  style: TextStyle(
                    color: color,
                    fontSize: 20,
                    fontFamily: 'DaysOne',
                  ),
                ),
              ],
            ),
          ),
          CircleAvatar(
            radius: 18,
            backgroundColor: iconBg,
            child: Icon(icon, color: color, size: 20),
          ),
        ],
      ),
    );
  }
}
