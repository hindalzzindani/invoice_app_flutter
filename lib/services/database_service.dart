import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/invoice.dart';
import '../models/invoice_item.dart';
import 'dart:convert';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  static Database? _database;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'invoice_app.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createTables,
    );
  }

  Future<void> _createTables(Database db, int version) async {
    await db.execute('''
      CREATE TABLE invoices (
        id TEXT PRIMARY KEY,
        invoice_number INTEGER NOT NULL,
        items TEXT NOT NULL,
        total_quantity REAL NOT NULL,
        total_value REAL NOT NULL,
        expenses REAL DEFAULT 0,
        guard_expenses REAL DEFAULT 0,
        rent_expenses REAL DEFAULT 0,
        other_expenses REAL DEFAULT 0,
        marketing REAL DEFAULT 0,
        net_total REAL NOT NULL,
        created_date TEXT NOT NULL,
        updated_date TEXT
      )
    ''');

    await db.execute('''
      CREATE INDEX idx_invoice_number ON invoices(invoice_number)
    ''');

    await db.execute('''
      CREATE INDEX idx_created_date ON invoices(created_date)
    ''');
  }

  // Create
  Future<void> insertInvoice(Invoice invoice) async {
    final db = await database;
    await db.insert(
      'invoices',
      {
        'id': invoice.id,
        'invoice_number': invoice.invoiceNumber,
        'items': jsonEncode(invoice.items.map((e) => e.toJson()).toList()),
        'total_quantity': invoice.totalQuantity,
        'total_value': invoice.totalValue,
        'expenses': invoice.expenses,
        'guard_expenses': invoice.guardExpenses,
        'rent_expenses': invoice.rentExpenses,
        'other_expenses': invoice.otherExpenses,
        'marketing': invoice.marketing,
        'net_total': invoice.netTotal,
        'created_date': invoice.createdDate.toIso8601String(),
        'updated_date': invoice.updatedDate?.toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  // Read
  Future<Invoice?> getInvoice(String id) async {
    final db = await database;
    final maps = await db.query(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToInvoice(maps.first);
  }

  Future<List<Invoice>> getAllInvoices() async {
    final db = await database;
    final maps = await db.query(
      'invoices',
      orderBy: 'created_date DESC',
    );
    return maps.map((map) => _mapToInvoice(map)).toList();
  }

  Future<List<Invoice>> getInvoicesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'invoices',
      where: 'created_date BETWEEN ? AND ?',
      whereArgs: [
        startDate.toIso8601String(),
        endDate.toIso8601String(),
      ],
      orderBy: 'created_date DESC',
    );
    return maps.map((map) => _mapToInvoice(map)).toList();
  }

  // Update
  Future<void> updateInvoice(Invoice invoice) async {
    final db = await database;
    await db.update(
      'invoices',
      {
        'invoice_number': invoice.invoiceNumber,
        'items': jsonEncode(invoice.items.map((e) => e.toJson()).toList()),
        'total_quantity': invoice.totalQuantity,
        'total_value': invoice.totalValue,
        'expenses': invoice.expenses,
        'guard_expenses': invoice.guardExpenses,
        'rent_expenses': invoice.rentExpenses,
        'other_expenses': invoice.otherExpenses,
        'marketing': invoice.marketing,
        'net_total': invoice.netTotal,
        'updated_date': invoice.updatedDate?.toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [invoice.id],
    );
  }

  // Delete
  Future<void> deleteInvoice(String id) async {
    final db = await database;
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<void> deleteAllInvoices() async {
    final db = await database;
    await db.delete('invoices');
  }

  // Helper method
  Invoice _mapToInvoice(Map<String, dynamic> map) {
    final itemsList = jsonDecode(map['items'] as String) as List;
    final items = itemsList
        .map((item) => InvoiceItem.fromJson(item as Map<String, dynamic>))
        .toList();

    return Invoice(
      id: map['id'] as String,
      invoiceNumber: map['invoice_number'] as int,
      items: items,
      totalQuantity: map['total_quantity'] as double,
      totalValue: map['total_value'] as double,
      expenses: map['expenses'] as double? ?? 0,
      guardExpenses: map['guard_expenses'] as double? ?? 0,
      rentExpenses: map['rent_expenses'] as double? ?? 0,
      otherExpenses: map['other_expenses'] as double? ?? 0,
      marketing: map['marketing'] as double? ?? 0,
      netTotal: map['net_total'] as double,
      createdDate: DateTime.parse(map['created_date'] as String),
      updatedDate: map['updated_date'] != null
          ? DateTime.parse(map['updated_date'] as String)
          : null,
    );
  }

  // Statistics
  Future<double> getTotalSalesAmount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT SUM(net_total) as total FROM invoices',
    );
    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTotalInvoicesCount() async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM invoices',
    );
    return (result.first['count'] as int?) ?? 0;
  }

  // Close database
  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
