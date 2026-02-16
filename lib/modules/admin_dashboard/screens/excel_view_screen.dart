
import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';

class ExcelViewScreen extends StatelessWidget {
  final String title;
  final List<Map<String, dynamic>> data;
  final List<String> headers;

  const ExcelViewScreen({
    Key? key,
    required this.title,
    required this.data,
    required this.headers,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // If no data, show message
    if (data.isEmpty) {
      return Scaffold(
        appBar: AppBar(title: Text(title)),
        body: Center(child: Text(AppLocalizations.of(context)!.noDataAvailable)),
      );
    }

    // Determine headers from data keys if not provided (though passed in constructor)
    final displayHeaders = headers.isNotEmpty ? headers : data.first.keys.toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
            columns: displayHeaders
                .map((h) => DataColumn(
                        label: Text(
                      h.toUpperCase(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    )))
                .toList(),
            rows: data.map((row) {
              return DataRow(
                  cells: displayHeaders.map((h) {
                return DataCell(Text("${row[h] ?? '-'}"));
              }).toList());
            }).toList(),
          ),
        ),
      ),
    );
  }
}
