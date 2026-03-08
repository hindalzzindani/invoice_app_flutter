import 'package:flutter/material.dart';

class KeyboardSection extends StatefulWidget {
  final Function(String) onQuantityInput;
  final Function(String) onPriceInput;
  final VoidCallback onAddNewRow;
  final String? activeFieldType;
  final String? activeFieldId;

  const KeyboardSection({
    super.key,
    required this.onQuantityInput,
    required this.onPriceInput,
    required this.onAddNewRow,
    this.activeFieldType,
    this.activeFieldId,
  });

  @override
  State<KeyboardSection> createState() => _KeyboardSectionState();
}

class _KeyboardSectionState extends State<KeyboardSection> {
  String quantityInput = '';
  String priceInput = '';

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Container(
        color: Colors.grey.shade50,
        padding: const EdgeInsets.all(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // عرض القيم المدخلة
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.activeFieldType == 'quantity'
                            ? Colors.amber.shade700
                            : Colors.amber.shade300,
                        width: widget.activeFieldType == 'quantity' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'الكمية',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.amber.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          quantityInput.isEmpty ? '0' : quantityInput,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: widget.activeFieldType == 'price'
                            ? Colors.blue.shade700
                            : Colors.blue.shade300,
                        width: widget.activeFieldType == 'price' ? 2 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'السعر',
                          style: TextStyle(
                            fontSize: 10,
                            color: Colors.blue.shade700,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          priceInput.isEmpty ? '0' : priceInput,
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // الحاسبات
            Row(
              children: [
                // حاسبة الكمية (يمين)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'الكمية',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.amber.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.2,
                        children: [
                          ..._buildKeyboardButtons(
                            ['7', '8', '9', '4', '5', '6', '1', '2', '3', 'C', '0', '⌫'],
                            (value) {
                              setState(() {
                                if (value == 'C') {
                                  quantityInput = '';
                                } else if (value == '⌫') {
                                  if (quantityInput.isNotEmpty) {
                                    quantityInput = quantityInput.substring(
                                      0,
                                      quantityInput.length - 1,
                                    );
                                  }
                                } else {
                                  quantityInput += value;
                                }
                                widget.onQuantityInput(quantityInput);
                              });
                            },
                            Colors.amber,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                // حاسبة السعر (يسار)
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        'السعر',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      GridView.count(
                        crossAxisCount: 3,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 4,
                        crossAxisSpacing: 4,
                        childAspectRatio: 1.2,
                        children: [
                          ..._buildKeyboardButtons(
                            ['7', '8', '9', '4', '5', '6', '1', '2', '3', 'C', '0', '⌫'],
                            (value) {
                              setState(() {
                                if (value == 'C') {
                                  priceInput = '';
                                } else if (value == '⌫') {
                                  if (priceInput.isNotEmpty) {
                                    priceInput = priceInput.substring(
                                      0,
                                      priceInput.length - 1,
                                    );
                                  }
                                } else {
                                  priceInput += value;
                                }
                                widget.onPriceInput(priceInput);
                              });
                            },
                            Colors.blue,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            // زر صف جديد
            ElevatedButton.icon(
              onPressed: quantityInput.isEmpty || priceInput.isEmpty
                  ? null
                  : () {
                      widget.onAddNewRow();
                      setState(() {
                        quantityInput = '';
                        priceInput = '';
                      });
                    },
              icon: const Icon(Icons.add),
              label: const Text('صف جديد'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.purple.shade600,
                foregroundColor: Colors.white,
                disabledBackgroundColor: Colors.grey.shade300,
                minimumSize: const Size(double.infinity, 40),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildKeyboardButtons(
    List<String> keys,
    Function(String) onTap,
    Color color,
  ) {
    return keys.map((key) {
      Color btnColor = color;
      if (key == 'C' || key == '⌫') {
        btnColor = Colors.red;
      }

      return GestureDetector(
        onTap: () => onTap(key),
        child: Container(
          decoration: BoxDecoration(
            color: btnColor.withOpacity(0.2),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: btnColor),
          ),
          child: Center(
            child: Text(
              key,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: btnColor,
              ),
            ),
          ),
        ),
      );
    }).toList();
  }
}
