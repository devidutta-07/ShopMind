import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import '../models/shopping_item.dart';

class PdfService {
  static Future<void> generateAndPrintPdf(
    List<ShoppingItem> items,
    double totalBudget,
    double totalSpent,
    DateTime reportDate,
    String currencySymbol,
  ) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('MMMM yyyy').format(reportDate);

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Header(
                level: 0,
                child: pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Text('ShopAI Report',
                        style: pw.TextStyle(
                            fontSize: 24, fontWeight: pw.FontWeight.bold)),
                    pw.Text(
                      dateStr,
                      style: const pw.TextStyle(fontSize: 12, color: PdfColors.grey),
                    ),
                  ],
                ),
              ),
              pw.SizedBox(height: 20),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: [
                  _buildBudgetInfo('Monthly Budget', totalBudget, PdfColors.blue, currencySymbol),
                  _buildBudgetInfo('Spent', totalSpent, PdfColors.red, currencySymbol),
                  _buildBudgetInfo('Remaining', totalBudget - totalSpent, PdfColors.green, currencySymbol),
                ],
              ),
              pw.SizedBox(height: 30),
              pw.Table.fromTextArray(
                context: context,
                headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                headerDecoration: const pw.BoxDecoration(color: PdfColors.grey300),
                headers: ['Date', 'Item', 'Category', 'Qty', 'Price', 'Total'],
                data: items.map((item) {
                  final price = double.tryParse(item.price ?? '0') ?? 0;
                  final total = price * item.quantity;
                  return [
                    DateFormat('dd MMM').format(item.dateAdded),
                    item.name,
                    item.category,
                    item.quantity.toString(),
                    item.price != null ? '$currencySymbol${item.price}' : '-',
                    '$currencySymbol${total.toStringAsFixed(2)}',
                  ];
                }).toList(),
              ),
            ],
          );
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'ShopAI_Report_${DateFormat('yyyy_MM').format(reportDate)}.pdf',
    );
  }

  static pw.Widget _buildBudgetInfo(String label, double amount, PdfColor color, String currencySymbol) {
    return pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(label, style: const pw.TextStyle(fontSize: 10, color: PdfColors.grey)),
        pw.Text(
          '$currencySymbol${amount.toStringAsFixed(2)}',
          style: pw.TextStyle(
            fontSize: 14,
            fontWeight: pw.FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}
