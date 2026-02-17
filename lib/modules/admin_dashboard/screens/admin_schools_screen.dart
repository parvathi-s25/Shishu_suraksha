
import 'package:flutter/material.dart';
import 'package:shishu_suraksha/l10n/app_localizations.dart';
import '../../../../app/theme/colors.dart';

class AdminSchoolsScreen extends StatelessWidget {
  const AdminSchoolsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final t = AppLocalizations.of(context)!;
    
    // Mock Data
    final schools = [
      {'name': 'MPS Delhi', 'students': 450, 'status': 'Active', 'risk': 'Low'},
      {'name': 'KV Noida', 'students': 320, 'status': 'Active', 'risk': 'Medium'},
      {'name': 'Govt School #4', 'students': 180, 'status': 'Active', 'risk': 'High'},
      {'name': 'Anganwadi Center 1', 'students': 45, 'status': 'Active', 'risk': 'Low'},
      {'name': 'Public School Dwarka', 'students': 560, 'status': 'Inactive', 'risk': 'N/A'},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(t.totalSchools),
        automaticallyImplyLeading: false,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: schools.length,
        itemBuilder: (context, index) {
          final school = schools[index];
          final isHighRisk = school['risk'] == 'High';
          
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              leading: CircleAvatar(
                backgroundColor: isHighRisk ? Colors.red[100] : Colors.blue[100],
                child: Icon(
                  Icons.school, 
                  color: isHighRisk ? Colors.red : Colors.blue
                ),
              ),
              title: Text(school['name'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Text("Students: ${school['students']} • Status: ${school['status']}"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: isHighRisk ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  school['risk'] as String,
                  style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
