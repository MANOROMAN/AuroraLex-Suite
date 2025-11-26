import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0A0A0A),
      body: Stack(
        children: [
          // Background Image with Dark Overlay
          Positioned.fill(
            child: CachedNetworkImage(
              imageUrl: 'https://images.unsplash.com/photo-1436450412740-6b988f486c6b?w=2000&q=95',
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFF0A0A0A),
                child: Center(
                  child: CircularProgressIndicator(
                    color: const Color(0xFF1173d4).withOpacity(0.3),
                    strokeWidth: 2,
                  ),
                ),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFF0A0A0A),
              ),
              memCacheWidth: 2000,
              maxWidthDiskCache: 2000,
              color: Colors.black.withOpacity(0.45),
              colorBlendMode: BlendMode.darken,
              fadeInDuration: const Duration(milliseconds: 300),
              fadeOutDuration: const Duration(milliseconds: 100),
            ),
          ),
          // Dark Gradient Overlay
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.7),
                    Colors.black.withOpacity(0.85),
                    Colors.black.withOpacity(0.95),
                  ],
                ),
              ),
            ),
          ),
          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
              child: Column(
                children: [
                  const Spacer(flex: 2),
                  // Logo & Title
                  _buildHeader().animate().fadeIn(duration: 600.ms),
                  const Spacer(flex: 3),
                  // Buttons
                  _buildButtons(context)
                      .animate()
                      .fadeIn(delay: 200.ms, duration: 600.ms),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Image.asset(
          'assets/images/icon.png',
          width: 100,
          height: 100,
        ),
        const SizedBox(height: 16),
        const Text(
          'AuroraLex',
          style: TextStyle(
            fontSize: 40,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            letterSpacing: -0.5,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Yapay Zeka Destekli Hukuk Uygulaması',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey.shade400,
            fontWeight: FontWeight.w400,
          ),
        ),
      ],
    );
  }

  Widget _buildButtons(BuildContext context) {
    return Column(
      children: [
        // Login Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: ElevatedButton(
            onPressed: () => context.push('/login'),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1173d4),
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'GİRİŞ YAP',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Sign Up Button
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () => context.push('/register'),
            style: OutlinedButton.styleFrom(
              foregroundColor: Colors.white,
              side: BorderSide(color: Colors.white.withOpacity(0.3), width: 1),
              backgroundColor: Colors.transparent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'KAYIT OL',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
                height: 1.2,
              ),
            ),
          ),
        ),
      ],
    );
  }
}
