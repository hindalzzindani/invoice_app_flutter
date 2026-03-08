import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:invoice_app_flutter/models/invoice.dart';
import 'package:uuid/uuid.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
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

  List<InvoiceItem> get groupedItems {
    final Map<String, double> grouped = {};

    for (var item in widget.items) {
      final price = item.price.isEmpty ? "0" : item.price;
      final quantity = double.tryParse(item.quantity) ?? 0.0;
      grouped[price] = (grouped[price] ?? 0.0) + quantity;
    }

    const uuid = Uuid();

    return grouped.entries.map((e) {
      final double price = double.tryParse(e.key) ?? 0.0;
      final double quantity = e.value;
      final double total = price * quantity;

      return InvoiceItem(
        id: uuid.v4(),
        quantity: quantity.toString(),
        price: price.toString(),
        total: total, // ✅ تم الحساب
      );
    }).toList();
  }
  @override
  void initState() {
    super.initState();
    expenses = ref.read(expensesProvider);
    guardExpenses = ref.read(guardExpensesProvider);
    rentExpenses = ref.read(rentExpensesProvider);
    otherExpenses = ref.read(otherExpensesProvider);

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

  String _generateInvoiceText() {
    final marketing = expenses * 0.4;
    final totalExpenses = expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;
    final items = groupedItems;

    return '''🧾 ملخص فاتورة المبيعات
━━━━━━━━━━━━━━━━━
${items.asMap().entries.map((e) => '${e.key + 1}. الكمية: ${e.value.quantity} × السعر: ${e.value.price} = ${e.value.total.toStringAsFixed(2)}').join('\n')}
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
  }

  Future<void> _shareInvoice() async {
    await Share.share(_generateInvoiceText());
  }

  Future<void> _shareWhatsApp() async {
    final text = _generateInvoiceText();
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
    await Clipboard.setData(ClipboardData(text: _generateInvoiceText()));
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
    final totalExpenses = expenses + guardExpenses + rentExpenses + otherExpenses + marketing;
    final netTotal = widget.totalValue - totalExpenses;
    final items = groupedItems;

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
                        'تفاصيل الأصناف (مجمعة حسب السعر)',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[800],
                        ),
                      ),
                      const SizedBox(height: 12),
                      ...items.asMap().entries.map((entry) {
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
                      _buildExpenseInput('المصروفات', expensesController, (val) {
                        setState(() {
                          expenses = val;
                          ref.read(expensesProvider.notifier).state = val;
                        });
                      }),
                      _buildExpenseInput('مصاريف حراسة', guardExpensesController, (val) {
                        setState(() {
                          guardExpenses = val;
                          ref.read(guardExpensesProvider.notifier).state = val;
                        });
                      }),
                      _buildExpenseInput('مصاريف إيجار', rentExpensesController, (val) {
                        setState(() {
                          rentExpenses = val;
                          ref.read(rentExpensesProvider.notifier).state = val;
                        });
                      }),
                      _buildExpenseInput('مصاريف أخرى', otherExpensesController, (val) {
                        setState(() {
                          otherExpenses = val;
                          ref.read(otherExpensesProvider.notifier).state = val;
                        });
                      }),
                      const Divider(),
                      _buildTotalRow(
                        'التسويق (40% من المصروفات)',
                        marketing.toStringAsFixed(2),
                        Colors.orange,
                      ),
                      _buildTotalRow(
                        'إجمالي المصاريف',
                        totalExpenses.toStringAsFixed(2),
                        Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Card(
                color: Colors.green[50],
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.green.shade200, width: 2),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      const Text(
                        'الصافي النهائي',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        netTotal.toStringAsFixed(2),
                        style: TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _copyToClipboard,
                      icon: const Icon(Icons.copy),
                      label: const Text('نسخ'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey[200],
                        foregroundColor: Colors.black87,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: _shareInvoice,
                      icon: const Icon(Icons.share),
                      label: const Text('مشاركة'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                onPressed: () async {
                  final items = ref.read(invoiceItemsProvider);
                  final totalQty = ref.read(totalQuantityProvider);
                  final totalVal = ref.read(totalValueProvider);
                  final netTotal = ref.read(netTotalProvider);
                  final invoiceNumber = ref.read(invoiceNumberProvider);

                  final expenses = ref.read(expensesProvider);
                  final guardExpenses = ref.read(guardExpensesProvider);
                  final rentExpenses = ref.read(rentExpensesProvider);
                  final otherExpenses = ref.read(otherExpensesProvider);
                  final marketing = ref.read(marketingProvider);

                  final invoice = Invoice(
                    id: const Uuid().v4(),
                    invoiceNumber: invoiceNumber,
                    items: items,
                    totalQuantity: totalQty,
                    totalValue: totalVal,
                    expenses: expenses,
                    guardExpenses: guardExpenses,
                    rentExpenses: rentExpenses,
                    otherExpenses: otherExpenses,
                    marketing: marketing,
                    netTotal: netTotal,
                    createdDate: DateTime.now(),
                  );

                  await ref.read(saveInvoiceProvider(invoice).future);

                  ref.read(addInvoiceItemProvider.notifier).clearAll();

                  ref.read(expensesProvider.notifier).state = 0;
                  ref.read(guardExpensesProvider.notifier).state = 0;
                  ref.read(rentExpensesProvider.notifier).state = 0;
                  ref.read(otherExpensesProvider.notifier).state = 0;

                  ref.read(invoiceNumberProvider.notifier).state++;

                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('✅ تم حفظ الفاتورة بنجاح'),
                        duration: Duration(seconds: 2),
                      ),
                    );

                    Navigator.pushNamedAndRemoveUntil(
                      context,
                      '/saved_invoices',
                          (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('إتمام وحفظ الفاتورة'),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExpenseInput(String label, TextEditingController controller, Function(double) onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        children: [
          Expanded(
            flex: 3,
            child: Text(label, style: const TextStyle(fontSize: 14)),
          ),
          Expanded(
            flex: 2,
            child: TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              decoration: const InputDecoration(
                isDense: true,
                contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                final doubleVal = double.tryParse(value) ?? 0.0;
                onChanged(doubleVal);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}
