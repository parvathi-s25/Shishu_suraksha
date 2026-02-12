import 'package:flutter/material.dart';
import 'child_report_screen.dart';

class ChildTab extends StatefulWidget {
  const ChildTab({Key? key}) : super(key: key);

  @override
  _ChildTabState createState() => _ChildTabState();
}

enum SelectionMode { byAge, byChild }

class _ChildTabState extends State<ChildTab> {
  SelectionMode? _selectionMode = SelectionMode.byAge;
  String? _selectedAgeRange;
  
  final List<String> _ageRanges = [
    "0–6 months",
    "6 months–1 year",
    "1–2 years",
    "2–3 years",
    "3–4 years",
    "4–5 years",
    "5–6 years",
  ];

  // Mock Data
  final Map<String, List<Map<String, dynamic>>> _mockChildren = {
    "0–6 months": [
      {"name": "Aarav", "age": "4 months", "id": "A001"},
      {"name": "Vihaan", "age": "5 months", "id": "A002"},
      {"name": "Ishaan", "age": "2 months", "id": "A003"},
    ],
    "6 months–1 year": [
      {"name": "Aditya", "age": "8 months", "id": "B001"},
      {"name": "Sai", "age": "11 months", "id": "B002"},
    ],
    "1–2 years": [
      {"name": "Reyansh", "age": "1.5 years", "id": "C001"},
      {"name": "Arjun", "age": "1.2 years", "id": "C002"},
    ],
    // Add more if needed, default mostly empty for simplicity
  };

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> displayedChildren = [];
    if (_selectedAgeRange != null && _mockChildren.containsKey(_selectedAgeRange)) {
      displayedChildren = _mockChildren[_selectedAgeRange]!;
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center, // Vertically center content
              crossAxisAlignment: CrossAxisAlignment.center, // Horizontally center content
              children: [
                const SizedBox(height: 20),
                const Text(
                  "Child Growth Monitoring",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 30),

                // Radio Option 1 -> Select by Age
                SizedBox(
                  width: 300, // Limit width for centering
                  child: RadioListTile<SelectionMode>(
                    title: const Text("Select by Age"),
                    value: SelectionMode.byAge,
                    groupValue: _selectionMode,
                    activeColor: Colors.teal,
                    onChanged: (SelectionMode? value) {
                      setState(() {
                         _selectionMode = value;
                      });
                    },
                  ),
                ),

                // Dropdown (Visible/Active only if Age Mode OR just always visible but logically tied?)
                // Requirement: "Show a dropdown" under Option 1.
                if (_selectionMode == SelectionMode.byAge) ...[
                  Container(
                    width: 280,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedAgeRange,
                        hint: const Text("Choose Age Range"),
                        items: _ageRanges.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(child: Text(value)), // Center text in dropdown
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _selectedAgeRange = newValue;
                            // Auto-switch to child selection mode if age selected? 
                            // Or keep it here. Let's keep smooth flow.
                          });
                        },
                      ),
                    ),
                  ),
                ],
                
                const SizedBox(height: 20),

                // Radio Option 2 -> Select Child
                SizedBox(
                  width: 300,
                  child: RadioListTile<SelectionMode>(
                    title: const Text("Select Child"),
                    value: SelectionMode.byChild,
                    groupValue: _selectionMode,
                    activeColor: Colors.teal,
                    onChanged: (SelectionMode? value) {
                      setState(() {
                         _selectionMode = value;
                      });
                    },
                  ),
                ),

                // Child List (Dynamic based on age selected)
                // Requirement: "Show dynamic child names based on the age selected"
                // Visible when Mode is byChild? Or just always, but filtered?
                // "When a child name is clicked -> Open Child Report Screen"
                
                if (_selectionMode == SelectionMode.byChild) ...[
                   if (_selectedAgeRange == null)
                     const Padding(
                       padding: EdgeInsets.all(8.0),
                       child: Text("Please select an age range first.", style: TextStyle(color: Colors.red)),
                     )
                   else if (displayedChildren.isEmpty)
                     const Padding(
                       padding: EdgeInsets.all(8.0),
                       child: Text("No children found in this age group.", style: TextStyle(color: Colors.grey)),
                     )
                   else
                     Container(
                       width: 300,
                       height: 300, // Fixed height or flexible?
                       margin: const EdgeInsets.only(top: 10),
                       decoration: BoxDecoration(
                         border: Border.all(color: Colors.grey.withOpacity(0.3)),
                         borderRadius: BorderRadius.circular(12),
                       ),
                       child: ListView.builder(
                         itemCount: displayedChildren.length,
                         itemBuilder: (context, index) {
                           final child = displayedChildren[index];
                           return Card(
                             margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                             child: ListTile(
                               leading: CircleAvatar(
                                 backgroundColor: Colors.teal.shade100,
                                 child: Text(child['name'][0], style: const TextStyle(color: Colors.teal)),
                               ),
                               title: Text(child['name'], textAlign: TextAlign.center), // Center text
                               subtitle: Text("ID: ${child['id']}", textAlign: TextAlign.center),
                               onTap: () {
                                 Navigator.push(
                                   context,
                                   MaterialPageRoute(
                                     builder: (context) => ChildReportScreen(child: child),
                                   ),
                                 );
                               },
                             ),
                           );
                         },
                       ),
                     ),
                ],

                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
