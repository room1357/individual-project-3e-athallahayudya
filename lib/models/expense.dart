class Expense {
  final String id;
  final String title;
  final double amount;
  final String category;
  final DateTime date;
  final String description;

  Expense({
    required this.id,
    required this.title,
    required this.amount,
    required this.category,
    required this.date,
    required this.description,
  });

  // Getter untuk format tampilan mata uang
  String get formattedAmount => 'Rp ${amount.toStringAsFixed(0)}';

  // Getter untuk format tampilan tanggal
  String get formattedDate {
    return '${date.day}/${date.month}/${date.year}';
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'amount': amount,
        'category': category,
        'date': date.millisecondsSinceEpoch,
        'description': description,
      };

  factory Expense.fromJson(Map<String, dynamic> json) => Expense(
        id: json['id'] as String,
        title: json['title'] as String,
        amount: (json['amount'] as num).toDouble(),
        category: json['category'] as String,
        date: DateTime.fromMillisecondsSinceEpoch(json['date'] as int),
        description: json['description'] as String,
      );
}