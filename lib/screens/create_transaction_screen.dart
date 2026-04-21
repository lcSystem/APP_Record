import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../data/database_helper.dart';
import '../models/transaction_model.dart';

class CreateTransactionScreen extends StatefulWidget {
  const CreateTransactionScreen({super.key});

  @override
  State<CreateTransactionScreen> createState() => _CreateTransactionScreenState();
}

class _CreateTransactionScreenState extends State<CreateTransactionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _amountController = TextEditingController();
  final _noteController = TextEditingController();
  String _type = 'expense';
  String _category = 'Alimentación';
  bool _isLoading = false;

  final List<String> _categories = [
    'Alimentación',
    'Transporte',
    'Vivienda',
    'Salud',
    'Educación',
    'Entretenimiento',
    'Ingreso Laboral',
    'Venta/Negocio',
    'Otros'
  ];

  void _save() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      final tx = TransactionModel(
        id: const Uuid().v4(),
        amount: double.parse(_amountController.text),
        type: _type,
        category: _category,
        date: DateTime.now().toIso8601String(),
        note: _noteController.text,
      );

      await DatabaseHelper.instance.insertTransaction(tx);
      
      if (!mounted) return;
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Nuevo Registro'),
        backgroundColor: Colors.indigo,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'expense', label: Text('Gasto'), icon: Icon(Icons.remove_circle)),
                  ButtonSegment(value: 'income', label: Text('Ingreso'), icon: Icon(Icons.add_circle)),
                ],
                selected: {_type},
                onSelectionChanged: (Set<String> newSelection) {
                  setState(() => _type = newSelection.first);
                },
              ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Monto',
                  prefixIcon: Icon(Icons.attach_money),
                  border: OutlineInputBorder(),
                ),
                validator: (value) => (value == null || double.tryParse(value) == null) ? 'Monto inválido' : null,
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(
                  labelText: 'Categoría',
                  border: OutlineInputBorder(),
                ),
                items: _categories.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (value) => setState(() => _category = value!),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _noteController,
                decoration: const InputDecoration(
                  labelText: 'Nota (Opcional)',
                  prefixIcon: Icon(Icons.note),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.indigo,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                ),
                child: _isLoading ? const CircularProgressIndicator() : const Text('Guardar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
