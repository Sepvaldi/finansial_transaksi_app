import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../services/transaction_services.dart';
import '../utils/app_color.dart';
import '../utils/format_helper.dart';
import 'custom_input.dart';
import 'custom_snackbar.dart';

class AddTransactionSheet {
  static Future<void> show(BuildContext context, {required bool isIncome}) {
    return showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true, // agar sheet bisa naik saat keyboard muncul
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (_) => _SheetBody(isIncome: isIncome),
    );
  }
}

class _SheetBody extends StatefulWidget {
  final bool isIncome;
  const _SheetBody({required this.isIncome});

  @override
  State<_SheetBody> createState() => _SheetBodyState();
}

class _SheetBodyState extends State<_SheetBody> {
  final _amountC = TextEditingController();
  final _titleC = TextEditingController();
  final _service = TransactionService();
  String _category = Fmt.categories.first;
  bool _loading = false;
  String? _error;

  @override
  void dispose() {
    _amountC.dispose();
    _titleC.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleC.text.trim();
    final amount = Fmt.parseAmount(_amountC.text);
    if (amount <= 0 || title.isEmpty) {
      setState(
        () => _error = 'Isi nominal (lebih dari 0) dan keterangan dulu ya',
      );
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });
    final error = await _service.add(
      type: widget.isIncome ? 'income' : 'expense',
      title: title,
      amount: amount,
      category: _category,
    );
    if (!mounted) return;

    if (error != null) {
      setState(() {
        _loading = false;
        _error = error;
      });
      return;
    }
    // Snackbar ditampilkan dulu, baru sheet ditutup
    CustomSnackbar.show(
      context,
      widget.isIncome ? 'Pemasukan disimpan' : 'Pengeluaran disimpan',
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.isIncome ? AppColor.BackgroundUtama : AppColor.expense;
    return Padding(
      // viewInsets.bottom = tinggi keyboard, supaya form tidak tertutup
      padding: EdgeInsets.fromLTRB(
        24,
        12,
        24,
        24 + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 5,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.isIncome
                              ? AppColor.incomeSoft
                              : const Color(0xFFFFE0E0),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.isIncome
                              ? '+ Pemasukan MBG'
                              : '- Pengeluaran MBG',
                          style: TextStyle(
                            color: color,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        widget.isIncome
                            ? 'Tambah Pemasukan Baru'
                            : 'Catat Pengeluaran Baru',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    backgroundColor: AppColor.incomeSoft,
                  ),
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close, color: Colors.black),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _label('Nominal (Rp)'),
            CustomInput(
              controller: _amountC,
              hintText: '0',
              prefixIcon: Icons.payments_outlined,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              fillColor: AppColor.incomeSoft,
            ),
            const SizedBox(height: 12),
            _label('Keterangan / Nama Catatan'),
            CustomInput(
              controller: _titleC,
              hintText: 'Contoh: Belanja bahan dapur',
              prefixIcon: Icons.edit_note,
              fillColor: AppColor.incomeSoft,
            ),
            const SizedBox(height: 12),
            _label('Kategori'),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: Fmt.categories.map((c) {
                  final selected = _category == c;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(c),
                      avatar: Icon(
                        Fmt.categoryIcon(c),
                        size: 16,
                        color: selected ? Colors.white : Colors.black54,
                      ),
                      selected: selected,
                      showCheckmark: false,
                      selectedColor: AppColor.deepGreen,
                      backgroundColor: AppColor.incomeSoft,
                      labelStyle: TextStyle(
                        color: selected ? Colors.white : Colors.black,
                      ),
                      onSelected: (_) => setState(() => _category = c),
                    ),
                  );
                }).toList(),
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  style: const TextStyle(color: AppColor.expense),
                ),
              ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: _loading ? null : _save,
                icon: _loading
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.save_outlined),
                label: const Text('Simpan ke MBG'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColor.deepGreen,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(text, style: const TextStyle(fontWeight: FontWeight.w600)),
  );
}
