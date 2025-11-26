import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/router/app_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../widgets/glass_card.dart';

class AuroraOnboardingScreen extends HookConsumerWidget {
  const AuroraOnboardingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = usePageController(viewportFraction: 0.85);
    final page = useState(0.0);

    useEffect(() {
      void listener() => page.value = controller.page ?? 0;
      controller.addListener(listener);
      return () => controller.removeListener(listener);
    }, [controller]);

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF05031B), Color(0xFF0C0830), Color(0xFF1A0F45)],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AuroraLex Suite',
                  style: TextStyle(
                    color: Colors.white70,
                    letterSpacing: 2,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Avukatlik pratiklerini\nisik hizina tasiyoruz.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 28),
                Expanded(
                  child: PageView.builder(
                    controller: controller,
                    itemCount: _cards.length,
                    itemBuilder: (context, index) {
                      final data = _cards[index];
                      final scale =
                          (1 - (page.value - index).abs().clamp(0.0, 1.0)) *
                          0.08;

                      return Transform.scale(
                        scale: 0.92 + scale,
                        child: GlassCard(
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 8,
                                  horizontal: 12,
                                ),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(30),
                                  color: Colors.white.withOpacity(0.08),
                                ),
                                child: Text(
                                  data.category.toUpperCase(),
                                  style: const TextStyle(
                                    color: Colors.white70,
                                    fontSize: 12,
                                    letterSpacing: 2,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Text(
                                data.title,
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 16),
                              Text(
                                data.description,
                                style: const TextStyle(
                                  color: Colors.white70,
                                  fontSize: 16,
                                ),
                              ),
                              const Spacer(),
                              Wrap(
                                spacing: 10,
                                runSpacing: 10,
                                children: data.tags
                                    .map(
                                      (tag) => Chip(
                                        label: Text(tag),
                                        backgroundColor: Colors.white
                                            .withOpacity(0.08),
                                        labelStyle: const TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                    )
                                    .toList(),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                Row(
                  children: List.generate(_cards.length, (index) {
                    final active = (page.value.round() == index);
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 250),
                      margin: const EdgeInsets.only(right: 8),
                      height: 6,
                      width: active ? 32 : 12,
                      decoration: BoxDecoration(
                        color: active ? AuroraColors.aurora : Colors.white24,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 20),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => context.go(AuroraRoutes.auth),
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 18),
                          backgroundColor: AuroraColors.aurora,
                          foregroundColor: Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                        ),
                        child: const Text(
                          'Deneyime Basla',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    IconButton.filled(
                      onPressed: () => context.go(AuroraRoutes.home),
                      style: IconButton.styleFrom(
                        padding: const EdgeInsets.all(18),
                        backgroundColor: Colors.white12,
                      ),
                      icon: const Icon(Icons.play_arrow_rounded, size: 30),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _OnboardingCardData {
  const _OnboardingCardData({
    required this.category,
    required this.title,
    required this.description,
    required this.tags,
  });

  final String category;
  final String title;
  final String description;
  final List<String> tags;
}

const _cards = [
  _OnboardingCardData(
    category: 'Case Intelligence',
    title: 'Dava analitigi ve\nisik hizinda icgoru',
    description:
        'AuroraLens motoru; dosyalar, kararlar ve takvim verilerini tek bakista anlamlandirir.',
    tags: ['Smart Timeline', 'Evidence Cloud', 'Risk Pulse'],
  ),
  _OnboardingCardData(
    category: 'Secure Identity',
    title: 'Sifir guven protokolleri\nve 2FA mimarisi',
    description:
        'Google Authenticator + biyometrik dogrulama icin hazir kimlik katmani.',
    tags: ['TOTP', 'Biometrics', 'Device Trust'],
  ),
  _OnboardingCardData(
    category: 'Knowledge Orbit',
    title: 'Hukuki sozluk +\ndinamik arama galaksisi',
    description:
        'Stitch referansli neon kartlar ile doktrin, mevzuat ve kisisel notlar ayni yerde.',
    tags: ['Deep Search', 'Bookmarks', 'Collab Share'],
  ),
];
