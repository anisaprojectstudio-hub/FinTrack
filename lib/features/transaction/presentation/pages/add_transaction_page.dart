import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/transaction_entity.dart';
import '../providers/transaction_providers.dart';
import '../widgets/category_grid_picker.dart';
import '../widgets/type_segmented_control.dart';

/// Form yang sama dipakai untuk Tambah (existing == null) dan Ubah
/// (existing terisi) — sesuai keputusan Tahap 2.
class AddTransactionPage extends ConsumerStatefulWidget {
  final TransactionEntity? existing;
  const AddTransactionPage({super.key, this.existing});

  @override
  ConsumerState<AddTransactionPage> createState() => _AddTransactionPageState();
}

class _AddTransactionPageState extends ConsumerState<AddTransactionPage> {
  final _formKey = GlobalKey<FormState>();
  late TransactionType _type;
  late TextEditingController _amountController;
  late TextEditingController _noteController;
  String? _category;
  late DateTime _date;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _type = e?.type ?? TransactionType.expense;
    _amountController = TextEditingController(
        text: e != null ? e.amount.toStringAsFixed(0) : '');
    _noteController = TextEditingController(text: e?.description ?? '');
    _category = e?.category;
    _date = e?.date ?? DateTime.now();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_category == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Pilih kategori dulu ya')),
      );
      return;
    }

    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;

    final transaction = TransactionEntity(
      id: widget.existing?.id ?? '',
      userId: userId,
      amount: double.parse(_amountController.text),
      type: _type,
      category: _category!,
      description: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
      date: _date,
    );

    final controller = ref.read(transactionFormControllerProvider.notifier);
    final success = await controller.save(transaction, isEdit: _isEdit);

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      final error = ref.read(transactionFormControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(error.error?.toString() ?? 'Gagal menyimpan transaksi.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(transactionFormControllerProvider);

    return Scaffold(
      appBar:
          AppBar(title: Text(_isEdit ? 'Ubah Transaksi' : 'Tambah Transaksi')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TypeSegmentedControl(
                  value: _type,
                  onChanged: (t) => setState(() {
                    _type = t;
                    _category = null; // kategori beda antara income/expense
                  }),
                ),
                const SizedBox(height: 20),
                // Input nominal dibuat besar & jadi fokus utama (target Tahap 4:
                // maksimal 3 tap dari dashboard sampai transaksi tersimpan).
                TextFormField(
                  controller: _amountController,
                  autofocus: !_isEdit,
                  keyboardType: TextInputType.number,
                  style: Theme.of(context).textTheme.headlineMedium,
                  textAlign: TextAlign.center,
                  decoration: const InputDecoration(
                      prefixText: 'Rp ', border: InputBorder.none),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Nominal wajib diisi';
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0)
                      return 'Nominal tidak valid';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                CategoryGridPicker(
                  type: _type,
                  selected: _category,
                  onSelected: (c) => setState(() => _category = c),
                ),
                const SizedBox(height: 20),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(Icons.calendar_today_outlined),
                  title: Text('${_date.day}/${_date.month}/${_date.year}'),
                  onTap: _pickDate,
                ),
                TextFormField(
                  controller: _noteController,
                  decoration:
                      const InputDecoration(labelText: 'Catatan (opsional)'),
                ),
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: state.isLoading ? null : _submit,
                  child: state.isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                              strokeWidth: 2, color: Colors.white),
                        )
                      : Text(_isEdit ? 'Simpan Perubahan' : 'Simpan'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
