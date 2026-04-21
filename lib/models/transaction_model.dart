class TransactionModel {
  final String id;
  final double amount;
  final String type; // 'income' or 'expense'
  final String category;
  final String date;
  final String? note;
  final int synced;

  TransactionModel({
    required this.id,
    required this.amount,
    required this.type,
    required this.category,
    required this.date,
    this.note,
    this.synced = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'amount': amount,
      'type': type,
      'category': category,
      'date': date,
      'note': note,
      'synced': synced,
    };
  }

  factory TransactionModel.fromMap(Map<String, dynamic> map) {
    return TransactionModel(
      id: map['id'],
      amount: map['amount'],
      type: map['type'],
      category: map['category'],
      date: map['date'],
      note: map['note'],
      synced: map['synced'] ?? 0,
    );
  }
}
