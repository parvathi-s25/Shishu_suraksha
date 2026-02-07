import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import 'package:shishu_suraksha/data/models/child_model.dart';
import 'package:shishu_suraksha/data/services/storage_service.dart';
import 'package:shishu_suraksha/ui/widgets/glass_container.dart';
import 'package:shishu_suraksha/ui/screens/children/add_child_screen.dart';
import 'package:intl/intl.dart';

class ChildrenTab extends ConsumerStatefulWidget {
  const ChildrenTab({super.key});

  @override
  ConsumerState<ChildrenTab> createState() => _ChildrenTabState();
}

class _ChildrenTabState extends ConsumerState<ChildrenTab> {
  List<ChildModel> _children = [];

  @override
  void initState() {
    super.initState();
    _loadChildren();
  }

  void _loadChildren() {
    // In a real app with ValueListenableBuilder, this would be automatic.
    // For simplicity, we just reload on init and when returning from Add Screen.
    setState(() {
      _children = ref.read(storageServiceProvider).getAllChildren();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Children List',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.refresh, color: Colors.white),
                  onPressed: _loadChildren,
                ),
              ],
            ),
          ),

          // Search Bar (Visual Only for now)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: GlassContainer(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: const TextField(
                style: TextStyle(color: Colors.white),
                decoration: InputDecoration(
                  hintText: 'Search by name or ID...',
                  hintStyle: TextStyle(color: Colors.white54),
                  border: InputBorder.none,
                  icon: Icon(Icons.search, color: Colors.white),
                ),
              ),
            ),
          ),

          const SizedBox(height: 10),

          // List
          Expanded(
            child: _children.isEmpty
                ? const Center(
                    child: Text(
                      'No children added yet.',
                      style: TextStyle(color: Colors.white70),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _children.length,
                    itemBuilder: (context, index) {
                      final child = _children[index];
                      // Calculate age
                      final age = DateTime.now().difference(child.dob).inDays ~/ 365;
                      
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: GlassContainer(
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: AppColors.secondary,
                              child: Text(
                                child.name[0].toUpperCase(),
                                style: const TextStyle(color: Colors.white),
                              ),
                            ),
                            title: Text(
                              child.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                            subtitle: Text(
                              'Age: $age yrs • ${child.gender}',
                              style: const TextStyle(color: AppColors.textSecondary),
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white54, size: 16),
                            onTap: () {
                              // Navigate to details (Future)
                            },
                          ),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddChildScreen()),
          );
          _loadChildren(); // Refresh list on return
        },
        backgroundColor: AppColors.secondary,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
