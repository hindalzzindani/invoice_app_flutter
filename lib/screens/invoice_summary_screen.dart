import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../providers/invoice_provider.dart';

class InvoiceSummaryScreen extends ConsumerStatefulWidget {
  final List<InvoiceItem> items;
  final double totalQuantity;
  final double totalValue;

  const InvoiceSummaryScreen({
    super.key,
    required this.items,
    required this.totalQuantity,
    required this.totalValue,
  });

  @override
  ConsumerState<InvoiceSummaryScreen> createState() =>
      _InvoiceSummaryScreenState();
}

class _InvoiceSummaryScreenState extends ConsumerState<InvoiceSummaryScreen> {
  late double expenses;
  late double guardExpenses;
  late double rentExpenses;
  late double otherExpenses;
  
  late TextEditingController expensesController;
  late TextEditingController guardExpensesController;
  late TextEditingController rentExpensesController;
  late TextEditingController otherExpensesController;

  @override
  void initState() {
    super.initState();
    expenses = ref.read(expensesProvider);
    guardExpenses = ref.read(guardExpensesProvider);
    rentExpenses = ref.read(rentExpensesProvider);
    otherExpenses = ref.read(otherExpensesProvider);
    
    // إنشاء controllers مع القيم الأولية
    expensesController = TextEditingController(text: expenses.toInt().toString());
    guardExpensesController = TextEditingController(text: guardExpenses.toInt().toString());
    rentExpensesController = TextEditingController(text: rentExpenses.toInt().toString());
    otherExpensesController = TextEditingController(text: otherExpenses.toInt().toString());
  }

  @override
  void dispose() {
    expensesController.dispose();
    guardExpensesController.dispose();
    rentExpensesController.dispose();
    otherExpensesController.dispose();
    super.dispose();
  }

  Future<void> _shareInvoice() async {
    final marketing = expenses * 0.4;
    final totalExpenses =
        expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;

    final text = '''🧾 ملخص فاتورة المبيعات
━━━━━━━━━━━━━━━━━
${widget.items.asMap().entries.map((e) => '${e.key + 1}. الكمية: ${e.value.quantity} × السعر: ${e.value.price} = ${e.value.total.toStringAsFixed(2)}').join('\n')}
━━━━━━━━━━━━━━━━━
📦 إجمالي الكميات: ${widget.totalQuantity}
💰 إجمالي القيم: ${widget.totalValue.toStringAsFixed(2)}
📉 المصروفات: ${expenses.toStringAsFixed(2)}
🛡️ مصاريف حراسة: ${guardExpenses.toStringAsFixed(2)}
🏠 مصاريف إيجار: ${rentExpenses.toStringAsFixed(2)}
📦 مصاريف أخرى: ${otherExpenses.toStringAsFixed(2)}
🏷️ التسويق: ${marketing.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━
✅ الصافي النهائي: ${netTotal.toStringAsFixed(2)}''';

    await Share.share(text);
  }

