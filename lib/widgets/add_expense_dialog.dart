// ...existing code...
import 'package:flutter/material.dart';
import '../models/expense.dart';

Future<Expense?> showAddExpenseDialog(BuildContext context, List<String> options, {Expense? initial}) {
  return showDialog<Expense?>(
    context: context,
    builder: (ctx) => _AddExpenseDialog(options: options, initial: initial),
  );
}

class _AddExpenseDialog extends StatefulWidget {
  final List<String> options;
  final Expense? initial;
  const _AddExpenseDialog({required this.options, this.initial});

  @override
  State<_AddExpenseDialog> createState() => _AddExpenseDialogState();
}

class _AddExpenseDialogState extends State<_AddExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _titleCtrl;
  late TextEditingController _amountCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _customCatCtrl;
  late DateTime _selectedDate;
  late List<String> _opts;
  String? _selectedCat;
  bool _useCustom = false;

  @override
  void initState() {
    super.initState();
    final initial = widget.initial;
    _titleCtrl = TextEditingController(text: initial?.title ?? '');
    _amountCtrl = TextEditingController(text: initial != null ? initial.amount.toStringAsFixed(0) : '');
    _descCtrl = TextEditingController(text: initial?.description ?? '');
    _customCatCtrl = TextEditingController(text: initial?.category ?? '');
    _selectedDate = initial?.date ?? DateTime.now();
    _opts = widget.options;
    _selectedCat = _opts.isNotEmpty ? _opts.first : null;
    if (initial != null) {
      // if initial category matches one of options -> select it, else use custom
      final match = _opts.firstWhere(
        (c) => c.toLowerCase() == initial.category.toLowerCase(),
        orElse: () => '',
      );
      if (match.isNotEmpty) {
        _selectedCat = match;
        _useCustom = false;
      } else {
        _useCustom = true;
        _customCatCtrl.text = initial.category;
      }
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _amountCtrl.dispose();
    _descCtrl.dispose();
    _customCatCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.initial != null;
    return AlertDialog(
      title: Text(isEditing ? 'Edit Pengeluaran' : 'Tambah Pengeluaran'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            TextFormField(
              controller: _titleCtrl,
              decoration: const InputDecoration(labelText: 'Judul'),
              validator: (v) => (v == null || v.trim().isEmpty) ? 'Judul wajib' : null,
            ),
            const SizedBox(height: 8),
            TextFormField(
              controller: _amountCtrl,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Jumlah (angka)'),
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Jumlah wajib';
                final n = double.tryParse(v.replaceAll(',', ''));
                if (n == null) return 'Masukkan angka valid';
                if (n <= 0) return 'Jumlah harus > 0';
                return null;
              },
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _useCustom ? 'Lainnya' : _selectedCat,
              items: [
                ..._opts.map((c) => DropdownMenuItem(value: c, child: Text(c))),
                const DropdownMenuItem(value: 'Lainnya', child: Text('Lainnya')),
              ],
              onChanged: (v) {
                if (v == null) return;
                setState(() {
                  if (v == 'Lainnya') {
                    _useCustom = true;
                  } else {
                    _useCustom = false;
                    _selectedCat = v;
                  }
                });
              },
              decoration: const InputDecoration(labelText: 'Kategori'),
              validator: (v) {
                if ((_useCustom && _customCatCtrl.text.trim().isEmpty) ||
                    (!_useCustom && (v == null || v.trim().isEmpty))) {
                  return 'Kategori wajib';
                }
                return null;
              },
            ),
            if (_useCustom) ...[
              const SizedBox(height: 8),
              TextFormField(
                controller: _customCatCtrl,
                decoration: const InputDecoration(labelText: 'Kategori (kustom)'),
                validator: (v) => (v == null || v.trim().isEmpty) ? 'Masukkan kategori' : null,
              ),
            ],
            const SizedBox(height: 8),
            TextFormField(
              controller: _descCtrl,
              decoration: const InputDecoration(labelText: 'Deskripsi (opsional)'),
              maxLines: 2,
            ),
            const SizedBox(height: 8),
            Row(children: [
              const Text('Tanggal: '),
              TextButton(
                onPressed: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _selectedDate,
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) setState(() => _selectedDate = picked);
                },
                child: Text('${_selectedDate.day.toString().padLeft(2, '0')}-${_selectedDate.month.toString().padLeft(2, '0')}-${_selectedDate.year}'),
              ),
            ]),
          ]),
        ),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(context, null), child: const Text('Batal')),
        ElevatedButton(
          onPressed: () {
            if (_formKey.currentState?.validate() ?? false) {
              final category = _useCustom ? _customCatCtrl.text.trim() : (_selectedCat ?? (_opts.isNotEmpty ? _opts.first : 'Lainnya'));
              final id = widget.initial?.id ?? DateTime.now().millisecondsSinceEpoch.toString();
              final parsedAmount = double.tryParse(_amountCtrl.text.replaceAll(',', '')) ?? 0;
              final result = Expense(
                id: id,
                title: _titleCtrl.text.trim(),
                amount: parsedAmount,
                category: category,
                date: _selectedDate,
                description: _descCtrl.text.trim(),
              );
              Navigator.pop(context, result);
            }
          },
          child: const Text('Simpan'),
        ),
      ],
    );
  }
}
// ...existing code...