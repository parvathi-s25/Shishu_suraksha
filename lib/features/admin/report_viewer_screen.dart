import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';

class ReportViewerScreen extends StatefulWidget {
  final List<Map<String, dynamic>> data; // List of rows (key-value pairs)
  final List<String> columns; // Column keys

  const ReportViewerScreen({
    super.key,
    required this.data,
    required this.columns,
  });

  @override
  State<ReportViewerScreen> createState() => _ReportViewerScreenState();
}

class _ReportViewerScreenState extends State<ReportViewerScreen> {
  late List<Map<String, dynamic>> _filteredData;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _filteredData = widget.data;
  }

  void _filterData(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredData = widget.data;
      } else {
        _filteredData = widget.data.where((row) {
          return row.values.any((value) =>
              value.toString().toLowerCase().contains(query.toLowerCase()));
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n?.reports ?? 'Reports'),
        actions: [
          IconButton(
            icon: const Icon(Icons.print),
            onPressed: () {
              // Create PDF or print action
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: l10n?.searchChild ?? 'Search',
                prefixIcon: const Icon(Icons.search),
                border: const OutlineInputBorder(),
              ),
              onChanged: _filterData,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              scrollDirection: Axis.vertical,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.all(AppTheme.primaryColor.withOpacity(0.1)),
                  columns: widget.columns
                      .map((col) => DataColumn(
                            label: Text(
                              col.toUpperCase(),
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                          ))
                      .toList(),
                  rows: _filteredData
                      .map((row) => DataRow(
                            cells: widget.columns
                                .map((col) => DataCell(Text(row[col]?.toString() ?? '-')))
                                .toList(),
                          ))
                      .toList(),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
