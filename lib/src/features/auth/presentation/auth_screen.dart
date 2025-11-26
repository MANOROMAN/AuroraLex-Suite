import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';
import '../../../widgets/metric_chip.dart';

class AuroraAuthScreen extends HookConsumerWidget {
  const AuroraAuthScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final otpController = useTextEditingController();
    final authMode = useState(_AuthMode.signIn);

    void onAuthenticatorTap() {
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.black.withOpacity(0.82),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        builder: (context) {
          return Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Text(
                  'Google Authenticator',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: 14),
                Text(
                  '1. Firebase Console > Authentication > MFA sekmesinden TOTP kanalini ac.\n'
                  '2. Olusan QR/secret key bilgisini kullaniciya goster.\n'
                  '3. Kullanici bu kodu Google Authenticator uygulamasina eklesin.\n'
                  '4. Firestore icinde `users/{uid}/mfa` dokumaninda secret bilgisini sifreli tut.\n'
                  '5. Giriste OTP alanini zorunlu hale getir.',
                  style: TextStyle(color: Colors.white70, height: 1.4),
                ),
              ],
            ),
          );
        },
      );
    }

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF040312), Color(0xFF0B0533), Color(0xFF1C0F42)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isWide = constraints.maxWidth > 900;

                final form = Expanded(
                  flex: 5,
                  child: GlassCard(
                    padding: const EdgeInsets.all(28),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            ChoiceChip(
                              label: const Text('Giris'),
                              selected: authMode.value == _AuthMode.signIn,
                              onSelected: (_) =>
                                  authMode.value = _AuthMode.signIn,
                            ),
                            const SizedBox(width: 12),
                            ChoiceChip(
                              label: const Text('Kayit'),
                              selected: authMode.value == _AuthMode.signUp,
                              onSelected: (_) =>
                                  authMode.value = _AuthMode.signUp,
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        _AuroraInput(
                          controller: emailController,
                          hintText: 'E-posta',
                          icon: Icons.mail_outline,
                        ),
                        const SizedBox(height: 16),
                        _AuroraInput(
                          controller: passwordController,
                          hintText: authMode.value == _AuthMode.signUp
                              ? 'Sifre (min 12 karakter)'
                              : 'Sifre',
                          icon: Icons.lock_outline,
                          obscure: true,
                        ),
                        const SizedBox(height: 16),
                        _AuroraInput(
                          controller: otpController,
                          hintText: 'Google Authenticator OTP',
                          icon: Icons.shield_outlined,
                          keyboardType: TextInputType.number,
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            TextButton.icon(
                              onPressed: onAuthenticatorTap,
                              icon: const Icon(
                                Icons.qr_code_scanner,
                                color: Colors.white,
                              ),
                              label: const Text(
                                'Authenticator ekle',
                                style: TextStyle(color: Colors.white),
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.face_6_rounded,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: () => context.go(AuroraRoutes.home),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 18),
                            backgroundColor: AuroraColors.iris,
                          ),
                          child: Text(
                            authMode.value == _AuthMode.signIn
                                ? 'Giris yap'
                                : 'AuroraLex\'e katil',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: () {},
                          icon: const Icon(Icons.g_mobiledata, size: 32),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            foregroundColor: Colors.white,
                            side: BorderSide(
                              color: Colors.white.withOpacity(0.2),
                            ),
                          ),
                          label: const Text(
                            'Google ile devam et',
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                final hero = Expanded(
                  flex: 4,
                  child: Column(
                    crossAxisAlignment: isWide
                        ? CrossAxisAlignment.start
                        : CrossAxisAlignment.center,
                    children: [
                      Text(
                        'Zero-trust kimlik.\nGlassmorphism UI.\nYarisma hazir deneyim.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w800,
                          height: 1.1,
                        ),
                      ),
                      const SizedBox(height: 18),
                      Text(
                        'Biyometrik imza, TOTP, cihaz baglama ve Firestore tabanli oturum politikalarini tek katta sunar.',
                        textAlign: isWide ? TextAlign.left : TextAlign.center,
                        style: const TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 28),
                      Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        alignment: isWide
                            ? WrapAlignment.start
                            : WrapAlignment.center,
                        children: const [
                          MetricChip(
                            label: 'Aktif muvekkil',
                            value: '128',
                            icon: Icons.groups_3_outlined,
                          ),
                          MetricChip(
                            label: 'TOTP korumali',
                            value: '%94',
                            icon: Icons.shield_outlined,
                            accentColor: AuroraColors.magenta,
                          ),
                          MetricChip(
                            label: 'Latency',
                            value: '180ms',
                            icon: Icons.speed,
                            accentColor: AuroraColors.iris,
                          ),
                        ],
                      ),
                      const Spacer(),
                      const Text(
                        'Yeni nesil Stitch vibe + kurumsal guvenlik.',
                        style: TextStyle(color: Colors.white54),
                      ),
                    ],
                  ),
                );

                return isWide
                    ? Row(children: [hero, const SizedBox(width: 20), form])
                    : SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [hero, const SizedBox(height: 28), form],
                        ),
                      );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _AuroraInput extends StatelessWidget {
  const _AuroraInput({
    required this.controller,
    required this.hintText,
    required this.icon,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hintText;
  final IconData icon;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscure,
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: Colors.white70),
        hintText: hintText,
        hintStyle: const TextStyle(color: Colors.white54),
      ),
      style: const TextStyle(color: Colors.white),
    );
  }
}

enum _AuthMode { signIn, signUp }