  Future<void> _shareWhatsApp() async {
    final marketing = expenses * 0.4;
    final totalExpenses =
        expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;

    final text = '''🧾 ملخص فاتورة المبيعات
━━━━━━━━━━━━━━━━━
${widget.items.asMap().entries.map((e) => '${e.key + 1}. الكمية: ${e.value.quantity} × السعر: ${e.value.price} = ${e.value.total.toStringAsFixed(2)}').join('\n')}
━━━━━━━━━━━━━━━━━
📦 إجمالي الكميات: ${widget.totalQuantity}
💰 إجمالي القيم: ${widget.totalValue.toStringAsFixed(2)}
📉 المصروفات: ${expenses.toStringAsFixed(2)}
🛡️ مصاريف حراسة: ${guardExpenses.toStringAsFixed(2)}
🏠 مصاريف إيجار: ${rentExpenses.toStringAsFixed(2)}
📦 مصاريف أخرى: ${otherExpenses.toStringAsFixed(2)}
🏷️ التسويق: ${marketing.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━
✅ الصافي النهائي: ${netTotal.toStringAsFixed(2)}''';

    final encodedText = Uri.encodeComponent(text);
    final whatsappUrl = 'https://wa.me/?text=$encodedText';

    if (await canLaunchUrl(Uri.parse(whatsappUrl))) {
      await launchUrl(Uri.parse(whatsappUrl), mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('لم يتم العثور على واتس أب')),
        );
      }
    }
  }

  Future<void> _copyToClipboard() async {
    final marketing = expenses * 0.4;
    final totalExpenses =
        expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;

    final text = '''🧾 ملخص فاتورة المبيعات
━━━━━━━━━━━━━━━━━
${widget.items.asMap().entries.map((e) => '${e.key + 1}. الكمية: ${e.value.quantity} × السعر: ${e.value.price} = ${e.value.total.toStringAsFixed(2)}').join('\n')}
━━━━━━━━━━━━━━━━━
📦 إجمالي الكميات: ${widget.totalQuantity}
💰 إجمالي القيم: ${widget.totalValue.toStringAsFixed(2)}
📉 المصروفات: ${expenses.toStringAsFixed(2)}
🛡️ مصاريف حراسة: ${guardExpenses.toStringAsFixed(2)}
🏠 مصاريف إيجار: ${rentExpenses.toStringAsFixed(2)}
📦 مصاريف أخرى: ${otherExpenses.toStringAsFixed(2)}
🏷️ التسويق: ${marketing.toStringAsFixed(2)}
━━━━━━━━━━━━━━━━━
✅ الصافي النهائي: ${netTotal.toStringAsFixed(2)}''';

    await Clipboard.setData(ClipboardData(text: text));

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم نسخ الفاتورة إلى الحافظة'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final marketing = expenses * 0.4;
    final totalExpenses =
        expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;

    return Scaffold(
      appBar: AppBar(
        title: const Text('ملخص الفاتورة'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.purple[900],
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            onPressed: _shareWhatsApp,
            icon: const Icon(Icons.share),
            tooltip: 'مشاركة عبر واتس أب',
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Items List
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'تفاصيل الأصناف',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...widget.items.asMap().entries.map((entry) {
                        final item = entry.value;
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'الكمية: ${item.quantity}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                  Text(
                                    'السعر: ${item.price}',
                                    style: const TextStyle(fontSize: 12),
                                  ),
                                ],
                              ),
                              Text(
                                item.total.toStringAsFixed(2),
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Totals
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildTotalRow(
                        'إجمالي الكميات',
                        widget.totalQuantity.toString(),
                        Colors.blue,
                      ),
                      const Divider(),
                      _buildTotalRow(
                        'إجمالي القيم',
                        widget.totalValue.toStringAsFixed(2),
                        Colors.amber,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Expenses Section
              Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'المصاريف',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildExpenseField(
                        'المصروفات',
                        expensesController,
                        (value) => setState(() => expenses = value),
                        Colors.red,
                      ),
                      const SizedBox(height: 12),
                      _buildExpenseField(
                        '🛡️ حراسة',
                        guardExpensesController,
                        (value) => setState(() => guardExpenses = value),
                        Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _buildExpenseField(
                        '🏠 إيجار',
                        rentExpensesController,
                        (value) => setState(() => rentExpenses = value),
                        Colors.blue,
                      ),
                      const SizedBox(height: 12),
                      _buildExpenseField(
                        '📦 أخرى',
                        otherExpensesController,
                        (value) => setState(() => otherExpenses = value),
                        Colors.purple,
                      ),
                      const SizedBox(height: 12),
                      _buildReadOnlyField(
                        '🏷️ التسويق (40%)',
                        marketing.toStringAsFixed(2),
                        Colors.orange,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Net Total
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.green[600]!, Colors.green[500]!],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    const Text(
                      'الصافي النهائي',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      netTotal.toStringAsFixed(2),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        final invoice = Invoice(
                          id: const Uuid().v4(),
                          invoiceNumber: 1,
                          items: widget.items,
                          totalQuantity: widget.totalQuantity,
                          totalValue: widget.totalValue,
                          expenses: expenses,
                          guardExpenses: guardExpenses,
                          rentExpenses: rentExpenses,
                          otherExpenses: otherExpenses,
                          marketing: marketing,
                          netTotal: netTotal,
                          createdDate: DateTime.now(),
                        );

                        ref.read(addInvoiceItemProvider.notifier).clearAll();
                        ref.invalidate(invoicesProvider);

                        final db = ref.read(databaseServiceProvider);
                        db.insertInvoice(invoice);

                        if (mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('تم حفظ الفاتورة بنجاح'),
                              backgroundColor: Colors.green,
                            ),
                          );
                          // العودة إلى قائمة الفواتير
                          Navigator.of(context).pushNamedAndRemoveUntil(
                            '/saved_invoices',
                            (route) => false,
                          );
                        }
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('حفظ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('نسخ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[600],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: _shareInvoice,
                icon: const Icon(Icons.share),
                label: const Text('مشاركة'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.purple[600],
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, Color color) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 14,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: _getColorShade(color, 700),
          ),
        ),
      ],
    );
  }

  Widget _buildExpenseField(
    String label,
    TextEditingController controller,
    Function(double) onChanged,
    Color color,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          controller: controller,
          onChanged: (val) {
            onChanged(double.tryParse(val) ?? 0);
          },
          inputFormatters: [
            FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
          ],
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 12,
              vertical: 12,
            ),
            hintText: '0',
          ),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: _getColorShade(color, 300)),
            borderRadius: BorderRadius.circular(8),
            color: _getColorShade(color, 50),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: _getColorShade(color, 700),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getColorShade(Color color, int shade) {
    if (color == Colors.red) return Colors.red[shade] ?? Colors.red;
    if (color == Colors.orange) return Colors.orange[shade] ?? Colors.orange;
    if (color == Colors.blue) return Colors.blue[shade] ?? Colors.blue;
    if (color == Colors.purple) return Colors.purple[shade] ?? Colors.purple;
    return color;
  }
}
