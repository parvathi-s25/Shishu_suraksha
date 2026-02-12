import 'package:flutter/material.dart';
import 'assessment_screen.dart';

class StartTab extends StatefulWidget {
  const StartTab({Key? key}) : super(key: key);

  @override
  _StartTabState createState() => _StartTabState();
}

enum StartSelectionMode { byAge, byChild }

class _StartTabState extends State<StartTab> {
  StartSelectionMode? _selectionMode = StartSelectionMode.byAge;
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

  // Mock Data (Reusing structure for consistency)
  final Map<String, List<Map<String, dynamic>>> _mockChildren = {
    "0–6 months": [
      {"name": "Aarav", "age": "4 months", "id": "A001"},
      {"name": "Vihaan", "age": "5 months", "id": "A002"},
    ],
    "1–2 years": [
      {"name": "Reyansh", "age": "1.5 years", "id": "C001"},
    ],
    "2–3 years": [
      {"name": "Kiran", "age": "2.5 years", "id": "D001"},
      {"name": "Lata", "age": "2.2 years", "id": "D002"},
    ],
    "3–4 years": [
      {"name": "Mohan", "age": "3.5 years", "id": "E001"},
    ],
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
                  "Assessment Flow",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 10),
                const Text("Follow steps to start assessment", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 30),

                // Step 1: Select Age
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                       const Align(
                         alignment: Alignment.centerLeft,
                         child: Text("1. Select Age Group", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                       ),
                       RadioListTile<StartSelectionMode>(
                        title: const Text("Select by Age"),
                        value: StartSelectionMode.byAge,
                        groupValue: _selectionMode,
                        activeColor: Colors.teal,
                        onChanged: (StartSelectionMode? value) {
                          setState(() {
                             _selectionMode = value;
                          });
                        },
                      ),
                      
                      DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          isExpanded: true,
                          value: _selectedAgeRange,
                          hint: const Text("Choose Age Range"),
                          items: _ageRanges.map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Center(child: Text(value)), // Center text
                            );
                          }).toList(),
                          onChanged: (newValue) {
                            setState(() {
                              _selectedAgeRange = newValue;
                              // Auto move to child selection logic visualization
                              _selectionMode = StartSelectionMode.byChild; 
                            });
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 20),

                // Step 2: Select Child
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  width: 320,
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Align(
                         alignment: Alignment.centerLeft,
                         child: Text("2. Select Child", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal)),
                       ),
                      RadioListTile<StartSelectionMode>(
                        title: const Text("Select Child"),
                        value: StartSelectionMode.byChild,
                        groupValue: _selectionMode,
                        activeColor: Colors.teal,
                        onChanged: (StartSelectionMode? value) {
                          setState(() {
                             _selectionMode = value;
                          });
                        },
                      ),

                      if (_selectedAgeRange != null && displayedChildren.isNotEmpty)
                         ListView.builder(
                           shrinkWrap: true,
                           physics: const NeverScrollableScrollPhysics(),
                           itemCount: displayedChildren.length,
                           itemBuilder: (context, index) {
                             final child = displayedChildren[index];
                             return Card(
                               margin: const EdgeInsets.symmetric(vertical: 4),
                               child: ListTile(
                                 leading: const CircleAvatar(child: Icon(Icons.person)),
                                 title: Text(child['name']),
                                 subtitle: Text("ID: ${child['id']}"),
                                 trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                                 onTap: () {
                                   // Start Assessment
                                   Navigator.push(
                                     context,
                                     MaterialPageRoute(
                                       builder: (context) => AssessmentScreen(child: child),
                                     ),
                                   );
                                 },
                               ),
                             );
                           },
                         )
                      else if (_selectedAgeRange != null)
                        const Padding(padding: EdgeInsets.all(8), child: Text("No children found."))
                      else
                        const Padding(padding: EdgeInsets.all(8), child: Text("Please select an age first."))
                    ],
                  ),
                ),
                
                const SizedBox(height: 50),
              ],
            ),
          ),
        );
      },
    );
  }
}
