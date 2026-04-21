import 'package:flutter/material.dart';
import '../data/database_helper.dart';
import '../models/transaction_model.dart';

class FinancialDashboard extends StatefulWidget {
  const FinancialDashboard({super.key});

  @override
  State<FinancialDashboard> createState() => _FinancialDashboardState();
}

class _FinancialDashboardState extends State<FinancialDashboard> {
  double _balance = 0;
  double _income = 0;
  double _expenses = 0;
  List<TransactionModel> _recentTransactions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    final summary = await DatabaseHelper.instance.getFinancialSummary();
    final transactions = await DatabaseHelper.instance.getAllTransactions();

    setState(() {
      _balance = summary['balance'] ?? 0;
      _income = summary['totalIncome'] ?? 0;
      _expenses = summary['totalExpense'] ?? 0;
      _recentTransactions = transactions.take(5).toList();
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mi Gemelo Financiero'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadData,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildBalanceCard(),
                  const SizedBox(height: 24),
                  Row(
                    children: [
                      Expanded(child: _buildStatCard('Ingresos', _income, Colors.green, Icons.arrow_upward)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildStatCard('Gastos', _expenses, Colors.red, Icons.arrow_downward)),
                    ],
                  ),
                  const SizedBox(height: 32),
                  const Text(
                    'Registros Recientes',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  if (_recentTransactions.isEmpty)
                    const Center(child: Text('No hay transacciones aún'))
                  else
                    ..._recentTransactions.map((tx) => _buildTransactionItem(tx)),
                ],
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.indigo, Colors.indigo.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.indigo.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Balance Total',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 8),
          Text(
            '\$${_balance.toStringAsFixed(2)}',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 36,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String label, double amount, Color color, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.grey, fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            '\$${amount.toStringAsFixed(2)}',
            style: TextStyle(
              color: color,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTransactionItem(TransactionModel tx) {
    final isExpense = tx.type == 'expense';
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: isExpense ? Colors.red.shade50 : Colors.green.shade50,
          child: Icon(
            isExpense ? Icons.remove : Icons.add,
            color: isExpense ? Colors.red : Colors.green,
          ),
        ),
        title: Text(tx.category),
        subtitle: Text(tx.date.split('T')[0]),
        trailing: Text(
          '${isExpense ? '-' : '+'}\$${tx.amount.toStringAsFixed(2)}',
          style: TextStyle(
            color: isExpense ? Colors.red : Colors.green,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}
