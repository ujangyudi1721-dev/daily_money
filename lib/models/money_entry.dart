/// One money transaction : either income or expense.
class MoneyEntry {
  final String id;
  final String title;
  final double amount; // Always positif
  final bool isIncome; // True = income, False = Expense.
  final DateTime date;

  const MoneyEntry({
    required this.id,
    required this.title,
    required this.amount,
    required this.isIncome,
    required this.date,
  });

  /// Convert to a MAP so HIVE can save it.
  Map<String, dynamic> toMap() => {
    'id': id,
    'title': title,
    'amount': amount,
    'isIncome': isIncome,
    'date': date.toIso8601String(),
  };

  /// Create an entry back from a saved map.
  factory MoneyEntry.fromMap(Map map) => MoneyEntry(
    id: map['id'] as String,
    title: map['title'] as String,
    amount: (map['amount'] as num).toDouble(),
    isIncome: map['isIncome'] as bool,
    date: DateTime.parse(map['date'] as String),
  );
}
