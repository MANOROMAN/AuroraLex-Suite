import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/auth_service.dart';

class LoginScreen extends HookConsumerWidget {
  const LoginScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final isLoading = useState(false);
    final obscurePassword = useState(true);

    Future<void> handleLogin() async {
      if (emailController.text.isEmpty || passwordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
        );
        return;
      }

      isLoading.value = true;
      try {
        await ref.read(authServiceProvider).signInWithEmail(
              emailController.text.trim(),
              passwordController.text,
            );
        if (context.mounted) {
          context.go('/home');
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          String message = 'Giriş başarısız';
          if (e.code == 'user-not-found') {
            message = 'Kullanıcı bulunamadı';
          } else if (e.code == 'wrong-password') {
            message = 'Hatalı şifre';
          } else if (e.code == 'invalid-email') {
            message = 'Geçersiz e-posta';
          }
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(message)),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    Future<void> handleGoogleSignIn() async {
      isLoading.value = true;
      try {
        await ref.read(authServiceProvider).signInWithGoogle();
        if (context.mounted) {
          context.go('/home');
        }
      } catch (e) {
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Google ile giriş yapılamadı. Lütfen tekrar deneyin.\n\nDetay: $e'),
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } finally {
        isLoading.value = false;
      }
    }

    return Scaffold(
      backgroundColor: const Color(0xFF101922),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 40),
                // Back Button
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
                const SizedBox(height: 40),
                // Header
                Center(
                  child: Column(
                    children: [
                      const Text(
                        'Tekrar Hoş Geldiniz',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Hesabınıza giriş yapın',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                // Email Field
                _buildInputLabel('E-posta'),
                const SizedBox(height: 8),
                TextField(
                  controller: emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'ornek@email.com',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF1a2633),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                // Password Field
                _buildInputLabel('Şifre'),
                const SizedBox(height: 8),
                TextField(
                  controller: passwordController,
                  obscureText: obscurePassword.value,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: '••••••••',
                    hintStyle: TextStyle(color: Colors.grey.shade600),
                    filled: true,
                    fillColor: const Color(0xFF1a2633),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(8),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 14,
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        obscurePassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () {
                        obscurePassword.value = !obscurePassword.value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Forgot Password
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () {
                      // TODO: Implement forgot password
                    },
                    child: const Text(
                      'Şifrenizi mi unuttunuz?',
                      style: TextStyle(
                        color: Color(0xFF1173d4),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Login Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1173d4),
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      disabledBackgroundColor:
                          const Color(0xFF1173d4).withOpacity(0.5),
                    ),
                    child: isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text(
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
                const SizedBox(height: 24),
                // Divider
                Row(
                  children: [
                    Expanded(child: Divider(color: Colors.grey.shade800)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'veya',
                        style: TextStyle(
                          color: Colors.grey.shade600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.grey.shade800)),
                  ],
                ),
                const SizedBox(height: 24),
                // Google Sign In
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: isLoading.value ? null : handleGoogleSignIn,
                    icon: const Icon(
                      Icons.g_mobiledata,
                      size: 24,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Google ile devam et',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white,
                      side: BorderSide(color: Colors.grey.shade800),
                      backgroundColor: Colors.transparent,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                // Sign Up Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Hesabınız yok mu? ',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Kayıt Ol',
                          style: TextStyle(
                            color: Color(0xFF1173d4),
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputLabel(String text) {
    return Text(
      text,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
    );
  }
}
