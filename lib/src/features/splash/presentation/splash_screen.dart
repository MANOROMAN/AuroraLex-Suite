import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../../../core/config/firebase_init_provider.dart';
import '../../../core/router/app_router.dart';

class AuroraSplashScreen extends HookConsumerWidget {
  const AuroraSplashScreen({super.key, this.autoNavigate = true});

  final bool autoNavigate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaleController = useAnimationController(
      duration: const Duration(milliseconds: 1200),
    )..forward();
    final fadeController = useAnimationController(
      duration: const Duration(milliseconds: 1000),
    )..forward();

    final firebaseInitialization = ref.watch(
      firebaseInitializationProvider.future,
    );

    useEffect(() {
      if (!autoNavigate) return null;

      var cancelled = false;
      Future<void>(() async {
        await firebaseInitialization;
        await Future.delayed(const Duration(milliseconds: 2500));
        if (!cancelled && context.mounted) {
          context.go(AuroraRoutes.welcome);
        }
      });
      return () => cancelled = true;
    }, [firebaseInitialization, autoNavigate]);

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(flex: 2),
            ScaleTransition(
              scale: CurvedAnimation(
                parent: scaleController,
                curve: Curves.elasticOut,
              ),
              child: Image.asset(
                'assets/images/icon.png',
                width: 120,
                height: 120,
              ),
            ),
            const SizedBox(height: 40),
            FadeTransition(
              opacity: fadeController,
              child: const Text(
                'AuroraLex',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 8),
            FadeTransition(
              opacity: fadeController,
              child: const Text(
                'Hukuk Asistanı',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.white70,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const Spacer(),
            FadeTransition(
              opacity: fadeController,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 40),
                child: Column(
                  children: const [
                    Text(
                      '"Adalet mülkün temelidir."',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontStyle: FontStyle.italic,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                        height: 1.5,
                        letterSpacing: 0.3,
                      ),
                    ),
                    SizedBox(height: 16),
                    _SignatureDivider(),
                  ],
                ),
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }
}

class _SignatureDivider extends StatelessWidget {
  const _SignatureDivider();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'M. Kemal Atatürk',
          style: TextStyle(
            fontSize: 16,
            color: Colors.white.withOpacity(0.8),
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            letterSpacing: 1.2,
          ),
        ),
      ],
    );
  }
}