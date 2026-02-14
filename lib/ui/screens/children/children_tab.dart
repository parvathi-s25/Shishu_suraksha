import 'package:flutter/material.dart';
import 'package:shishu_suraksha/ui/widgets/health_indicator_widget.dart';
import '../dashboard/tabs/child_report_screen.dart';
import '../../../services/responsive_dashboard.dart';

class ChildrenTab extends StatefulWidget {
  const ChildrenTab({Key? key}) : super(key: key);

  @override
  _ChildrenTabState createState() => _ChildrenTabState();
}

enum SelectionMode { byAge, byChild }

class _ChildrenTabState extends State<ChildrenTab> {
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
      {"name": "Aarav", "age": "4 months", "id": "A001", "status": HealthStatus.good},
      {"name": "Vihaan", "age": "5 months", "id": "A002", "status": HealthStatus.needsAttention},
      {"name": "Ishaan", "age": "2 months", "id": "A003", "status": HealthStatus.excellent},
    ],
    "6 months–1 year": [
      {"name": "Aditya", "age": "8 months", "id": "B001", "status": HealthStatus.critical},
      {"name": "Sai", "age": "11 months", "id": "B002", "status": HealthStatus.good},
    ],
    "1–2 years": [
      {"name": "Reyansh", "age": "1.5 years", "id": "C001", "status": HealthStatus.good},
      {"name": "Arjun", "age": "1.2 years", "id": "C002", "status": HealthStatus.excellent},
    ],
  };

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final responsive = ResponsiveDashboard(context);
    
    List<Map<String, dynamic>> displayedChildren = [];
    if (_selectedAgeRange != null && _mockChildren.containsKey(_selectedAgeRange)) {
      displayedChildren = _mockChildren[_selectedAgeRange]!;
    }

    final containerWidth = responsive.isMobile
        ? MediaQuery.of(context).size.width - responsive.getSpacing(32)
        : (responsive.isTablet ? 400.0 : 500.0);

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
                  "Child Growth Monitoring",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: responsive.getFontSize(22),
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                SizedBox(height: responsive.getSpacing(30)),

                // Radio Option 1 -> Select by Age
                SizedBox(
                  width: containerWidth.toDouble(),
                  child: RadioListTile<SelectionMode>(
                    title: Text(
                      "Select by Age",
                      style: TextStyle(fontSize: responsive.getFontSize(14)),
                    ),
                    value: SelectionMode.byAge,
                    groupValue: _selectionMode,
                    activeColor: Colors.teal,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsive.getSpacing(12),
                    ),
                    onChanged: (SelectionMode? value) {
                      setState(() => _selectionMode = value);
                    },
                  ),
                ),

                // Dropdown for Age Range
                if (_selectionMode == SelectionMode.byAge) ...[
                  Container(
                    width: containerWidth.toDouble(),
                    padding: EdgeInsets.symmetric(
                      horizontal: responsive.getSpacing(12),
                    ),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.teal),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        isExpanded: true,
                        value: _selectedAgeRange,
                        hint: Text(
                          "Choose Age Range",
                          style: TextStyle(fontSize: responsive.getFontSize(13)),
                        ),
                        items: _ageRanges.map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Center(
                              child: Text(
                                value,
                                style: TextStyle(
                                  fontSize: responsive.getFontSize(13),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() => _selectedAgeRange = newValue);
                        },
                      ),
                    ),
                  ),
                ],
                
                SizedBox(height: responsive.getSpacing(20)),

                // Radio Option 2 -> Select Child
                SizedBox(
                  width: containerWidth.toDouble(),
                  child: RadioListTile<SelectionMode>(
                    title: Text(
                      "Select Child",
                      style: TextStyle(fontSize: responsive.getFontSize(14)),
                    ),
                    value: SelectionMode.byChild,
                    groupValue: _selectionMode,
                    activeColor: Colors.teal,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: responsive.getSpacing(12),
                    ),
                    onChanged: (SelectionMode? value) {
                      setState(() => _selectionMode = value);
                    },
                  ),
                ),

                // Child List
                if (_selectionMode == SelectionMode.byChild || _selectedAgeRange != null) ...[
                  if (_selectedAgeRange == null)
                    Padding(
                      padding: EdgeInsets.all(responsive.getSpacing(8)),
                      child: Text(
                        "Please select an age range first.",
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: responsive.getFontSize(12),
                        ),
                      ),
                    )
                  else if (displayedChildren.isEmpty)
                    Padding(
                      padding: EdgeInsets.all(responsive.getSpacing(8)),
                      child: Text(
                        "No children found in this age group.",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: responsive.getFontSize(12),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: containerWidth.toDouble(),
                      height: responsive.isMobile ? 250 : (responsive.isTablet ? 300 : 350),
                      margin: EdgeInsets.only(top: responsive.getSpacing(10)),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: ListView.builder(
                        itemCount: displayedChildren.length,
                        itemBuilder: (context, index) {
                          final child = displayedChildren[index];
                          return Card(
                            margin: EdgeInsets.symmetric(
                              horizontal: responsive.getSpacing(8),
                              vertical: responsive.getSpacing(4),
                            ),
                            child: ListTile(
                              contentPadding: EdgeInsets.symmetric(
                                horizontal: responsive.getSpacing(12),
                                vertical: 4,
                              ),
                              leading: CircleAvatar(
                                backgroundColor: Colors.teal.shade100,
                                radius: responsive.getSpacing(20),
                                child: Text(
                                  child['name'][0],
                                  style: TextStyle(
                                    color: Colors.teal,
                                    fontSize: responsive.getFontSize(16),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              title: Text(
                                child['name'],
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: responsive.getFontSize(14),
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              subtitle: Text(
                                "ID: ${child['id']} • Age: ${child['age']}",
                                textAlign: TextAlign.start,
                                style: TextStyle(
                                  fontSize: responsive.getFontSize(11),
                                  color: Colors.grey,
                                ),
                              ),
                              trailing: HealthIndicatorWidget(
                                status: child['status'] as HealthStatus,
                                label: '',
                                showBadge: true,
                              ),
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

                SizedBox(height: responsive.getSpacing(50)),
              ],
            ),
          ),
        );
      },
    );
  }
}
