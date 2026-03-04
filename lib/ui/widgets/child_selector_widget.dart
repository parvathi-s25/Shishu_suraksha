
import 'package:flutter/material.dart';

class ChildSelectorWidget extends StatelessWidget {
  final List<Map<String, dynamic>> children;
  final String selectedChildId;
  final Function(String childId, String childName) onChildSelected;

  const ChildSelectorWidget({
    Key? key,
    required this.children,
    required this.selectedChildId,
    required this.onChildSelected,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 16),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: children.length,
        itemBuilder: (context, index) {
          final child = children[index];
          final isSelected = child['id'] == selectedChildId;

          return GestureDetector(
            onTap: () => onChildSelected(child['id'], child['name']),
            child: Container(
              width: 80,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: isSelected ? Colors.teal : Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected ? Colors.teal : Colors.grey.shade300,
                  width: 2,
                ),
                boxShadow: isSelected ? [
                  BoxShadow(
                    color: Colors.teal.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  )
                ] : null,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                   CircleAvatar(
                     radius: 20,
                     backgroundColor: isSelected ? Colors.white : Colors.teal.shade50,
                     child: Text(
                       child['name'][0],
                       style: TextStyle(
                         color: isSelected ? Colors.teal : Colors.teal.shade700,
                         fontWeight: FontWeight.bold,
                       ),
                     ),
                   ),
                   const SizedBox(height: 8),
                   Padding(
                     padding: const EdgeInsets.symmetric(horizontal: 4.0),
                     child: Text(
                       child['name'].split(' ')[0],
                       style: TextStyle(
                         fontSize: 12,
                         fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                         color: isSelected ? Colors.white : Colors.black87,
                       ),
                       overflow: TextOverflow.ellipsis,
                     ),
                   ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
