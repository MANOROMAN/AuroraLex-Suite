import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:go_router/go_router.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';

import '../data/baro_verification_service.dart';
import '../domain/models/user_model.dart';
import '../data/auth_service.dart';

class RegisterScreen extends HookConsumerWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final nameController = useTextEditingController();
    final emailController = useTextEditingController();
    final passwordController = useTextEditingController();
    final confirmPasswordController = useTextEditingController();
    final baroNumberController = useTextEditingController();
    final baroVerificationService = useMemoized(() => BaroVerificationService());
    final isLoading = useState(false);
    final obscurePassword = useState(true);
    final obscureConfirmPassword = useState(true);
    final selectedUserType = useState<UserType>(UserType.individual);
    final acceptedTerms = useState(false);

    Future<void> handleRegister() async {
      if (nameController.text.isEmpty ||
          emailController.text.isEmpty ||
          passwordController.text.isEmpty ||
          confirmPasswordController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen tüm alanları doldurun')),
        );
        return;
      }

      if (passwordController.text != confirmPasswordController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Şifreler eşleşmiyor')),
        );
        return;
      }

      if (!acceptedTerms.value) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen kullanım koşullarını kabul edin')),
        );
        return;
      }

      // Avukat ise baro sicil numarasını doğrula
      if (selectedUserType.value == UserType.lawyer) {
        if (baroNumberController.text.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen baro sicil numaranızı girin')),
          );
          return;
        }

        // Baro numarası format kontrolü
        if (!baroVerificationService.isValidBaroNumberFormat(baroNumberController.text)) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Geçersiz baro sicil numarası formatı (4-10 haneli sayı olmalı)')),
          );
          return;
        }

        // Baro numarası doğrulama
        final isValid = await baroVerificationService.verifyBaroNumber(baroNumberController.text.trim());
        if (!isValid) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Baro sicil numarası doğrulanamadı. Lütfen kontrol edin.')),
          );
          return;
        }
      }

      isLoading.value = true;
      try {
        await ref.read(authServiceProvider).signUpWithEmail(
              email: emailController.text.trim(),
              password: passwordController.text,
              displayName: nameController.text.trim(),
              userType: selectedUserType.value,
              // Baro numarasını VERİTABANINA KAYDETME - sadece doğrulama için kullan
              baroRegistrationNumber: null,
            );
        if (context.mounted) {
          context.go('/home');
        }
      } on FirebaseAuthException catch (e) {
        if (context.mounted) {
          String message = 'Kayıt başarısız';
          if (e.code == 'weak-password') {
            message = 'Şifre çok zayıf';
          } else if (e.code == 'email-already-in-use') {
            message = 'Bu e-posta zaten kullanılıyor';
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
                        'Hesabınızı Oluşturun',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Başlamak için kayıt olun',
                        style: TextStyle(
                          fontSize: 15,
                          color: Colors.grey.shade400,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 40),
                // User Type Selection
                Text(
                  'Hesap Tipi',
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _UserTypeButton(
                        label: 'Bireysel',
                        icon: Icons.person_outline,
                        isSelected: selectedUserType.value == UserType.individual,
                        onTap: () => selectedUserType.value = UserType.individual,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _UserTypeButton(
                        label: 'Avukat',
                        icon: Icons.gavel,
                        isSelected: selectedUserType.value == UserType.lawyer,
                        onTap: () => selectedUserType.value = UserType.lawyer,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Name Field
                _buildInputLabel('Ad Soyad'),
                const SizedBox(height: 8),
                TextField(
                  controller: nameController,
                  style: const TextStyle(color: Colors.white, fontSize: 15),
                  decoration: InputDecoration(
                    hintText: 'Adınız ve soyadınız',
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
                const SizedBox(height: 16),
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
                const SizedBox(height: 16),
                // Baro Registration Number (only for lawyers)
                if (selectedUserType.value == UserType.lawyer) ...[
                  _buildInputLabel('Baro Sicil Numarası'),
                  const SizedBox(height: 8),
                  TextField(
                    controller: baroNumberController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white, fontSize: 15),
                    decoration: InputDecoration(
                      hintText: 'Baro sicil numaranız',
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
                  const SizedBox(height: 16),
                ],
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
                const SizedBox(height: 16),
                // Confirm Password Field
                _buildInputLabel('Şifre Tekrar'),
                const SizedBox(height: 8),
                TextField(
                  controller: confirmPasswordController,
                  obscureText: obscureConfirmPassword.value,
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
                        obscureConfirmPassword.value
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade500,
                        size: 20,
                      ),
                      onPressed: () {
                        obscureConfirmPassword.value = !obscureConfirmPassword.value;
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Terms Checkbox
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: acceptedTerms.value,
                        onChanged: (value) => acceptedTerms.value = value ?? false,
                        fillColor: MaterialStateProperty.resolveWith((states) {
                          if (states.contains(MaterialState.selected)) {
                            return const Color(0xFF1173d4);
                          }
                          return Colors.grey.shade800;
                        }),
                        checkColor: Colors.white,
                        side: BorderSide(color: Colors.grey.shade800),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: GestureDetector(
                        onTap: () => acceptedTerms.value = !acceptedTerms.value,
                        child: Text.rich(
                          TextSpan(
                            text: 'Kullanım Koşulları',
                            style: const TextStyle(
                              color: Color(0xFF1173d4),
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                            children: [
                              TextSpan(
                                text: ' ve ',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                              const TextSpan(
                                text: 'Gizlilik Politikası',
                                style: TextStyle(
                                  color: Color(0xFF1173d4),
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              TextSpan(
                                text: '\'nı kabul ediyorum',
                                style: TextStyle(
                                  color: Colors.grey.shade500,
                                  fontWeight: FontWeight.w400,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                // Register Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: isLoading.value ? null : handleRegister,
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
                const SizedBox(height: 32),
                // Login Link
                Center(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Zaten hesabınız var mı? ',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 14,
                        ),
                      ),
                      TextButton(
                        onPressed: () => context.push('/login'),
                        style: TextButton.styleFrom(
                          padding: EdgeInsets.zero,
                          minimumSize: Size.zero,
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                        ),
                        child: const Text(
                          'Giriş Yap',
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

class _UserTypeButton extends StatelessWidget {
  const _UserTypeButton({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFF1173d4).withOpacity(0.15)
              : const Color(0xFF1a2633),
          border: Border.all(
            color: isSelected
                ? const Color(0xFF1173d4)
                : Colors.transparent,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF1173d4) : Colors.grey.shade500,
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? const Color(0xFF1173d4) : Colors.grey.shade400,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
