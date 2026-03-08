import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import '../services/database_service.dart';

final databaseServiceProvider = Provider((ref) => DatabaseService());

final invoicesProvider = FutureProvider<List<Invoice>>((ref) async {
  final db = ref.watch(databaseServiceProvider);
  return db.getAllInvoices();
});

final currentInvoiceProvider = StateProvider<Invoice?>((ref) => null);

final invoiceItemsProvider = StateProvider<List<InvoiceItem>>((ref) => []);

final totalQuantityProvider = StateProvider<double>((ref) {
  final items = ref.watch(invoiceItemsProvider);
  return items.fold(0, (sum, item) {
    final qty = double.tryParse(item.quantity) ?? 0;
    return sum + qty;
  });
});

final totalValueProvider = StateProvider<double>((ref) {
  final items = ref.watch(invoiceItemsProvider);
  return items.fold(0, (sum, item) => sum + item.total);
});

final expensesProvider = StateProvider<double>((ref) => 0);
final guardExpensesProvider = StateProvider<double>((ref) => 0);
final rentExpensesProvider = StateProvider<double>((ref) => 0);
final otherExpensesProvider = StateProvider<double>((ref) => 0);

final marketingProvider = StateProvider<double>((ref) {
  final expenses = ref.watch(expensesProvider);
  return expenses * 0.4; // 40% من المصروفات
});

final netTotalProvider = StateProvider<double>((ref) {
  final totalValue = ref.watch(totalValueProvider);
  final expenses = ref.watch(expensesProvider);
  final guardExpenses = ref.watch(guardExpensesProvider);
  final rentExpenses = ref.watch(rentExpensesProvider);
  final otherExpenses = ref.watch(otherExpensesProvider);
  final marketing = ref.watch(marketingProvider);

  return totalValue - expenses - guardExpenses - rentExpenses - otherExpenses - marketing;
});

final invoiceNumberProvider = StateProvider<int>((ref) => 1);

// Actions
final addInvoiceItemProvider = StateNotifierProvider<AddInvoiceItemNotifier, void>(
  (ref) => AddInvoiceItemNotifier(ref),
);

class AddInvoiceItemNotifier extends StateNotifier<void> {
  final Ref ref;

  AddInvoiceItemNotifier(this.ref) : super(null);

  void addItem(String quantity, String price) {
    final total = (double.tryParse(quantity) ?? 0) * (double.tryParse(price) ?? 0);
    final newItem = InvoiceItem(
      id: const Uuid().v4(),
      quantity: quantity,
      price: price,
      total: total,
    );

    final currentItems = ref.read(invoiceItemsProvider);
    ref.read(invoiceItemsProvider.notifier).state = [...currentItems, newItem];
  }

  void updateItem(String id, String quantity, String price) {
    final currentItems = ref.read(invoiceItemsProvider);
    final total = (double.tryParse(quantity) ?? 0) * (double.tryParse(price) ?? 0);
    
    ref.read(invoiceItemsProvider.notifier).state = currentItems.map((item) {
      if (item.id == id) {
        return item.copyWith(quantity: quantity, price: price, total: total);
      }
      return item;
    }).toList();
  }

  void removeItem(String id) {
    final currentItems = ref.read(invoiceItemsProvider);
    ref.read(invoiceItemsProvider.notifier).state =
        currentItems.where((item) => item.id != id).toList();
  }

  void clearAll() {
    ref.read(invoiceItemsProvider.notifier).state = [];
  }
}

final saveInvoiceProvider = FutureProvider.family<void, Invoice>((ref, invoice) async {
  final db = ref.watch(databaseServiceProvider);
  await db.insertInvoice(invoice);
  ref.invalidate(invoicesProvider);
});

final deleteInvoiceProvider = FutureProvider.family<void, String>((ref, id) async {
  final db = ref.watch(databaseServiceProvider);
  await db.deleteInvoice(id);
  ref.invalidate(invoicesProvider);
});
