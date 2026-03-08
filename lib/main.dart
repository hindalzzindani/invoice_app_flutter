import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'screens/create_invoice_screen.dart';
import 'screens/invoice_summary_screen.dart';
import 'screens/saved_invoices_screen.dart';
import 'screens/invoice_detail_screen.dart';
import 'models/invoice.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'تطبيق الفواتير',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.light,
        ),
        fontFamily: 'Almarai',
      ),
      home: const HomeScreen(),
      routes: {
        '/create_invoice': (context) => const CreateInvoiceScreen(),
        '/saved_invoices': (context) => const SavedInvoicesScreen(),
        '/invoice_summary': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map;
          return InvoiceSummaryScreen(
            items: args['items'],
            totalQuantity: args['totalQuantity'],
            totalValue: args['totalValue'],
          );
        },
        '/invoice_detail': (context) {
          final invoice = ModalRoute.of(context)!.settings.arguments as Invoice;
          return InvoiceDetailScreen(invoice: invoice);
        },
      },
      onGenerateRoute: (settings) {
        if (settings.name == '/invoice_detail') {
          final invoice = settings.arguments as Invoice;
          return MaterialPageRoute(
            builder: (context) => InvoiceDetailScreen(invoice: invoice),
          );
        }
        return null;
      },
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.blue.shade900,
              Colors.blue.shade600,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long,
                    size: 80,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'تطبيق الفواتير',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'إدارة احترافية للفواتير والمبيعات',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white.withOpacity(0.8),
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/create_invoice');
                        },
                        icon: const Icon(Icons.add_circle_outline),
                        label: const Text('إنشاء فاتورة جديدة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.blue.shade900,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                        ),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, '/saved_invoices');
                        },
                        icon: const Icon(Icons.history),
                        label: const Text('الفواتير المحفوظة'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.2),
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 16,
                          ),
                          textStyle: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                          minimumSize: const Size(double.infinity, 56),
                          side: const BorderSide(
                            color: Colors.white,
                            width: 2,
                          ),
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
    );
  }
}
