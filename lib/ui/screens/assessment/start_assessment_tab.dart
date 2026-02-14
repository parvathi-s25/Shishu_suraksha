import 'package:flutter/material.dart';
import '../dashboard/tabs/assessment_screen.dart';
import '../../../services/responsive_dashboard.dart';

class StartAssessmentTab extends StatefulWidget {
  const StartAssessmentTab({Key? key}) : super(key: key);

  @override
  _StartAssessmentTabState createState() => _StartAssessmentTabState();
}

enum StartSelectionMode { byAge, byChild }

class _StartAssessmentTabState extends State<StartAssessmentTab> {
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
    final responsive = ResponsiveDashboard(context);
    
    List<Map<String, dynamic>> displayedChildren = [];
    if (_selectedAgeRange != null && _mockChildren.containsKey(_selectedAgeRange)) {
      displayedChildren = _mockChildren[_selectedAgeRange]!;
    }

    final containerWidth = responsive.isMobile
        ? MediaQuery.of(context).size.width - responsive.getSpacing(32)
        : (responsive.isTablet ? 350.0 : 420.0);

    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                SizedBox(height: responsive.getSpacing(20)),
                Text(
                  "Assessment Flow",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: responsive.getSpacing(10)),
                Text(
                  "Follow steps to start assessment",
                  style: TextStyle(
                    color: Colors.grey,
                    fontSize: responsive.getFontSize(13),
                  ),
                ),
                SizedBox(height: responsive.getSpacing(30)),

                // Step 1: Select Age
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.getSpacing(16),
                    vertical: responsive.getSpacing(8),
                  ),
                  width: containerWidth.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "1. Select Age Group",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          fontSize: responsive.getFontSize(14),
                        ),
                      ),
                      RadioListTile<StartSelectionMode>(
                        title: Text(
                          "Select by Age",
                          style: TextStyle(fontSize: responsive.getFontSize(13)),
                        ),
                        value: StartSelectionMode.byAge,
                        groupValue: _selectionMode,
                        activeColor: Colors.teal,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: responsive.getSpacing(0),
                        ),
                        onChanged: (StartSelectionMode? value) {
                          setState(() => _selectionMode = value);
                        },
                      ),
                      
                      Container(
                        padding: EdgeInsets.symmetric(
                          horizontal: responsive.getSpacing(8),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<String>(
                            isExpanded: true,
                            value: _selectedAgeRange,
                            hint: Text(
                              "Choose Age Range",
                              style: TextStyle(fontSize: responsive.getFontSize(12)),
                            ),
                            items: _ageRanges.map((String value) {
                              return DropdownMenuItem<String>(
                                value: value,
                                child: Center(
                                  child: Text(
                                    value,
                                    style: TextStyle(
                                      fontSize: responsive.getFontSize(12),
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                            onChanged: (newValue) {
                              setState(() {
                                _selectedAgeRange = newValue;
                                _selectionMode = StartSelectionMode.byChild;
                              });
                            },
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                SizedBox(height: responsive.getSpacing(20)),

                // Step 2: Select Child
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: responsive.getSpacing(16),
                    vertical: responsive.getSpacing(8),
                  ),
                  width: containerWidth.toDouble(),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.teal.withOpacity(0.3)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "2. Select Child",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                          fontSize: responsive.getFontSize(14),
                        ),
                      ),
                      RadioListTile<StartSelectionMode>(
                        title: Text(
                          "Select Child",
                          style: TextStyle(fontSize: responsive.getFontSize(13)),
                        ),
                        value: StartSelectionMode.byChild,
                        groupValue: _selectionMode,
                        activeColor: Colors.teal,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: responsive.getSpacing(0),
                        ),
                        onChanged: (StartSelectionMode? value) {
                          setState(() => _selectionMode = value);
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
                              margin: EdgeInsets.symmetric(
                                vertical: responsive.getSpacing(4),
                              ),
                              child: ListTile(
                                contentPadding: EdgeInsets.symmetric(
                                  horizontal: responsive.getSpacing(12),
                                  vertical: 4,
                                ),
                                leading: CircleAvatar(
                                  backgroundColor: Colors.teal.shade100,
                                  child: Icon(
                                    Icons.person,
                                    color: Colors.teal,
                                    size: responsive.getFontSize(20),
                                  ),
                                ),
                                title: Text(
                                  child['name'],
                                  style: TextStyle(
                                    fontSize: responsive.getFontSize(13),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  "ID: ${child['id']}",
                                  style: TextStyle(
                                    fontSize: responsive.getFontSize(11),
                                  ),
                                ),
                                trailing: Icon(
                                  Icons.arrow_forward_ios,
                                  size: responsive.getFontSize(14),
                                  color: Colors.grey,
                                ),
                                onTap: () {
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
                        Padding(
                          padding: EdgeInsets.all(responsive.getSpacing(8)),
                          child: Text(
                            "No children found.",
                            style: TextStyle(
                              fontSize: responsive.getFontSize(12),
                              color: Colors.grey,
                            ),
                          ),
                        )
                      else
                        Padding(
                          padding: EdgeInsets.all(responsive.getSpacing(8)),
                          child: Text(
                            "Please select an age first.",
                            style: TextStyle(
                              fontSize: responsive.getFontSize(12),
                              color: Colors.grey,
                            ),
                          ),
                        )
                    ],
                  ),
                ),
                
                SizedBox(height: responsive.getSpacing(50)),
              ],
            ),
          ),
        );
      },
    );
  }
}
