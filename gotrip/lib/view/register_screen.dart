import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '../controller/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final RegisterController controller = Get.put(RegisterController());
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // TextEditingController untuk setiap field
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController nikController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nikController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background
          Positioned.fill(
            child: Image.asset('assets/background.jpg', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.25)),
          ),

          // Konten
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Column(
                children: [
                  // Tombol back
                  Align(
                    alignment: Alignment.centerLeft,
                    child: IconButton(
                      onPressed: () => Get.back(),
                      icon: const Icon(Icons.arrow_back_ios,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const SizedBox(height: 8),

                  // Card form
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.95),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: const [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 12,
                          offset: Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Form(
                      key: formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header
                          const Text(
                            'Buat Akun',
                            style: TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF1D4F44),
                            ),
                          ),
                          const Text(
                            'Isi data diri kamu untuk mendaftar',
                            style: TextStyle(fontSize: 13, color: Colors.grey),
                          ),
                          const SizedBox(height: 24),

                          // ── SECTION: Data Diri ──
                          _sectionLabel('Data Diri'),
                          const SizedBox(height: 12),

                          // Nama Lengkap
                          _buildTextField(
                            controller: nameController,
                            label: 'Nama Lengkap',
                            icon: Icons.person_outline,
                            onChanged: (val) => controller.name.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nama tidak boleh kosong';
                              }
                              if (value.length < 3) {
                                return 'Nama minimal 3 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          _buildTextField(
                            controller: nikController,
                            label: 'NIK / Nomor Paspor',
                            icon: Icons.badge_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(16),
                            ],
                            onChanged: (val) =>
                                controller.NIK.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'NIK/Nomor paspor tidak boleh kosong';
                              }
                              if (value.length < 8) {
                                return 'Nomor identitas terlalu pendek';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // No. HP
                          _buildTextField(
                            controller: phoneController,
                            label: 'Nomor HP',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            onChanged: (val) => controller.phone.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Nomor HP tidak boleh kosong';
                              }
                              if (value.length < 9) {
                                return 'Nomor HP tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 24),

                          // ── SECTION: Akun ──
                          _sectionLabel('Akun'),
                          const SizedBox(height: 12),

                          // Email
                          _buildTextField(
                            controller: emailController,
                            label: 'Email',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            onChanged: (val) => controller.email.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Email tidak boleh kosong';
                              }
                              if (!GetUtils.isEmail(value)) {
                                return 'Format email tidak valid';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Password
                          TextFormField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(obscurePassword
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => obscurePassword = !obscurePassword),
                              ),
                            ),
                            onChanged: (val) => controller.password.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Password tidak boleh kosong';
                              }
                              if (value.length < 6) {
                                return 'Password minimal 6 karakter';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),

                          // Konfirmasi Password
                          TextFormField(
                            controller: confirmPasswordController,
                            obscureText: obscureConfirm,
                            decoration: InputDecoration(
                              labelText: 'Konfirmasi Password',
                              border: const OutlineInputBorder(),
                              prefixIcon: const Icon(Icons.lock_outline),
                              suffixIcon: IconButton(
                                icon: Icon(obscureConfirm
                                    ? Icons.visibility_off
                                    : Icons.visibility),
                                onPressed: () => setState(
                                    () => obscureConfirm = !obscureConfirm),
                              ),
                            ),
                            onChanged: (val) =>
                                controller.confirmPassword.value = val,
                            validator: (value) {
                              if (value == null || value.isEmpty) {
                                return 'Konfirmasi password tidak boleh kosong';
                              }
                              if (value != passwordController.text) {
                                return 'Password tidak cocok';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 28),

                          // Tombol Daftar
                          SizedBox(
                            width: double.infinity,
                            child: Obx(
                              () => ElevatedButton(
                                onPressed: controller.isLoading.value
                                    ? null
                                    : () {
                                        if (formKey.currentState!.validate()) {
                                          controller.register();
                                        }
                                      },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF1D4F44),
                                  foregroundColor: Colors.white,
                                  disabledBackgroundColor:
                                      const Color(0xFF1D4F44).withOpacity(0.6),
                                  padding:
                                      const EdgeInsets.symmetric(vertical: 16),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 5,
                                ),
                                child: controller.isLoading.value
                                    ? const SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: Colors.white,
                                        ),
                                      )
                                    : const Text(
                                        'Daftar Sekarang',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          // Link ke login
                          Center(
                            child: TextButton(
                              onPressed: () => Get.offAllNamed('/login'),
                              child: const Text(
                                'Sudah punya akun? Masuk',
                                style: TextStyle(color: Color(0xFF1D4F44)),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget helper: label section
  Widget _sectionLabel(String label) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: const Color(0xFF1D4F44),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1D4F44),
          ),
        ),
      ],
    );
  }

  // Widget helper: text field standar
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    required ValueChanged<String> onChanged,
    required FormFieldValidator<String> validator,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      decoration: InputDecoration(
        labelText: label,
        border: const OutlineInputBorder(),
        prefixIcon: Icon(icon),
      ),
      onChanged: onChanged,
      validator: validator,
    );
  }
}