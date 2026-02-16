import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';

import '../../../core/services/data_service.dart';

class TasksScreen extends StatelessWidget {
  const TasksScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Reminders", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.download, color: Colors.green),
            tooltip: 'Export to Excel',
            onPressed: () async {
              String path = await DataService().exportToExcel();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Data Exported to $path')),
              );
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildSectionHeader("Overdue", Colors.red),
          _buildTaskItem("Vaccination: Polio", "Ravi Kumar (3y)", "Overdue by 2 days", Colors.red),
          
          const SizedBox(height: 16),
          _buildSectionHeader("Upcoming", Colors.black),
          _buildTaskItem("Home Visit: Post-Natal", "Sunita Devi", "Due Tomorrow", Colors.orange),
          _buildTaskItem("Growth Monitoring", "Amit Patel (6m)", "Due in 3 days", Colors.teal),
          _buildTaskItem("Vitamin A Supplement", "All Children (1-5y)", "Due in 5 days", Colors.blue),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.primary,
        child: const Icon(Icons.add),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Text(
        title,
        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color),
      ),
    );
  }

  Widget _buildTaskItem(String title, String subtitle, String due, Color color) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.1),
           child: Icon(Icons.task_alt, color: color),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text("$subtitle • $due"),
        trailing: const Icon(Icons.chevron_right, color: Colors.grey),
        onTap: () {},
      ),
    );
  }
}
