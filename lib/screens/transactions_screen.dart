import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/transaction_model.dart';
import 'create_transaction_screen.dart';

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  List<TransactionModel> _transactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    setState(() => _isLoading = true);
    final transactions = await DatabaseHelper.instance.getAllTransactions();
    setState(() {
      _transactions = transactions;
      _isLoading = false;
    });
  }

  void _addTransaction() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const CreateTransactionScreen()),
    );
    if (result == true) {
      _loadTransactions();
    }
  }

  void _deleteTransaction(String id) async {
    await DatabaseHelper.instance.deleteTransaction(id);
    _loadTransactions();
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Registro eliminado')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Registros Financieros'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _transactions.isEmpty
              ? const Center(child: Text('Presiona + para añadir un registro'))
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final tx = _transactions[index];
                    final isExpense = tx.type == 'expense';
                    return Card(
                      child: ListTile(
                        leading: Icon(
                          isExpense ? Icons.remove_circle : Icons.add_circle,
                          color: isExpense ? Colors.red : Colors.green,
                        ),
                        title: Text(tx.category),
                        subtitle: Text('${tx.date.split('T')[0]} - ${tx.note ?? ""}'),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '\$${tx.amount.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: isExpense ? Colors.red : Colors.green,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.grey),
                              onPressed: () => _deleteTransaction(tx.id),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addTransaction,
        backgroundColor: Colors.indigo,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
