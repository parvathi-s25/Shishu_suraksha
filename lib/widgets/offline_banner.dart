import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import '../l10n/generated/app_localizations.dart';

class OfflineModeBanner extends StatelessWidget {
  const OfflineModeBanner({super.key});

  @override
  Widget build(BuildContext context) {
    // Ideally, check connectivity here or via a provider
    // For now, this widget is static and can be conditionally shown
    return Container(
      width: double.infinity,
      color: Colors.black87,
      padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, color: Colors.white, size: 16),
          const SizedBox(width: 8),
          Text(
            AppLocalizations.of(context)?.offlineModeActive ?? 'Offline Mode Active',
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}
