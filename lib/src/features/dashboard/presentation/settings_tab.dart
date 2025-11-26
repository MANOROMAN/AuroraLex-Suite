import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/controllers/language_controller.dart';
import '../../../core/controllers/theme_controller.dart';
import '../../../core/i18n/app_localizations.dart';
import '../../auth/data/auth_service.dart';

class SettingsTab extends HookConsumerWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final currentUserAsync = ref.watch(currentUserProvider);
    final l10n = AppLocalizations.of(context);

    return currentUserAsync.when(
      data: (userData) {
        final displayName = userData?.displayName ?? 
                           ref.watch(authServiceProvider).currentUser?.email?.split('@').first ?? 
                           l10n.username;
        final email = userData?.email ?? 
                     ref.watch(authServiceProvider).currentUser?.email ?? 
                     '';
        final photoUrl = ref.watch(authServiceProvider).currentUser?.photoURL;
        
        return ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              l10n.settings,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            // Profil Kartı
            Card(
              color: const Color(0xFF1a2633),
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 36,
                      backgroundColor: const Color(0xFF1173d4),
                      backgroundImage: photoUrl != null 
                          ? NetworkImage(photoUrl)
                          : null,
                      child: photoUrl == null
                          ? Text(
                              displayName[0].toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            style: TextStyle(
                              color: Colors.grey.shade400,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
        const SizedBox(height: 20),
        // Görünüm Ayarları
        _buildSection(
          title: l10n.appearance,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.language, color: Colors.grey.shade500),
              title: Text(l10n.language, style: const TextStyle(color: Colors.white)),
              subtitle: Text(
                locale.languageCode == 'tr' ? l10n.turkish : l10n.english,
                style: TextStyle(color: Colors.grey.shade400),
              ),
              trailing: DropdownButton<Locale>(
                dropdownColor: const Color(0xFF1a2633),
                value: locale,
                underline: const SizedBox.shrink(),
                style: const TextStyle(color: Colors.white),
                onChanged: (value) {
                  if (value != null) {
                    ref.read(localeProvider.notifier).update(value);
                  }
                },
                items: [
                  DropdownMenuItem(value: const Locale('tr'), child: Text(l10n.turkish)),
                  DropdownMenuItem(value: const Locale('en'), child: Text(l10n.english)),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Hesap Ayarları
        _buildSection(
          title: l10n.account,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(Icons.email, color: Color(0xFF1173d4)),
              title: Text(
                l10n.emailAddress,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                email,
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const Divider(color: Color(0xFF2a3744)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.person, color: Colors.grey.shade500),
              title: Text(
                l10n.username,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                displayName,
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
        const SizedBox(height: 20),
        // Hakkında
        _buildSection(
          title: l10n.about,
          children: [
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.info_outline, color: Colors.grey.shade500),
              title: Text(
                l10n.version,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                '1.0.0',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
            const Divider(color: Color(0xFF2a3744)),
            ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Icon(Icons.description, color: Colors.grey.shade500),
              title: Text(
                l10n.appInfo,
                style: const TextStyle(color: Colors.white),
              ),
              subtitle: Text(
                l10n.appDescription,
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        // Çıkış Yap Butonu
        OutlinedButton.icon(
          onPressed: () async {
            // Çıkış yapma onayı
            final shouldLogout = await showDialog<bool>(
              context: context,
              builder: (dialogContext) => AlertDialog(
                backgroundColor: const Color(0xFF1a2633),
                title: Text(
                  l10n.logout,
                  style: const TextStyle(color: Colors.white),
                ),
                content: Text(
                  l10n.logoutConfirmation,
                  style: const TextStyle(color: Colors.grey),
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(dialogContext, false),
                    child: Text(l10n.cancel),
                  ),
                  ElevatedButton(
                    onPressed: () => Navigator.pop(dialogContext, true),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                    ),
                    child: Text(l10n.logout),
                  ),
                ],
              ),
            );

            if (shouldLogout == true && context.mounted) {
              await ref.read(authServiceProvider).signOut();
              if (context.mounted) {
                context.go('/login');
              }
            }
          },
          style: OutlinedButton.styleFrom(
            foregroundColor: Colors.red,
            side: const BorderSide(color: Colors.red),
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
          icon: const Icon(Icons.logout),
          label: Text(l10n.logout),
        ),
      ],
    );
      },
      loading: () => const Center(
        child: CircularProgressIndicator(
          color: Color(0xFF1173d4),
        ),
      ),
      error: (_, __) => Center(
        child: Text(
          AppLocalizations(const Locale('tr')).error,
          style: const TextStyle(color: Colors.white),
        ),
      ),
    );
  }

  static Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Card(
      color: const Color(0xFF1a2633),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ...children,
          ],
        ),
      ),
    );
  }
}
