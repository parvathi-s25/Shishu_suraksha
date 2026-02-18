import 'package:flutter/material.dart';
import 'package:shishu_suraksha/app/theme/colors.dart';
import '../../../../services/responsive_dashboard.dart';
import 'package:shishu_suraksha/l10n/generated/app_localizations.dart';

// Assessments
import '../dashboard/tabs/assessment_screen.dart';
import '../../../modules/ai_motor/screens/pose_detector_view.dart';
import '../../../modules/ai_audio/screens/hearing_test_screen.dart';
import '../../../modules/ai_audio/screens/speech_assessment_screen.dart';
import '../../../modules/vision/screens/vision_home_screen.dart';

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
          Text(
            AppLocalizations.of(context)!.selectAssessmentType,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: responsive.getFontSize(14),
            ),
          ),
          SizedBox(height: responsive.getSpacing(24)),

          // --- AI Powered Screenings ---
          Text(
            AppLocalizations.of(context)!.aiPoweredScreenings,
            style: TextStyle(
              fontSize: responsive.getFontSize(18),
              fontWeight: FontWeight.bold,
              color: AppColors.primary,
            ),
          ),
          SizedBox(height: responsive.getSpacing(16)),
          GridView.count(
            crossAxisCount: responsive.isMobile ? 2 : 4,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: responsive.getSpacing(16),
            crossAxisSpacing: responsive.getSpacing(16),
            childAspectRatio: 1.1,
            children: [
              _buildAssessmentCard(
                title: AppLocalizations.of(context)!.motorDevelopment,
                subtitle: AppLocalizations.of(context)!.poseDetection,
                icon: Icons.accessibility_new,
                color: Colors.orange,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const PoseDetectorView())),
                responsive: responsive,
              ),
              _buildAssessmentCard(
                title: AppLocalizations.of(context)!.hearingTest,
                subtitle: AppLocalizations.of(context)!.audioToneAnalysis,
                icon: Icons.hearing,
                color: Colors.blue,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const HearingTestScreen())),
                responsive: responsive,
              ),
              _buildAssessmentCard(
                title: AppLocalizations.of(context)!.speechAndFluency,
                subtitle: AppLocalizations.of(context)!.voiceAnalysis,
                icon: Icons.record_voice_over,
                color: Colors.purple,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const SpeechAssessmentScreen())),
                responsive: responsive,
              ),
              _buildAssessmentCard(
                title: "Vision Screening", // TODO: Localize
                subtitle: "Acuity, Color, Strabismus",
                icon: Icons.remove_red_eye,
                color: Colors.indigo,
                onTap: () => Navigator.push(context, MaterialPageRoute(builder: (c) => const VisionHomeScreen(childId: 'quick_test'))),
                responsive: responsive,
              ),
              _buildAssessmentCard(
                title: AppLocalizations.of(context)!.physicalHealth,
                subtitle: AppLocalizations.of(context)!.bodyAnalysis,
                icon: Icons.monitor_weight,
                color: Colors.teal,
                onTap: () {}, // Future integration
                responsive: responsive,
                isComingSoon: true,
              ),
            ],
          ),

          SizedBox(height: responsive.getSpacing(32)),
          const Divider(thickness: 1, color: AppColors.border),
          SizedBox(height: responsive.getSpacing(32)),

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
          
          SizedBox(height: responsive.getSpacing(80)),
        ],
      ),
    );
  }

  Widget _buildAssessmentCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    required ResponsiveDashboard responsive,
    bool isComingSoon = false,
  }) {
    return InkWell(
      onTap: isComingSoon ? null : onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.border),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(icon, color: color, size: 30),
                ),
                if (isComingSoon)
                  Positioned(
                    right: -10,
                    top: -10,
                    child: Container(
                       padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                       decoration: BoxDecoration(color: Colors.grey[400], borderRadius: BorderRadius.circular(4)),
                       child: Text(AppLocalizations.of(context)!.comingSoon, style: const TextStyle(fontSize: 8, color: Colors.white)),
                    ),
                  )
              ],
            ),
            const SizedBox(height: 12),
            Text(
              title,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: responsive.getFontSize(14),
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: responsive.getFontSize(11),
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
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
}
