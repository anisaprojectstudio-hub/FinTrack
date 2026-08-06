import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/categories.dart';
import '../../../transaction/presentation/providers/transaction_providers.dart';
import '../../domain/entities/budget_entity.dart';
import '../providers/budget_providers.dart';

/// [existing] terisi berarti mode edit (kategori terkunci, hanya limit
/// yang bisa diubah); null berarti mode tambah (pilih kategori dulu).
class AddBudgetPage extends ConsumerStatefulWidget {
  final BudgetEntity? existing;
  const AddBudgetPage({super.key, this.existing});

  @override
  ConsumerState<AddBudgetPage> createState() => _AddBudgetPageState();
}

class _AddBudgetPageState extends ConsumerState<AddBudgetPage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _limitController;
  String? _category;

  bool get _isEdit => widget.existing != null;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _limitController = TextEditingController(
        text: e != null ? e.limitAmount.toStringAsFixed(0) : '');
    _category = e?.category;
  }

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
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
    final month = ref.read(selectedMonthKeyProvider);
    if (userId == null) return;

    final controller = ref.read(budgetFormControllerProvider.notifier);
    final bool success;

    if (_isEdit) {
      final updated = BudgetEntity(
        id: widget.existing!.id,
        userId: userId,
        category: widget.existing!.category,
        limitAmount: double.parse(_limitController.text),
        month: widget.existing!.month,
      );
      success = await controller.updateBudget(updated);
    } else {
      final newBudget = BudgetEntity(
        id: '',
        userId: userId,
        category: _category!,
        limitAmount: double.parse(_limitController.text),
        month: month,
      );
      success = await controller.add(newBudget);
    }

    if (success && mounted) {
      Navigator.of(context).pop();
    } else if (mounted) {
      final error = ref.read(budgetFormControllerProvider);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content:
                Text(error.error?.toString() ?? 'Gagal menyimpan budget.')),
      );
    }
  }

  Future<void> _delete() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Hapus budget?'),
        content: Text(
            'Budget untuk kategori ${widget.existing!.category} akan dihapus.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Batal')),
          TextButton(
              onPressed: () => Navigator.pop(ctx, true),
              child: const Text('Hapus')),
        ],
      ),
    );
    if (confirmed != true) return;

    final deleteController = ref.read(deleteBudgetControllerProvider.notifier);
    final success = await deleteController.delete(widget.existing!.id);
    if (success && mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(budgetFormControllerProvider);
    // Kategori yang sudah punya budget bulan ini tidak ditawarkan lagi
    // (aturan "satu kategori satu budget per bulan" dari Tahap 3).
    final existingCategories =
        (ref.watch(budgetsStreamProvider).valueOrNull ?? [])
            .map((b) => b.category)
            .toSet();
    final availableCategories = AppCategories.expense
        .where((c) => _isEdit || !existingCategories.contains(c))
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEdit ? 'Ubah Budget' : 'Tambah Budget'),
        actions: [
          if (_isEdit)
            IconButton(
                icon: const Icon(Icons.delete_outline), onPressed: _delete),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('Kategori', style: Theme.of(context).textTheme.labelLarge),
                const SizedBox(height: 8),
                if (_isEdit)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: Icon(AppCategories.iconFor(_category!)),
                    title: Text(_category!),
                    subtitle: const Text(
                        'Kategori tidak bisa diubah — hapus & buat baru kalau salah'),
                  )
                else
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: availableCategories.map((c) {
                      final selected = c == _category;
                      return ChoiceChip(
                        label: Text(c),
                        avatar: Icon(AppCategories.iconFor(c), size: 16),
                        selected: selected,
                        onSelected: (_) => setState(() => _category = c),
                      );
                    }).toList(),
                  ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: _limitController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                      labelText: 'Limit Bulanan', prefixText: 'Rp '),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Limit wajib diisi';
                    final parsed = double.tryParse(v);
                    if (parsed == null || parsed <= 0)
                      return 'Limit tidak valid';
                    return null;
                  },
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
