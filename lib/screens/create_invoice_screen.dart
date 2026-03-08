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
  late ScrollController _scrollController;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
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
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToNewRow() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final items = ref.watch(invoiceItemsProvider);
    final totalQuantity = ref.watch(totalQuantityProvider);
    final totalValue = ref.watch(totalValueProvider);
    final screenHeight = MediaQuery.of(context).size.height;

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
          Expanded(
            flex: 1,
            child: SingleChildScrollView(
              controller: _scrollController,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade100,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        textDirection: TextDirection.rtl,
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
                            textDirection: TextDirection.rtl,
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
          Container(
            constraints: BoxConstraints(
              maxHeight: screenHeight * 0.5,
              minHeight: screenHeight * 0.4,
            ),
            color: Colors.grey.shade50,
            child: KeyboardSection(
              activeFieldId: activeFieldId,
              activeFieldType: activeFieldType,
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
                final notifier = ref.read(addInvoiceItemProvider.notifier);

                // إضافة صف جديد
                notifier.addItem('', '');

                // جلب أحدث صف (آخر عنصر)
                final updatedItems = ref.read(invoiceItemsProvider);
                final newItem = updatedItems.last;

                // جعل الصف الجديد هو النشط
                setState(() {
                  activeFieldId = newItem.id;
                  activeFieldType = 'quantity'; // يبدأ بالكمية
                });

                _scrollToNewRow();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalCard(String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey.shade600,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
