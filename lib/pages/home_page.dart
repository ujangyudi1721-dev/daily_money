import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/money_entry.dart';
import '../services/money_service.dart';
import 'add_entry_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime _day = DateTime.now(); // the day we are looking at

  final NumberFormat _money = NumberFormat.currency(
    locale: 'id_ID',
    symbol: 'Rp ',
    decimalDigits: 0,
  );

  /// Move to the previous day (-1) or the next day (+1).
  void _changeDay(int offset) {
    setState(() => _day = _day.add(Duration(days: offset)));
  }

  Future<void> _openAddPage() async {
    final saved = await Navigator.push<bool>(
      context,
      MaterialPageRoute(builder: (_) => AddEntryPage(day: _day)),
    );
    if (saved == true) setState(() {}); // refresh the list
  }

  Future<void> _delete(MoneyEntry entry) async {
    await MoneyService.delete(entry.id);
    setState(() {});
  }

  Widget _summaryItem(String label, double value, Color color) {
    return Column(
      children: [
        Text(label),
        const SizedBox(height: 4),
        Text(
          _money.format(value),
          style: TextStyle(fontWeight: FontWeight.bold, color: color),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final entries = MoneyService.getForDay(_day);

    final income = entries
        .where((e) => e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final expense = entries
        .where((e) => !e.isIncome)
        .fold<double>(0, (sum, e) => sum + e.amount);
    final balance = income - expense;

    return Scaffold(
      appBar: AppBar(title: const Text('Daily Money')),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openAddPage,
        icon: const Icon(Icons.add),
        label: const Text('Tambah'),
      ),
      body: Column(
        children: [
          // Date selector
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: const Icon(Icons.chevron_left),
                onPressed: () => _changeDay(-1),
              ),
              Text(
                DateFormat('EEEE, d MMM y').format(_day),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              IconButton(
                icon: const Icon(Icons.chevron_right),
                onPressed: () => _changeDay(1),
              ),
            ],
          ),

          // Daily summary card
          Card(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Text('Saldo hari ini'),
                  const SizedBox(height: 4),
                  Text(
                    _money.format(balance),
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: balance >= 0 ? Colors.green : Colors.red,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _summaryItem('Pemasukan', income, Colors.green),
                      _summaryItem('Pengeluaran', expense, Colors.red),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // List of transactions
          Expanded(
            child: entries.isEmpty
                ? const Center(child: Text('Belum ada transaksi hari ini.'))
                : ListView.builder(
                    itemCount: entries.length,
                    itemBuilder: (context, index) {
                      final e = entries[index];
                      return ListTile(
                        leading: CircleAvatar(
                          backgroundColor: e.isIncome
                              ? Colors.green.shade100
                              : Colors.red.shade100,
                          child: Icon(
                            e.isIncome
                                ? Icons.arrow_downward
                                : Icons.arrow_upward,
                            color: e.isIncome ? Colors.green : Colors.red,
                          ),
                        ),
                        title: Text(e.title),
                        subtitle: Text(DateFormat('HH:mm').format(e.date)),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${e.isIncome ? '+' : '-'}${_money.format(e.amount)}',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: e.isIncome ? Colors.green : Colors.red,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete_outline),
                              onPressed: () => _delete(e),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}