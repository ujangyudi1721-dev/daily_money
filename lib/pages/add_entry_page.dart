import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../models/money_entry.dart';
import '../services/money_service.dart';

class AddEntryPage extends StatefulWidget {
  final DateTime day;

  const AddEntryPage({super.key, required this.day});

  @override
  State<AddEntryPage> createState() => _AddEntryPageState();
}

class _AddEntryPageState extends State<AddEntryPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  bool _isIncome = false;

  @override
  void dispose() {
    _titleController.dispose();
    _amountController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final title = _titleController.text.trim();
    final amount = double.tryParse(_amountController.text.trim());

    if (title.isEmpty || amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Isi judul dan nominal dengan benar.')),
      );
      return;
    }

    final now = DateTime.now();
    final entry = MoneyEntry(
      id: now.microsecondsSinceEpoch.toString(),
      title: title,
      amount: amount,
      isIncome: _isIncome,
      date: DateTime(
        widget.day.year,
        widget.day.month,
        widget.day.day,
        now.hour,
        now.minute,
      ),
    );

    await MoneyService.add(entry);
    if (!mounted) return;
    Navigator.pop(context, true); // go back and say "saved"
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah transaksi')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SegmentedButton<bool>(
            segments: const [
              ButtonSegment(
                value: false,
                label: Text('Pengeluaran'),
                icon: Icon(Icons.arrow_upward),
              ),
              ButtonSegment(
                value: true,
                label: Text('Pemasukan'),
                icon: Icon(Icons.arrow_downward),
              ),
            ],
            selected: {_isIncome},
            onSelectionChanged: (s) => setState(() => _isIncome = s.first),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _titleController,
            decoration: const InputDecoration(
              labelText: 'Judul (contoh: Makan siang)',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _amountController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              labelText: 'Nominal',
              prefixText: 'Rp ',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 24),
          FilledButton(
            onPressed: _save,
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Text('Simpan'),
            ),
          ),
        ],
      ),
    );
  }
}