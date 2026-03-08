import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/invoice_provider.dart';
import '../widgets/invoice_item_row.dart';
import '../widgets/keyboard_section.dart';

class CreateInvoiceScreen extends ConsumerStatefulWidget {
  const CreateInvoiceScreen({super.key});

  @override
  ConsumerState<CreateInvoiceScreen> createState() =>
      _CreateInvoiceScreenState();
}

class _CreateInvoiceScreenState extends ConsumerState<CreateInvoiceScreen> {
  String? activeFieldId;
  String? activeFieldType;

  @override
  void initState() {
    super.initState();
    // إضافة صف أول تلقائياً عند فتح الشاشة
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final items = ref.read(invoiceItemsProvider);
      if (items.isEmpty) {
        ref.read(addInvoiceItemProvider.notifier).addItem('', '');
        setState(() {
          activeFieldId = ref.read(invoiceItemsProvider).first.id;
          activeFieldType = 'quantity';
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(invoiceItemsProvider);
    final totalQuantity = ref.watch(totalQuantityProvider);
    final totalValue = ref.watch(totalValueProvider);
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      appBar: AppBar(
        title: const Text('إنشاء فاتورة جديدة'),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.blue.shade900,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // النصف العلوي - الصفوف والإجمالي
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // رأس الجدول
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          SizedBox(
                            width: 30,
                            child: Text(
                              '#',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'الكمية',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'السعر',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          Expanded(
                            flex: 2,
                            child: Text(
                              'القيمة',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue.shade900,
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          SizedBox(
                            width: 30,
                            child: Icon(
                              Icons.delete,
                              size: 16,
                              color: Colors.blue.shade900,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    // الصفوف
                    if (items.isEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 32.0),
                        child: Center(
                          child: Text(
                            'لا توجد أصناف بعد',
                            style: TextStyle(
                              color: Colors.grey.shade600,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      )
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: items.length,
                        itemBuilder: (context, index) {
                          final item = items[index];
                          return InvoiceItemRow(
                            item: item,
                            index: index + 1,
                            isActive: activeFieldId == item.id,
                            onQuantityTap: () {
                              setState(() {
                                activeFieldId = item.id;
                                activeFieldType = 'quantity';
                              });
                            },
                            onPriceTap: () {
                              setState(() {
                                activeFieldId = item.id;
                                activeFieldType = 'price';
                              });
                            },
                            onDelete: () {
                              ref
                                  .read(addInvoiceItemProvider.notifier)
                                  .removeItem(item.id);
                              setState(() {
                                activeFieldId = null;
                                activeFieldType = null;
                              });
                            },
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    // الإجمالي
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.1),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              Flexible(
                                child: _buildTotalCard(
                                  'إجمالي الكميات',
                                  totalQuantity.toStringAsFixed(2),
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 8),
                              Flexible(
                                child: _buildTotalCard(
                                  'إجمالي القيم',
                                  totalValue.toStringAsFixed(2),
                                  Colors.amber,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: items.isEmpty
                                ? null
                                : () {
                                    Navigator.pushNamed(
                                      context,
                                      '/invoice_summary',
                                      arguments: {
                                        'items': items,
                                        'totalQuantity': totalQuantity,
                                        'totalValue': totalValue,
                                      },
                                    );
                                  },
                            icon: const Icon(Icons.arrow_forward),
                            label: const Text('ملخص الفاتورة'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.green.shade600,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              minimumSize: const Size(double.infinity, 48),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          // النصف السفلي - الحاسبة (ثابتة)
          Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.5,
              minHeight: screenHeight * 0.4,
            ),
            color: Colors.grey.shade50,
            child: KeyboardSection(
              onQuantityInput: (value) {
                if (activeFieldId != null) {
                  final item = items.firstWhere((i) => i.id == activeFieldId);
                  ref
                      .read(addInvoiceItemProvider.notifier)
                      .updateItem(activeFieldId!, value, item.price);
                }
              },
              onPriceInput: (value) {
                if (activeFieldId != null) {
                  final item = items.firstWhere((i) => i.id == activeFieldId);
                  ref
                      .read(addInvoiceItemProvider.notifier)
                      .updateItem(activeFieldId!, item.quantity, value);
                }
              },
              onAddNewRow: () {
                ref.read(addInvoiceItemProvider.notifier).addItem('', '');
                setState(() {
                  if (items.isNotEmpty) {
                    activeFieldId = items.last.id;
                    activeFieldType = 'quantity';
                  }
                });
              },
              activeFieldType: activeFieldType,
              activeFieldId: activeFieldId,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 11,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color, width: 2),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 14,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
