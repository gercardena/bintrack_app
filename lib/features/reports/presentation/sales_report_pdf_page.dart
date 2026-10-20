import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';

import '../models/sales_report_model.dart';
import '../data/sales_report_pdf.dart';

/// Uses the loaded report, so exporting never changes its period or totals.
class SalesReportPdfPage extends StatelessWidget {
  const SalesReportPdfPage({super.key, required this.report});

  final SalesReport report;

  @override
  Widget build(BuildContext context) {
    final filename =
        'ventas_${report.periodo}_'
        '${report.desde.replaceAll(RegExp(r'[^0-9-]'), '_')}.pdf';
    return Scaffold(
      appBar: AppBar(title: const Text('PDF de ventas')),
      body: PdfPreview(
        pdfFileName: filename,
        initialPageFormat: PdfPageFormat.a4,
        canChangePageFormat: false,
        canChangeOrientation: false,
        canDebug: false,
        build: (format) => buildSalesReportPdf(report, format),
        onError: (context, error) => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'No se pudo generar el PDF. Vuelve al reporte e inténtalo nuevamente.',
            ),
          ),
        ),
        onPrintError: (context, error) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'No se pudo imprimir el reporte. Inténtalo nuevamente.',
              ),
            ),
          );
        },
      ),
    );
  }
}