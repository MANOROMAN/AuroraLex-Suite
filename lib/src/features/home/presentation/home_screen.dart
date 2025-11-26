import 'package:flutter/material.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/i18n/app_localizations.dart';
import '../../dashboard/presentation/ai_chat_tab.dart';
import '../../dashboard/presentation/calendar_tab.dart';
import '../../dashboard/presentation/case_tracker_tab.dart';
import '../../dashboard/presentation/legal_dictionary_tab.dart';
import '../../dashboard/presentation/settings_tab.dart';

class AuroraHomeScreen extends ConsumerStatefulWidget {
  const AuroraHomeScreen({super.key});

  @override
  ConsumerState<AuroraHomeScreen> createState() => _AuroraHomeScreenState();
}

class _AuroraHomeScreenState extends ConsumerState<AuroraHomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    
    final tabs = [
      _AuroraTab(
        label: l10n.aiChat,
        icon: Icons.auto_awesome,
        widget: const AiChatTab(),
      ),
      _AuroraTab(
        label: l10n.caseTracker,
        icon: Icons.track_changes,
        widget: const CaseTrackerTab(),
      ),
      _AuroraTab(
        label: l10n.legalDictionary,
        icon: Icons.menu_book,
        widget: const LegalDictionaryTab(),
      ),
      _AuroraTab(
        label: l10n.calendar,
        icon: Icons.calendar_today,
        widget: const CalendarTab(),
      ),
      _AuroraTab(
        label: l10n.settings,
        icon: Icons.settings,
        widget: const SettingsTab(),
      ),
    ];
    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: const BoxDecoration(
          color: Color(0xFF101922),
        ),
        child: SafeArea(child: _buildActiveTab(tabs)),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: const Color(0xFF0d1419),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 8,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.transparent,
          selectedItemColor: const Color(0xFF1173d4),
          unselectedItemColor: Colors.grey.shade600,
          selectedFontSize: 10,
          unselectedFontSize: 10,
          elevation: 0,
          items: tabs
              .map(
                (tab) => BottomNavigationBarItem(
                  icon: Icon(tab.icon),
                  label: tab.label,
                ),
              )
              .toList(),
        ),
      ),
    );
  }

  Widget _buildActiveTab(List<_AuroraTab> tabs) {
    return IndexedStack(
      index: _currentIndex,
      children: tabs.map((tab) => tab.widget).toList(),
    );
  }
}

class _AuroraTab {
  const _AuroraTab({
    required this.label,
    required this.icon,
    required this.widget,
  });

  final String label;
  final IconData icon;
  final Widget widget;
}
