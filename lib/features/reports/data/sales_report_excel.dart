import 'dart:typed_data';

import 'package:excel/excel.dart';
import 'package:file_saver/file_saver.dart';

import '../models/sales_report_model.dart';

/// Construye y guarda un archivo Excel del reporte actualmente mostrado.
///
/// Los datos se generan en el equipo del usuario a partir del reporte ya
/// autenticado que la aplicación cargó desde BINTRACK.
class SalesReportExcel {
  static const _excelMimeType =
      'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet';

  static Future<void> export(SalesReport report) async {
    final bytes = await build(report);
    final fileName =
        'bintrack_ventas_${_fileDate(report.desde)}_a_${_fileDate(report.hasta)}';

    await FileSaver.instance.saveFile(
      name: fileName,
      bytes: bytes,
      fileExtension: 'xlsx',
      mimeType: MimeType.custom,
      customMimeType: _excelMimeType,
    );
  }

  static Future<Uint8List> build(SalesReport report) async {
    final excel = Excel.createExcel();
    final sheet = excel['Ventas'];
    excel.delete('Sheet1');

    final titleStyle = CellStyle(
      bold: true,
      fontSize: 14,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#1E40AF'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final headerStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#2563EB'),
      horizontalAlign: HorizontalAlign.Center,
    );
    final moneyStyle = CellStyle(
      numberFormat: NumFormat.custom(formatCode: r'$#,##0'),
    );

    sheet.merge(
      CellIndex.indexByString('A1'),
      CellIndex.indexByString('G1'),
      customValue: TextCellValue('BINTRACK | Reporte de ventas'),
    );
    sheet.cell(CellIndex.indexByString('A1')).cellStyle = titleStyle;
    sheet.appendRow([
      TextCellValue(
        'Período: ${_date(report.desde)} al ${_date(report.hasta)}',
      ),
    ]);
    sheet.appendRow([TextCellValue('')]);
    sheet.appendRow([
      TextCellValue('Fecha'),
      TextCellValue('N° venta'),
      TextCellValue('Cliente'),
      TextCellValue('Total vendido'),
      TextCellValue('Total abonado'),
      TextCellValue('Saldo pendiente'),
      TextCellValue('Estado'),
    ]);

    for (final cell in sheet.rows[3]) {
      cell?.cellStyle = headerStyle;
    }

    for (final sale in report.ventas) {
      sheet.appendRow([
        TextCellValue(_date(sale.fecha)),
        TextCellValue(sale.numero),
        TextCellValue(sale.clienteNombre),
        DoubleCellValue(sale.total),
        DoubleCellValue(sale.totalPagado),
        DoubleCellValue(sale.saldoPendiente),
        TextCellValue(_status(sale)),
      ]);
    }

    final totalRow = 5 + report.ventas.length;
    sheet.cell(CellIndex.indexByString('C$totalRow')).value = TextCellValue(
      'TOTALES',
    );
    sheet.cell(CellIndex.indexByString('D$totalRow')).value = DoubleCellValue(
      report.totalVendido,
    );
    sheet.cell(CellIndex.indexByString('E$totalRow')).value = DoubleCellValue(
      report.totalAbonado,
    );
    sheet.cell(CellIndex.indexByString('F$totalRow')).value = DoubleCellValue(
      report.totalPendiente,
    );
    sheet.cell(CellIndex.indexByString('C$totalRow')).cellStyle = CellStyle(
      bold: true,
      backgroundColorHex: ExcelColor.fromHexString('#DBEAFE'),
    );
    for (final column in ['D', 'E', 'F']) {
      sheet
          .cell(CellIndex.indexByString('$column$totalRow'))
          .cellStyle = CellStyle(
        bold: true,
        backgroundColorHex: ExcelColor.fromHexString('#DBEAFE'),
        numberFormat: NumFormat.custom(formatCode: r'$#,##0'),
      );
    }

    for (var row = 4; row <= totalRow; row++) {
      for (final column in ['D', 'E', 'F']) {
        final cell = sheet.cell(CellIndex.indexByString('$column$row'));
        if (row != totalRow) cell.cellStyle = moneyStyle;
      }
    }

    const widths = [15.0, 14.0, 28.0, 18.0, 18.0, 20.0, 22.0];
    for (var i = 0; i < widths.length; i++) {
      sheet.setColumnWidth(i, widths[i]);
    }

    final result = excel.save();
    if (result == null) {
      throw StateError('No se pudo generar el archivo Excel.');
    }
    return Uint8List.fromList(result);
  }

  static String _date(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return value;
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  static String _fileDate(String value) {
    final date = DateTime.tryParse(value)?.toLocal();
    if (date == null) return 'periodo';
    return '${date.year}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}';
  }

  static String _status(SalesReportSale sale) {
    if (sale.esPagada) return 'Pagada';
    if (sale.esAbonada) return 'Abonada parcialmente';
    return 'Pendiente de pago';
  }
}
