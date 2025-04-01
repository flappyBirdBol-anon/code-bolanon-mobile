// excel_data_source.dart
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:google_fonts/google_fonts.dart'; // For text styling

class ExcelDataSource extends DataGridSource {
  /// Creates the employee data source class with required details.
  ExcelDataSource({required List<List<dynamic>> excelData}) {
    if (excelData.isNotEmpty) {
      // Assume first row is header
      _headers = excelData[0].map((h) => h?.toString() ?? '').toList();
      // Store data rows (excluding header)
      _excelRows = excelData.length > 1
          ? excelData.sublist(1)
          : []; // Handle case with only header

      // Build DataGridRows
      _dataGridRows = _excelRows.map<DataGridRow>((dataRow) {
        // Ensure dataRow has same length as headers, padding if needed
        List<dynamic> paddedRow = List.from(dataRow);
        if (paddedRow.length < _headers.length) {
          paddedRow.addAll(List.filled(_headers.length - paddedRow.length, ''));
        } else if (paddedRow.length > _headers.length) {
          paddedRow = paddedRow.sublist(0, _headers.length);
        }

        return DataGridRow(
            cells: List<DataGridCell>.generate(_headers.length, (index) {
          return DataGridCell<String>(
              columnName: _headers[index], // Use header as column name
              value: paddedRow[index]?.toString() ?? '');
        }));
      }).toList();
    } else {
      _headers = [];
      _excelRows = [];
      _dataGridRows = [];
    }
  }

  List<String> _headers = [];
  List<List<dynamic>> _excelRows = [];
  List<DataGridRow> _dataGridRows = [];

  List<String> get headers => _headers;

  @override
  List<DataGridRow> get rows => _dataGridRows;

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(
        cells: row.getCells().map<Widget>((dataGridCell) {
      return Container(
        alignment: Alignment.centerLeft, // Align text to the left
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Text(
          dataGridCell.value.toString(),
          overflow: TextOverflow.ellipsis, // Handle overflow
          style: GoogleFonts.figtree(fontSize: 13), // Consistent font
        ),
      );
    }).toList());
  }

  // Optional: Implement methods like handleSort, handleFilter if needed
}
