import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/data/models/child_model.dart';
import 'assessment_flow_screen.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:excel/excel.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:permission_handler/permission_handler.dart';

/// Child Assessment Dashboard - Main screen for managing child assessments
/// 
/// Displays:
/// - List of all children in Anganwadi
/// - Last assessment date and risk level for each child
/// - Quick access to assessment for each child
/// - Search and filter functionality
class ChildAssessmentDashboard extends ConsumerStatefulWidget {
  const ChildAssessmentDashboard({Key? key}) : super(key: key);

  @override
  ConsumerState<ChildAssessmentDashboard> createState() =>
      _ChildAssessmentDashboardState();
}

class _ChildAssessmentDashboardState
    extends ConsumerState<ChildAssessmentDashboard> {
  late TextEditingController _searchController;
  List<ChildModel> _filteredChildren = [];
  List<ChildModel> _allChildren = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadChildren();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _loadChildren() {
    // This would load from Hive database
    // For now, mock data
    _allChildren = [
      ChildModel(
        id: '1',
        name: 'Aditya Kumar',
        dob: DateTime(2022, 6, 15),
        gender: 'Male',
        anganwadi: 'Anganwadi Center 1',
      ),
      ChildModel(
        id: '2',
        name: 'Priya Sharma',
        dob: DateTime(2022, 9, 22),
        gender: 'Female',
        anganwadi: 'Anganwadi Center 1',
      ),
      ChildModel(
        id: '3',
        name: 'Rohan Singh',
        dob: DateTime(2021, 11, 8),
        gender: 'Male',
        anganwadi: 'Anganwadi Center 1',
      ),
      ChildModel(
        id: '4',
        name: 'Divya Patel',
        dob: DateTime(2023, 1, 19),
        gender: 'Female',
        anganwadi: 'Anganwadi Center 1',
      ),
      ChildModel(
        id: '5',
        name: 'Vikram Gupta',
        dob: DateTime(2021, 4, 5),
        gender: 'Male',
        anganwadi: 'Anganwadi Center 1',
      ),
    ];
    _filteredChildren = _allChildren;
  }

  void _filterChildren(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredChildren = _allChildren;
      } else {
        _filteredChildren = _allChildren
            .where((child) =>
                child.name.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Child Assessment Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadChildren()),
            tooltip: 'Refresh',
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: 'Filter',
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(),
          _buildStatsBar(),
          Expanded(
            child: _filteredChildren.isEmpty
                ? _buildEmptyState()
                : _buildChildrenList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewChild,
        icon: const Icon(Icons.person_add),
        label: const Text('Add Child'),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterChildren,
        decoration: InputDecoration(
          hintText: 'Search child by name...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: _searchController.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _filterChildren('');
                  },
                )
              : null,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: const EdgeInsets.symmetric(horizontal: 16),
        ),
      ),
    );
  }

  Widget _buildStatsBar() {
    final totalChildren = _allChildren.length;
    final needsAssessment =
        _allChildren.where((c) => true).length; // Placeholder

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatCard(
            icon: Icons.people,
            label: 'Total Children',
            value: '$totalChildren',
            color: AppColors.primary,
          ),
          _buildStatCard(
            icon: Icons.assignment,
            label: 'Need Assessment',
            value: '$needsAssessment',
            color: AppColors.secondary,
          ),
          _buildStatCard(
            icon: Icons.warning,
            label: 'At Risk',
            value: '2',
            color: Colors.red,
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 10),
        ),
      ],
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.person_outline,
            size: 64,
            color: Colors.grey[300],
          ),
          const SizedBox(height: 16),
          Text(
            'No children found',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add a child to get started',
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildChildrenList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _filteredChildren.length,
      itemBuilder: (context, index) {
        final child = _filteredChildren[index];
        return _buildChildCard(child);
      },
    );
  }

  Widget _buildChildCard(ChildModel child) {
    final riskLevel = _getChildRiskLevel(child);
    final riskColor = _getRiskColor(riskLevel);
    final ageMonths = child.ageMonths;
    final years = ageMonths ~/ 12;
    final months = ageMonths % 12;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.blue[100],
                  child: Text(
                    child.name[0].toUpperCase(),
                    style: const TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        child.name,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      Text(
                        'Age: $years years $months months',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        'Gender: ${child.gender}',
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: riskColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: riskColor),
                  ),
                  child: Text(
                    riskLevel,
                    style: TextStyle(
                      color: riskColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Divider(height: 1),
            const SizedBox(height: 12),
            SizedBox(
              height: 40,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewChildDetails(child),
                      icon: const Icon(Icons.info_outline, size: 16),
                      label: const Text(
                        'Details',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _startAssessment(child),
                      icon: const Icon(Icons.play_arrow, size: 16),
                      label: const Text(
                        'Assessment',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[700],
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => _viewAssessmentHistory(child),
                      icon: const Icon(Icons.history, size: 16),
                      label: const Text(
                        'History',
                        style: TextStyle(fontSize: 12),
                      ),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getChildRiskLevel(ChildModel child) {
    // This would be determined from actual assessment results
    // For now, return mock data
    if (child.id == '3') return 'HIGH RISK';
    if (child.id == '5') return 'MEDIUM RISK';
    return 'LOW RISK';
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel == 'HIGH RISK') return Colors.red;
    if (riskLevel == 'MEDIUM RISK') return Colors.orange;
    return Colors.green;
  }

  void _startAssessment(ChildModel child) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AssessmentFlowScreen(child: child),
      ),
    );
  }

  void _viewChildDetails(ChildModel child) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing details for ${child.name}')),
    );
  }

  void _viewAssessmentHistory(ChildModel child) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Viewing assessment history for ${child.name}')),
    );
  }

  Future<void> _addNewChild() async {
    final _nameController = TextEditingController();
    final _dobController = TextEditingController(); // Simple text for now or DatePicker
    String _gender = 'Male';
    DateTime? _selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add New Child'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'Child Name'),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dobController,
                    decoration: const InputDecoration(
                      labelText: 'Date of Birth (YYYY-MM-DD)',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () async {
                      DateTime? picked = await showDatePicker(
                        context: context,
                        initialDate: DateTime.now(),
                        firstDate: DateTime(2015),
                        lastDate: DateTime.now(),
                      );
                      if (picked != null) {
                        setState(() {
                          _selectedDate = picked;
                          _dobController.text = "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        });
                      }
                    },
                  ),
                   const SizedBox(height: 10),
                   DropdownButtonFormField<String>(
                     value: _gender,
                     items: ['Male', 'Female', 'Other'].map((String value) {
                       return DropdownMenuItem<String>(
                         value: value,
                         child: Text(value),
                       );
                     }).toList(),
                     onChanged: (newValue) {
                       setState(() {
                         _gender = newValue!;
                       });
                     },
                     decoration: const InputDecoration(labelText: 'Gender'),
                   ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancel'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _selectedDate != null) {
                      final newChild = ChildModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        dob: _selectedDate,
                        gender: _gender,
                        anganwadi: 'Current Center', // Placeholder
                      );
                      
                      // Update State directly
                      this.setState(() {
                        _allChildren.add(newChild);
                        _filteredChildren = _allChildren; // Reset filter to show all including new
                      });
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Added ${newChild.name}')),
                      );
                     
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          }
        );
      },
    );
  }

  Future<void> _exportToExcel() async {
    // Permission check for storage
    /*
    var status = await Permission.storage.request();
    if (!status.isGranted) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Storage permission required for export')),
      );
      return;
    }
    */
    
    try {
      var excel = Excel.createExcel();
      Sheet sheetObject = excel['Children Data'];
      
      // Header
      sheetObject.appendRow([
        TextCellValue('ID'), 
        TextCellValue('Name'), 
        TextCellValue('DOB'), 
        TextCellValue('Gender'), 
        TextCellValue('Anganwadi')
      ]);
      
      // Data
      for (var child in _allChildren) {
        sheetObject.appendRow([
          TextCellValue(child.id),
          TextCellValue(child.name),
          TextCellValue(child.dob != null ? "${child.dob!.year}-${child.dob!.month}-${child.dob!.day}" : "N/A"),
          TextCellValue(child.gender ?? "N/A"),
          TextCellValue(child.anganwadi ?? "N/A"),
        ]);
      }
      
      // Save
      Directory? directory;
      if (Platform.isAndroid) {
        directory = await getExternalStorageDirectory(); // App specific public dir
        // Or for public download folder:
        // directory = Directory('/storage/emulated/0/Download');
      } else {
         directory = await getApplicationDocumentsDirectory();
      }
      
      String outputFile = "${directory?.path}/children_data_${DateTime.now().millisecondsSinceEpoch}.xlsx";
      
      List<int>? fileBytes = excel.save();
      
      if (fileBytes != null) {
        File(outputFile)
          ..createSync(recursive: true)
          ..writeAsBytesSync(fileBytes);
          
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Exported to $outputFile')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Export failed: $e')),
      );
    }
  }

  void _showFilterOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Filter Options',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: const Text('All Children'),
              onTap: () {
                setState(() => _filteredChildren = _allChildren);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('High Risk'),
              onTap: () {
                setState(() => _filteredChildren = _allChildren
                    .where((c) => _getChildRiskLevel(c) == 'HIGH RISK')
                    .toList());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Medium Risk'),
              onTap: () {
                setState(() => _filteredChildren = _allChildren
                    .where((c) => _getChildRiskLevel(c) == 'MEDIUM RISK')
                    .toList());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: const Text('Need Assessment'),
              onTap: () {
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
