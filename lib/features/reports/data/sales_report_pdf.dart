import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/sales_report_model.dart';

String _date(String value) {
  final date = DateTime.tryParse(value)?.toLocal();
  if (date == null) return value;
  return '${date.day.toString().padLeft(2, '0')}/'
      '${date.month.toString().padLeft(2, '0')}/${date.year}';
}

String _money(double value) => '\$${value.toStringAsFixed(0)}';

Future<Uint8List> buildSalesReportPdf(
  SalesReport report,
  PdfPageFormat format,
) async {
  final document = pw.Document(title: 'BINTRACK - Reporte de ventas');
  final period = switch (report.periodo) {
    'hoy' => 'Hoy',
    'semana' => 'Semana',
    'mes' => 'Mes',
    _ => report.periodo,
  };
  document.addPage(
    pw.MultiPage(
      pageFormat: format,
      margin: const pw.EdgeInsets.all(32),
      // Allow long reports; content is flattened so a large sale can span pages.
      maxPages: 10000,
      theme: pw.ThemeData.withFont(
        base: pw.Font.helvetica(),
        bold: pw.Font.helveticaBold(),
      ),
      header: (context) => pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'BINTRACK | Reporte de ventas',
            style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold),
          ),
          pw.Text('$period | ${_date(report.desde)} - ${_date(report.hasta)}'),
          pw.Divider(),
        ],
      ),
      footer: (context) => pw.Align(
        alignment: pw.Alignment.centerRight,
        child: pw.Text(
          'Página ${context.pageNumber} de ${context.pagesCount}',
          style: const pw.TextStyle(fontSize: 9),
        ),
      ),
      build: (context) => [
        pw.Text(
          'Total vendido: ${_money(report.totalVendido)}',
          style: pw.TextStyle(fontSize: 15, fontWeight: pw.FontWeight.bold),
        ),
        pw.Text('Contado / pagado: ${_money(report.totalContado)}'),
        pw.Text('Crédito / pendiente: ${_money(report.totalCredito)}'),
        pw.Text(
          'Ventas: ${report.cantidadVentas} | Pagadas: ${report.cantidadVentasContado} | Pendientes: ${report.cantidadVentasCredito}',
        ),
        pw.Text(
          'Clientes pagados: ${report.cantidadClientesPagados} | Clientes deben: ${report.cantidadClientesCredito}',
        ),
        pw.SizedBox(height: 16),
        if (report.ventas.isEmpty) pw.Text('No hay ventas en este período.'),
        for (final sale in report.ventas) ...[
          pw.Divider(),
          pw.Text(
            '${sale.numero} | ${_date(sale.fecha)} | ${sale.clienteNombre}',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 11),
          ),
          pw.Text(
            '${sale.esContado ? 'Contado / pagado' : 'Crédito / pendiente'} | Total: ${_money(sale.total)}',
            style: const pw.TextStyle(fontSize: 10),
          ),
          pw.SizedBox(height: 5),
          for (final item in sale.items)
            pw.Padding(
              padding: const pw.EdgeInsets.only(bottom: 6),
              child: pw.Text(
                '${item.productNombre} / ${item.binNombre}\n'
                '${item.esPorKilo ? '${item.binsCantidad} envase(s), ${item.kilosPesados?.toStringAsFixed(2) ?? '0.00'} kg' : '${item.cantidad} envase(s)'}'
                ' | Precio unitario: ${_money(item.precioUnitario)}'
                ' | Subtotal: ${_money(item.subtotal)}',
                style: const pw.TextStyle(fontSize: 10),
              ),
            ),
        ],
      ],
    ),
  );
  return document.save();
}
