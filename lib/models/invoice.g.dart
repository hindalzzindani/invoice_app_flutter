// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'invoice.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

Invoice _$InvoiceFromJson(Map<String, dynamic> json) => Invoice(
      id: json['id'] as String,
      invoiceNumber: (json['invoiceNumber'] as num).toInt(),
      items: (json['items'] as List<dynamic>)
          .map((e) => InvoiceItem.fromJson(e as Map<String, dynamic>))
          .toList(),
      totalQuantity: (json['totalQuantity'] as num).toDouble(),
      totalValue: (json['totalValue'] as num).toDouble(),
      expenses: (json['expenses'] as num?)?.toDouble() ?? 0,
      guardExpenses: (json['guardExpenses'] as num?)?.toDouble() ?? 0,
      rentExpenses: (json['rentExpenses'] as num?)?.toDouble() ?? 0,
      otherExpenses: (json['otherExpenses'] as num?)?.toDouble() ?? 0,
      marketing: (json['marketing'] as num?)?.toDouble() ?? 0,
      netTotal: (json['netTotal'] as num).toDouble(),
      createdDate: DateTime.parse(json['createdDate'] as String),
      updatedDate: json['updatedDate'] == null
          ? null
          : DateTime.parse(json['updatedDate'] as String),
    );

Map<String, dynamic> _$InvoiceToJson(Invoice instance) => <String, dynamic>{
      'id': instance.id,
      'invoiceNumber': instance.invoiceNumber,
      'items': instance.items,
      'totalQuantity': instance.totalQuantity,
      'totalValue': instance.totalValue,
      'expenses': instance.expenses,
      'guardExpenses': instance.guardExpenses,
      'rentExpenses': instance.rentExpenses,
      'otherExpenses': instance.otherExpenses,
      'marketing': instance.marketing,
      'netTotal': instance.netTotal,
      'createdDate': instance.createdDate.toIso8601String(),
      'updatedDate': instance.updatedDate?.toIso8601String(),
    };
