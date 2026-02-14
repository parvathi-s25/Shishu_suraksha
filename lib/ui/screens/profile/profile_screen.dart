import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("My Profile", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        leading: const BackButton(color: Colors.black),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 20),
            const CircleAvatar(
              radius: 50,
              backgroundColor: Colors.teal,
              child: Icon(Icons.person, size: 50, color: Colors.white),
            ),
            const SizedBox(height: 10),
            const Text(
              "Anganwadi Worker",
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const Text(
              "Center ID: AW-1024 • Zone: Karnataka North",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),
            _buildStatRow(),
            const Divider(),
            _buildProfileOption(Icons.location_on, "My Center Details"),
            _buildProfileOption(Icons.history, "Activity Log"),
            _buildProfileOption(Icons.settings, "Settings"),
            _buildProfileOption(Icons.logout, "Logout", color: Colors.red),
          ],
        ),
      ),
    );
  }

  Widget _buildStatRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem("42", "Children"),
        _buildStatItem("12", "Pending Tasks"),
        _buildStatItem("98%", "Vaccination"),
      ],
    );
  }

  Widget _buildStatItem(String count, String label) {
    return Column(
      children: [
        Text(count, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal)),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }

  Widget _buildProfileOption(IconData icon, String title, {Color color = Colors.black}) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(title, style: TextStyle(color: color)),
      trailing: const Icon(Icons.chevron_right),
      onTap: () {},
    );
  }
}
