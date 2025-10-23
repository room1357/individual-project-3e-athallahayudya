import 'package:flutter/material.dart';
import '../models/expense.dart';
import '../widgets/add_expense_dialog.dart';
import '../widgets/expense_item.dart';
import '../util/shared_prefs_storage.dart';

class ExpenseListScreen extends StatefulWidget {
  const ExpenseListScreen({super.key});

  @override
  State<ExpenseListScreen> createState() => _ExpenseListScreenState();
}

class _ExpenseListScreenState extends State<ExpenseListScreen> {
  late List<Expense> expenses = [];
  String selectedCategory = 'Semua';
  final TextEditingController _searchCtrl = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadExpenses();
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExpenses() async {
    final loaded = await SharedPrefsStorage.loadAll();
    if (mounted) {
      setState(() {
        if (loaded.isNotEmpty) {
          expenses = loaded;
        } else {
          // sample awal jika belum ada data tersimpan
          expenses = [
            Expense(id: '1', title: 'Belanja Bulanan', amount: 150000, category: 'Makanan', date: DateTime(2024, 9, 15), description: 'Belanja kebutuhan bulanan di supermarket'),
            Expense(id: '2', title: 'Bensin Motor', amount: 50000, category: 'Transportasi', date: DateTime(2024, 9, 14), description: 'Isi bensin motor untuk transportasi'),
          ];
        }
      });
    }
  }

  List<String> get categories {
    final cats = expenses.map((e) => e.category).toSet().toList();
    cats.sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return ['Semua', ...cats];
  }

  List<Expense> get filteredExpenses {
    final q = _searchCtrl.text.trim().toLowerCase();
    return expenses.where((e) {
      final matchesCategory = selectedCategory == 'Semua' || e.category.toLowerCase() == selectedCategory.toLowerCase();
      final matchesQuery = q.isEmpty || e.title.toLowerCase().contains(q) || e.description.toLowerCase().contains(q) || e.category.toLowerCase().contains(q);
      return matchesCategory && matchesQuery;
    }).toList();
  }

  Future<void> _onAddPressed() async {
    var opts = categories.where((c) => c.toLowerCase() != 'semua').toList();
    if (opts.isEmpty) opts = ['Makanan', 'Transportasi', 'Utilitas', 'Hiburan', 'Pendidikan'];

    final newExpense = await showAddExpenseDialog(context, opts);
    if (newExpense != null) {
      await SharedPrefsStorage.addExpense(newExpense);
      if (mounted) setState(() => expenses.insert(0, newExpense));
    }
  }

  String _calculateTotal(List<Expense> list) {
    final total = list.fold<double>(0, (sum, e) => sum + e.amount);
    return 'Rp ${total.toStringAsFixed(0)}';
  }

  @override
  Widget build(BuildContext context) {
    final visible = filteredExpenses;

    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Pengeluaran'), backgroundColor: Colors.blue),
      body: Column(children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.blue.shade50, border: Border(bottom: BorderSide(color: Colors.blue.shade200))),
          child: Column(children: [
            Text('Total Pengeluaran', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
            Text(_calculateTotal(visible), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.blue)),
            const SizedBox(height: 8),
            TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Cari judul / deskripsi / kategori...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _searchCtrl.text.isNotEmpty ? IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(() => _searchCtrl.clear())) : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 8),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(children: categories.map((cat) {
                final isSelected = selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: isSelected ? Colors.blue : Colors.grey[200], foregroundColor: isSelected ? Colors.white : Colors.black),
                    onPressed: () => setState(() => selectedCategory = cat),
                    child: Text(cat),
                  ),
                );
              }).toList()),
            ),
          ]),
        ),
        Expanded(
          child: visible.isEmpty
              ? Center(child: Text('Tidak ada pengeluaran', style: TextStyle(color: Colors.grey[600])))
              : ListView.builder(
                  padding: const EdgeInsets.all(8),
                  itemCount: visible.length,
                  itemBuilder: (context, index) {
                    final expense = visible[index];
                    return ExpenseItem(
                      expense: expense,
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (_) => AlertDialog(
                            title: Text(expense.title),
                            content: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                              Text('Jumlah: ${expense.formattedAmount}'),
                              const SizedBox(height: 8),
                              Text('Kategori: ${expense.category}'),
                              const SizedBox(height: 8),
                              Text('Tanggal: ${expense.formattedDate}'),
                              const SizedBox(height: 8),
                              Text('Deskripsi: ${expense.description}'),
                            ]),
                            actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Tutup'))],
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(onPressed: _onAddPressed, backgroundColor: Colors.blue, child: const Icon(Icons.add)),
    );
  }
}