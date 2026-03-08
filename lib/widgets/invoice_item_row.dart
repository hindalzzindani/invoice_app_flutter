import 'package:flutter/material.dart';
import '../models/invoice_item.dart';

class InvoiceItemRow extends StatelessWidget {
  final InvoiceItem item;
  final int index;
  final bool isActive;
  final VoidCallback onQuantityTap;
  final VoidCallback onPriceTap;
  final VoidCallback onDelete;

  const InvoiceItemRow({
    super.key,
    required this.item,
    required this.index,
    required this.isActive,
    required this.onQuantityTap,
    required this.onPriceTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: isActive ? Colors.blue.shade50 : Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isActive ? Colors.blue.shade400 : Colors.grey.shade200,
          width: isActive ? 2 : 1,
        ),
      ),
      child: Row(
        textDirection: TextDirection.rtl,
        children: [
          // الرقم
          SizedBox(
            width: 30,
            child: Text(
              index.toString(),
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          // الكمية
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onQuantityTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.amber.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.amber.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  item.quantity.isEmpty ? '0' : item.quantity,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          // السعر
          Expanded(
            flex: 2,
            child: GestureDetector(
              onTap: onPriceTap,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                    color: Colors.blue.shade300,
                    width: 1,
                  ),
                ),
                child: Text(
                  item.price.isEmpty ? '0' : item.price,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),

          const SizedBox(width: 4),
          // القيمة
          Expanded(
            flex: 2,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color: Colors.green.shade300,
                  width: 1,
                ),
              ),
              child: Text(
                item.total.toStringAsFixed(0),
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                  color: Colors.green.shade700,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
          const SizedBox(width: 4),
          // زر الحذف (أول عنصر من اليمين)
          SizedBox(
            width: 30,
            child: IconButton(
              onPressed: onDelete,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
              iconSize: 16,
              padding: EdgeInsets.zero,
              constraints: const BoxConstraints(),
            ),
          ),
          const SizedBox(width: 4),


        ],
      ),
    );
  }
}
