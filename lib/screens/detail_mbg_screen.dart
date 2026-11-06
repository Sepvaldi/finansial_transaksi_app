import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/transaction_model.dart';
import '../services/transaction_services.dart';
import '../utils/app_color.dart';
import '../utils/format_helper.dart';
import '../widgets/custom_dialog.dart';
import '../widgets/custom_input.dart';
import '../widgets/custom_snackbar.dart';
import '../widgets/mbg_app_bar.dart';

class DetailMbgScreen extends StatefulWidget {
  final TransactionModel trx;
  const DetailMbgScreen({super.key, required this.trx});

  @override
  State<DetailMbgScreen> createState() => _DetailMbgScreenState();
}

class _DetailMbgScreenState extends State<DetailMbgScreen> {
  final _service = TransactionService();
  late final _titleC = TextEditingController(text: widget.trx.title);
  late final _amountC = TextEditingController(
    text: widget.trx.amount.toString(),
  );
  late String _type = widget.trx.type;
  bool _loading = false;

  @override
  void dispose() {
    _titleC.dispose();
    _amountC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleC.text.trim();
    final amount = Fmt.parseAmount(_amountC.text);
    if (title.isEmpty || amount <= 0) {
      CustomSnackbar.show(
        context,
        'Keterangan dan nominal wajib diisi',
        isError: true,
      );
      return;
    }

    setState(() => _loading = true);
    final error = await _service.update(
      widget.trx.id,
      type: _type,
      title: title,
      amount: amount,
    );
    if (!mounted) return;
    setState(() => _loading = false);

    if (error != null) {
      CustomSnackbar.show(context, error, isError: true);
      return;
    }
    CustomSnackbar.show(context, 'Perubahan disimpan');
    Navigator.pop(context); // kembali; dashboard otomatis update lewat stream
  }

  Future<void> _delete() async {
    final yes = await CustomDialog.confirmDelete(context);
    if (!yes || !mounted) return;

    final error = await _service.delete(widget.trx.id);
    if (!mounted) return;
    if (error != null) {
      CustomSnackbar.show(context, error, isError: true);
      return;
    }
    CustomSnackbar.show(context, 'Transaksi dihapus');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.trx;
    return Scaffold(
      backgroundColor: AppColor.BackgroundKedua,
      body: Column(
        children: [
          const MbgAppBar(title: 'Detail Transaksi', showBack: true),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // Header hijau: nominal, keterangan, label tipe
                  Container(
                    width: double.infinity,
                    color: AppColor.BackgroundUtama,
                    padding: const EdgeInsets.fromLTRB(24, 24, 24, 40),
                    child: Column(
                      children: [
                        Text(
                          Fmt.signed(t),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 34,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          t.title,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color: t.isIncome
                                ? AppColor.deepGreen
                                : const Color(0xFFCC0000),
                            borderRadius: BorderRadius.circular(20),
                            boxShadow: AppColor.shadow,
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                t.isIncome
                                    ? Icons.south_west
                                    : Icons.north_east,
                                color: Colors.white,
                                size: 18,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                t.isIncome ? 'Pemasukan' : 'Pengeluaran',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    color: AppColor.BackgroundKedua,
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(28, 28, 28, 40),
                      decoration: const BoxDecoration(
                        color: AppColor.BackgroundKedua,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(50),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const CircleAvatar(
                                radius: 10,
                                backgroundColor: AppColor.BackgroundUtama,
                              ),
                              const SizedBox(width: 8),
                              const Expanded(
                                child: Text(
                                  'Edit Detail Transaksi',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: const Color(0xFF99FF99),
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: const Text(
                                  'Mode Edit',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _label('Tipe Keuangan'),
                          Row(
                            children: [
                              _typeChip('Pemasukan', 'income', AppColor.BackgroundUtama),
                              const SizedBox(width: 8),
                              _typeChip(
                                'Pengeluaran',
                                'expense',
                                AppColor.BackgroundKedua,
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                          _label('Keterangan Transaksi'),
                          CustomInput(
                            controller: _titleC,
                            hintText: 'Keterangan transaksi',
                            prefixIcon: Icons.edit_note,
                          ),
                          const SizedBox(height: 16),
                          _label('Nominal (Rupiah)'),
                          CustomInput(
                            controller: _amountC,
                            hintText: '0',
                            prefixIcon: Icons.payments_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                          ),
                          const SizedBox(height: 28),
                          Center(
                            child: SizedBox(
                              width: 260,
                              height: 48,
                              child: ElevatedButton.icon(
                                onPressed: _loading ? null : _save,
                                icon: const Icon(
                                  Icons.check_circle_outline,
                                  size: 18,
                                ),
                                label: const Text('Simpan Perubahan'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColor.deepGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(30),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Center(
                            child: ElevatedButton.icon(
                              onPressed: _loading ? null : _delete,
                              icon: const Icon(Icons.delete_outline, size: 18),
                              label: const Text('Hapus Transaksi'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColor.expenseSoft,
                                foregroundColor: AppColor.expense,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30),
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
            ),
          ),
        ],
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w600,
        color: Colors.black54,
      ),
    ),
  );

  Widget _typeChip(String label, String value, Color color) {
    final selected = _type == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      showCheckmark: false,
      selectedColor: color,
      backgroundColor: Colors.white,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black,
        fontWeight: FontWeight.bold,
      ),
      onSelected: (_) => setState(() => _type = value),
    );
  }
}
