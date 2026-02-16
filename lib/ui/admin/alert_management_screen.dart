import 'package:flutter/material.dart';
import '../../core/data/models/admin_models.dart';
import '../../core/data/services/admin_data_service.dart';
import 'package:intl/intl.dart';

class AlertManagementScreen extends StatefulWidget {
  const AlertManagementScreen({Key? key}) : super(key: key);

  @override
  State<AlertManagementScreen> createState() => _AlertManagementScreenState();
}

class _AlertManagementScreenState extends State<AlertManagementScreen> {
  final AdminDataService _dataService = AdminDataService();
  List<AlertModel> _alerts = [];
  bool _isLoading = true;
  String _filter = 'All'; // All, High, Medium, Low

  @override
  void initState() {
    super.initState();
    _loadAlerts();
  }

  Future<void> _loadAlerts() async {
    setState(() => _isLoading = true);
    final alerts = await _dataService.getActiveAlerts();
    if (mounted) {
      setState(() {
        _alerts = alerts;
        _isLoading = false;
      });
    }
  }

  Future<void> _resolveAlert(String id) async {
    await _dataService.resolveAlert(id);
    _loadAlerts(); // Reload list
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Alert marked as resolved'), backgroundColor: Colors.green),
    );
  }

  List<AlertModel> get _filteredAlerts {
    if (_filter == 'All') return _alerts;
    return _alerts.where((a) => a.severity == _filter).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Management'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.filter_list),
            onSelected: (value) => setState(() => _filter = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 'All', child: Text('All Severities')),
              const PopupMenuItem(value: 'High', child: Text('High Only')),
              const PopupMenuItem(value: 'Medium', child: Text('Medium Only')),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _filteredAlerts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.check_circle_outline, size: 64, color: Colors.green[200]),
                      const SizedBox(height: 16),
                      Text('No Active $_filter Alerts', style: const TextStyle(color: Colors.grey, fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _filteredAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = _filteredAlerts[index];
                    return Dismissible(
                      key: Key(alert.id),
                      background: Container(
                        color: Colors.green,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.only(right: 20),
                        child: const Icon(Icons.check, color: Colors.white),
                      ),
                      direction: DismissDirection.endToStart,
                      onDismissed: (_) => _resolveAlert(alert.id),
                      confirmDismiss: (direction) async {
                        return await showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Resolve Alert?'),
                            content: const Text('This will mark the issue as addressed.'),
                            actions: [
                              TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
                              TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Resolve')),
                            ],
                          ),
                        );
                      },
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: _getSeverityColor(alert.severity).withOpacity(0.3), width: 1)
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          leading: CircleAvatar(
                            backgroundColor: _getSeverityColor(alert.severity).withOpacity(0.1),
                            child: Icon(_getSeverityIcon(alert.severity), color: _getSeverityColor(alert.severity)),
                          ),
                          title: Text(alert.issue, style: const TextStyle(fontWeight: FontWeight.bold)),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 4),
                              Text('${alert.childName} • ${alert.schoolName}'),
                              const SizedBox(height: 4),
                              Text(
                                DateFormat('MMM d, h:mm a').format(alert.timestamp),
                                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                              ),
                            ],
                          ),
                          trailing: IconButton(
                            icon: const Icon(Icons.check_circle_outline, color: Colors.grey),
                            onPressed: () => _resolveAlert(alert.id), // Direct action
                          ),
                        ),
                      ),
                    );
                  },
                ),
    );
  }

  Color _getSeverityColor(String severity) {
    switch (severity) {
      case 'High': return Colors.red;
      case 'Medium': return Colors.orange;
      default: return Colors.blue;
    }
  }

  IconData _getSeverityIcon(String severity) {
    switch (severity) {
      case 'High': return Icons.warning;
      case 'Medium': return Icons.info;
      default: return Icons.priority_high;
    }
  }
}
