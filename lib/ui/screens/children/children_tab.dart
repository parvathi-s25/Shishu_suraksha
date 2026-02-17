import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';
import '../../../../core/data/models/child_model.dart';
import '../../../../core/data/models/assessment_result_models.dart';
import '../../screens/monitor/health_monitoring_screen.dart';
import '../../screens/monitor/growth_screen.dart';
import '../screening/visual/visual_screening_screen.dart';
import '../screening/audio/audio_screening_screen.dart';
import '../assessment/assessment_flow_screen.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:file_picker/file_picker.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../../../../core/services/data_service.dart';

// Renamed from ChildAssessmentDashboard to match existing file usage
class ChildrenTab extends ConsumerStatefulWidget {
  const ChildrenTab({Key? key}) : super(key: key);

  @override
  ConsumerState<ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends ConsumerState<ChildrenTab> {
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
    final t = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(t.childHealthDevelopment),
        automaticallyImplyLeading: false, // Hide back button if in tab
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => setState(() => _loadChildren()),
            tooltip: t.refresh,
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterOptions,
            tooltip: t.filter,
          ),
        ],
      ),
      body: Column(
        children: [
          _buildSearchBar(t),
          _buildStatsBar(t),
          Expanded(
            child: _filteredChildren.isEmpty
                ? _buildEmptyState(t)
                : _buildChildrenList(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addNewChild,
        icon: const Icon(Icons.person_add),
        label: Text(t.addChild),
      ),
    );
  }

  Widget _buildSearchBar(AppLocalizations t) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        onChanged: _filterChildren,
        decoration: InputDecoration(
          hintText: t.searchChild,
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

  Widget _buildStatsBar(AppLocalizations t) {
    final totalChildren = _allChildren.length;
    final needsAssessment =
        _allChildren.where((c) => true).length; // Placeholder

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.background,
      child: Wrap(
        alignment: WrapAlignment.spaceAround,
        spacing: 16,
        runSpacing: 12,
        children: [
          _buildStatCard(
            icon: Icons.people,
            label: t.totalChildren,
            value: '$totalChildren',
            color: AppColors.primary,
          ),
          _buildStatCard(
            icon: Icons.assignment,
            label: t.needAssessment,
            value: '$needsAssessment',
            color: AppColors.secondary,
          ),
          _buildStatCard(
            icon: Icons.warning,
            label: t.atRisk,
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

  Widget _buildEmptyState(AppLocalizations t) {
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
            t.noChildrenFound,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            t.addChildPrompt,
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
    final t = AppLocalizations.of(context)!;
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
                        '${t.ageLabel}: $years years $months months', // Localized age label
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      Text(
                        '${t.gender}: ${child.gender == 'Male' ? t.male : (child.gender == 'Female' ? t.female : t.other)}', // Localized gender label
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                Flexible(
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: riskColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: riskColor),
                    ),
                    child: Text(
                      _getLocalizedRiskLabel(riskLevel, t),
                      style: TextStyle(
                        color: riskColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ),
            ],
          ),
            const SizedBox(height: 16),
            const Divider(),
            
            // HEALTH & DEVELOPMENT SUITE
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 8.0),
              child: Text(t.healthDevelopmentSuite, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.0)),
            ),
            
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // 1. LIVE VITALS
                SizedBox(
                  width: double.infinity,
                  child: _buildTestButton(
                    context,
                    icon: Icons.monitor_heart,
                    label: t.heartRateVitals,
                    color: Colors.purple,
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => HealthMonitoringScreen(child: child)));
                    },
                  ),
                ),
                
                // 2. GROWTH
                _buildTestButton(
                  context,
                  icon: Icons.show_chart,
                  label: t.growth.toUpperCase(),
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => GrowthScreen(child: child)));
                  },
                ),
                
                // 3. DEVELOPMENTAL
                _buildTestButton(
                  context,
                  icon: Icons.psychology,
                  label: t.developmental.toUpperCase(), 
                  color: Colors.teal,
                  onTap: () => _startAssessment(child),
                ),

                // 4. VISION
                _buildTestButton(
                  context,
                  icon: Icons.visibility,
                  label: t.visionTest,
                  color: Colors.orange,
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VisualScreeningScreen()));
                  },
                ),
                
                // 5. HEARING
                _buildTestButton(
                  context,
                  icon: Icons.hearing,
                  label: t.hearingTest.toUpperCase(),
                  color: Colors.indigo,
                  onTap: () {
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const AudioScreeningScreen()));
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _getLocalizedRiskLabel(String riskLevel, AppLocalizations t) {
    if (riskLevel == 'HIGH RISK') return t.highRisk;
    if (riskLevel == 'MEDIUM RISK') return t.mediumRisk;
    if (riskLevel == 'LOW RISK') return t.lowRisk;
    if (riskLevel == 'NO ASSESSMENT') return t.noAssessment;
    return riskLevel;
  }



  Widget _buildTestButton(BuildContext context, {required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return ElevatedButton.icon(
      onPressed: onTap,
      icon: Icon(icon, size: 18),
      label: Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11)),
      style: ElevatedButton.styleFrom(
        backgroundColor: color.withOpacity(0.1),
        foregroundColor: color,
        elevation: 0,
        alignment: Alignment.centerLeft,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        shape: RoundedRectangleBorder(
           borderRadius: BorderRadius.circular(8),
           side: BorderSide(color: color.withOpacity(0.3)),
        )
      ),
    );
  }

  String _getChildRiskLevel(ChildModel child) {
    // Check DataService for assessments
    final assessments = DataService().getAssessmentsForChild(child.id);
    
    if (assessments.isEmpty) {
      // Keep mock data for specific IDs for demo purposes, else return NO ASSESSMENT
       if (child.id == '3') return 'HIGH RISK';
       if (child.id == '5') return 'MEDIUM RISK';
       return 'NO ASSESSMENT'; 
    }
    
    // Sort by date descending
    assessments.sort((a, b) => b.date.compareTo(a.date));
    final latest = assessments.first;
    
    // Determine risk based on latest assessment type
    double score = 0;
    if (latest is MotorAssessmentResult) score = latest.totalScore;
    if (latest is SpeechAssessmentResult) score = latest.totalScore;
    if (latest is CognitiveAssessmentResult) score = latest.totalScore;
    
    if (score >= 75) return 'LOW RISK';
    if (score >= 50) return 'MEDIUM RISK';
    return 'HIGH RISK';
  }

  Color _getRiskColor(String riskLevel) {
    if (riskLevel == 'HIGH RISK') return Colors.red;
    if (riskLevel == 'MEDIUM RISK') return Colors.orange;
    if (riskLevel == 'NO ASSESSMENT') return Colors.grey;
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

  String _getGreeting(AppLocalizations t) {
    final hour = DateTime.now().hour;
    if (hour < 12) return t.goodMorning;
    if (hour < 17) return t.goodAfternoon;
    return t.goodEvening;
  }

  Future<void> _addNewChild() async {
    final t = AppLocalizations.of(context)!;
    final _nameController = TextEditingController();
    final _dobController = TextEditingController(); 
    String _gender = 'Male';
    DateTime? _selectedDate;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: Text(t.addNewChild),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   TextField(
                    controller: _nameController,
                    decoration: InputDecoration(labelText: t.childName),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: _dobController,
                    readOnly: true,
                    decoration: InputDecoration(
                      labelText: t.dateOfBirth,
                      suffixIcon: const Icon(Icons.calendar_today),
                    ),
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
                     String label = value;
                     if (value == 'Male') label = t.male;
                     if (value == 'Female') label = t.female;
                     if (value == 'Other') label = t.other;
                     
                     return DropdownMenuItem<String>(
                       value: value,
                       child: Text(label),
                     );
                   }).toList(),
                   onChanged: (newValue) {
                     setState(() {
                       _gender = newValue!;
                     });
                   },
                   decoration: InputDecoration(labelText: t.gender), // Localized label
                 ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text(t.cancel),
                ),
                TextButton(
                  onPressed: () {
                    if (_nameController.text.isNotEmpty && _selectedDate != null) {
                      final newChild = ChildModel(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: _nameController.text,
                        dob: _selectedDate,
                        gender: _gender,
                        anganwadi: 'Current Center', 
                      );
                      
                      this.setState(() {
                        _allChildren.add(newChild);
                        _filteredChildren = _allChildren; 
                      });
                      
                      Navigator.pop(context);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('${t.added} ${newChild.name}')),
                      );
                    }
                  },
                  child: Text(t.add),
                ),
              ],
            );
          }
        );
      },
    );
  }

  void _showFilterOptions() {
    final t = AppLocalizations.of(context)!;
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              t.filterOptions,
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 16),
            ListTile(
              title: Text(t.allChildren),
              onTap: () {
                setState(() => _filteredChildren = _allChildren);
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(t.highRisk),
              onTap: () {
                setState(() => _filteredChildren = _allChildren
                    .where((c) => _getChildRiskLevel(c) == 'HIGH RISK')
                    .toList());
                Navigator.pop(context);
              },
            ),
            ListTile(
              title: Text(t.mediumRisk),
              onTap: () {
                setState(() => _filteredChildren = _allChildren
                    .where((c) => _getChildRiskLevel(c) == 'MEDIUM RISK')
                    .toList());
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }
}
