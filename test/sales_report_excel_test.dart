import 'package:bintrack_app/features/reports/data/sales_report_excel.dart';
import 'package:bintrack_app/features/reports/models/sales_report_model.dart';
import 'package:excel/excel.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('genera un Excel con las columnas y totales del reporte', () async {
    final report = SalesReport(
      periodo: 'personalizado',
      desde: '2026-11-01',
      hasta: '2026-11-06',
      totalVendido: 50000,
      totalAbonado: 20000,
      totalPendiente: 30000,
      totalContado: 20000,
      totalCredito: 30000,
      cantidadVentas: 1,
      cantidadVentasContado: 0,
      cantidadVentasCredito: 1,
      cantidadVentasPagadas: 0,
      cantidadVentasPendientes: 1,
      cantidadClientesPagados: 0,
      cantidadClientesCredito: 1,
      ventas: [
        SalesReportSale(
          id: 1,
          numero: 'V0001',
          fecha: '2026-11-06T12:00:00',
          clienteId: 1,
          clienteNombre: 'Cliente de prueba',
          estado: 'confirmada',
          tipoReporte: 'abonada',
          total: 50000,
          totalPagado: 20000,
          saldoPendiente: 30000,
          items: const [],
        ),
      ],
    );

    final bytes = await SalesReportExcel.build(report);
    final excel = Excel.decodeBytes(bytes);
    final sheet = excel['Ventas'];

    expect(
      sheet.cell(CellIndex.indexByString('A4')).value?.toString(),
      'Fecha',
    );
    expect(
      sheet.cell(CellIndex.indexByString('C5')).value?.toString(),
      'Cliente de prueba',
    );
    expect(
      sheet.cell(CellIndex.indexByString('C6')).value?.toString(),
      'TOTALES',
    );
    expect(
      sheet.cell(CellIndex.indexByString('D6')).value?.toString(),
      '50000',
    );
  });
}
