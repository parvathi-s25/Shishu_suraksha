import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../../../l10n/app_localizations.dart';

class AdminSidebar extends StatelessWidget {
  final Function(int) onIndexChanged;
  final int selectedIndex;

  const AdminSidebar({
    super.key,
    required this.onIndexChanged,
    required this.selectedIndex,
  });

  @override
  Widget build(BuildContext context) {
    var l10n = AppLocalizations.of(context)!;
    return Container(
      width: 250,
      color: AppTheme.surfaceLight,
      child: Column(
        children: [
          const SizedBox(height: 32),
          Text(
            'ShishuSuraksha',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryColor,
            ),
          ),
          const SizedBox(height: 48),
          _buildMenuItem(context, 0, Icons.dashboard, l10n.overview),
          _buildMenuItem(context, 1, Icons.school, l10n.totalSchools),
          _buildMenuItem(context, 2, Icons.child_care, l10n.children),
          _buildMenuItem(context, 3, Icons.analytics, l10n.reports),
          _buildMenuItem(context, 4, Icons.settings, l10n.admin),
        ],
      ),
    );
  }

  Widget _buildMenuItem(BuildContext context, int index, IconData icon, String title) {
    bool isSelected = selectedIndex == index;
    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? AppTheme.primaryColor : AppTheme.textSecondary,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onTap: () => onIndexChanged(index),
    );
  }
}
