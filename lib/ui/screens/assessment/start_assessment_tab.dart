import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import '../../../../services/responsive_dashboard.dart';
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';

// Assessments
import '../dashboard/tabs/assessment_screen.dart';


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
    "0–6 months", "6 months–1 year", "1–2 years", "2–3 years", "3–4 years", "4–5 years", "5–6 years",
  ];

  // Mock Data
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
    
    return SingleChildScrollView(
      padding: responsive.contentPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.startScreening,
            style: TextStyle(
              fontSize: responsive.getFontSize(24),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),




          // --- Standard General Assessment ---
          Text(
            AppLocalizations.of(context)!.generalAssessment,
            style: TextStyle(
              fontSize: responsive.getFontSize(18),
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          SizedBox(height: responsive.getSpacing(16)),
          
          _buildStandardAssessmentFlow(responsive, AppLocalizations.of(context)!),
          


          _buildAIDisclaimer(context, responsive),

          SizedBox(height: responsive.getSpacing(80)),
        ],
      ),
    );
  }



  Widget _buildStandardAssessmentFlow(ResponsiveDashboard responsive, AppLocalizations t) {
    List<Map<String, dynamic>> displayedChildren = [];
    if (_selectedAgeRange != null && _mockChildren.containsKey(_selectedAgeRange)) {
      displayedChildren = _mockChildren[_selectedAgeRange]!;
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildStepTitle(1, t.selectAge, responsive),
          const SizedBox(height: 12),
          Container(
             padding: const EdgeInsets.symmetric(horizontal: 12),
             decoration: BoxDecoration(
               border: Border.all(color: AppColors.border),
               borderRadius: BorderRadius.circular(8),
             ),
             child: DropdownButtonHideUnderline(
               child: DropdownButton<String>(
                 isExpanded: true,
                 value: _selectedAgeRange,
                 hint: Text(t.chooseAgeRange),
                 items: _ageRanges.map((String value) {
                   return DropdownMenuItem<String>(
                     value: value,
                     child: Text(value),
                   );
                 }).toList(),
                 onChanged: (newValue) {
                   setState(() {
                     _selectedAgeRange = newValue;
                   });
                 },
               ),
             ),
          ),
          
          const SizedBox(height: 24),
          _buildStepTitle(2, t.selectChild, responsive),
          const SizedBox(height: 12),
          
          if (_selectedAgeRange != null)
             displayedChildren.isNotEmpty
             ? ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: displayedChildren.length,
                separatorBuilder: (c, i) => const Divider(height: 1),
                itemBuilder: (context, index) {
                  final child = displayedChildren[index];
                  return ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: AppColors.primary.withOpacity(0.1),
                      child: const Icon(Icons.person, color: AppColors.primary, size: 20),
                    ),
                    title: Text(child['name'], style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Text("${t.idLabel}: ${child['id']}"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.textSecondary),
                    onTap: () {
                       Navigator.push(
                         context,
                         MaterialPageRoute(
                           builder: (context) => AssessmentScreen(child: child),
                         ),
                       );
                    },
                  );
                },
             )
             : Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(t.noChildrenFound, style: TextStyle(color: AppColors.textSecondary)),
             )
          else
             Padding(
               padding: const EdgeInsets.all(8.0),
               child: Text(t.plzSelectAge, style: TextStyle(color: AppColors.textSecondary)),
             ),
        ],
      ),
    );
  }

  Widget _buildStepTitle(int step, String title, ResponsiveDashboard responsive) {
    return Row(
      children: [
        Container(
          width: 24, height: 24,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: Text(
            step.toString(),
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            title,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
              fontSize: responsive.getFontSize(14),
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildAIDisclaimer(BuildContext context, ResponsiveDashboard responsive) {
    final t = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(top: 24),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.orange.withOpacity(0.3)),
        boxShadow: [
          BoxShadow(
            color: Colors.orange.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: Colors.orange[700], size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  t.aiDisclaimerTitle,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.orange[900],
                    fontSize: responsive.getFontSize(16),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  t.aiDisclaimerBody,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: responsive.getFontSize(14),
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
