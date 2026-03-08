import 'package:json_annotation/json_annotation.dart';
import 'invoice_item.dart';

part 'invoice.g.dart';

@JsonSerializable()
class Invoice {
  final String id;
  final int invoiceNumber;
  final List<InvoiceItem> items;
  final double totalQuantity;
  final double totalValue;
  final double expenses;
  final double guardExpenses;
  final double rentExpenses;
  final double otherExpenses;
  final double marketing;
  final double netTotal;
  final DateTime createdDate;
  final DateTime? updatedDate;

  Invoice({
    required this.id,
    required this.invoiceNumber,
    required this.items,
    required this.totalQuantity,
    required this.totalValue,
    this.expenses = 0,
    this.guardExpenses = 0,
    this.rentExpenses = 0,
    this.otherExpenses = 0,
    this.marketing = 0,
    required this.netTotal,
    required this.createdDate,
    this.updatedDate,
  });

  factory Invoice.fromJson(Map<String, dynamic> json) =>
      _$InvoiceFromJson(json);

  Map<String, dynamic> toJson() => _$InvoiceToJson(this);

  Invoice copyWith({
    String? id,
    int? invoiceNumber,
    List<InvoiceItem>? items,
    double? totalQuantity,
    double? totalValue,
    double? expenses,
    double? guardExpenses,
    double? rentExpenses,
    double? otherExpenses,
    double? marketing,
    double? netTotal,
    DateTime? createdDate,
    DateTime? updatedDate,
  }) {
    return Invoice(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      items: items ?? this.items,
      totalQuantity: totalQuantity ?? this.totalQuantity,
      totalValue: totalValue ?? this.totalValue,
      expenses: expenses ?? this.expenses,
      guardExpenses: guardExpenses ?? this.guardExpenses,
      rentExpenses: rentExpenses ?? this.rentExpenses,
      otherExpenses: otherExpenses ?? this.otherExpenses,
      marketing: marketing ?? this.marketing,
      netTotal: netTotal ?? this.netTotal,
      createdDate: createdDate ?? this.createdDate,
      updatedDate: updatedDate ?? this.updatedDate,
    );
  }
}
