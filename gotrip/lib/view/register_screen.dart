import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controller/register_controller.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final controller = Get.put(RegisterController());
  final formKey = GlobalKey<FormState>();

  bool obscurePassword = true;
  bool obscureConfirm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset("assets/background.jpg", fit: BoxFit.cover),
          ),
          Align(
            alignment: Alignment.center,
            child: SingleChildScrollView(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                margin: const EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black26,
                      blurRadius: 8,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: Form(
                  key: formKey,
                  child: Column(
                    children: [
                      const Text(
                        "Daftar Akun",
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF1D4F44),
                        ),
                      ),
                      const SizedBox(height: 20),

                      // ✅ Field Username
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Username",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.person),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Tidak boleh kosong" : null,
                        onChanged: (val) => controller.username.value = val,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Field Email
                      TextFormField(
                        decoration: const InputDecoration(
                          labelText: "Email",
                          border: OutlineInputBorder(),
                          prefixIcon: Icon(Icons.email),
                        ),
                        validator: (value) =>
                            value!.isEmpty ? "Tidak boleh kosong" : null,
                        onChanged: (val) => controller.email.value = val,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Field Password
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscurePassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              obscurePassword = !obscurePassword;
                            }),
                          ),
                        ),
                        obscureText: obscurePassword,
                        validator: (value) =>
                            value!.isEmpty ? "Tidak boleh kosong" : null,
                        onChanged: (val) => controller.password.value = val,
                      ),
                      const SizedBox(height: 16),

                      // ✅ Field Konfirmasi Password
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: "Konfirmasi Password",
                          border: const OutlineInputBorder(),
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              obscureConfirm
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                            onPressed: () => setState(() {
                              obscureConfirm = !obscureConfirm;
                            }),
                          ),
                        ),
                        obscureText: obscureConfirm,
                        validator: (value) =>
                            value!.isEmpty ? "Tidak boleh kosong" : null,
                        onChanged: (val) =>
                            controller.confirmPassword.value = val,
                      ),
                      const SizedBox(height: 20),

                      // ✅ Tombol Daftar
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
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: controller.isLoading.value
                                ? const CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  )
                                : const Text("Daftar"),
                          ),
                        ),
                      ),

                      // ✅ Navigasi ke Login
                      TextButton(
                        onPressed: () => Get.offAllNamed('/login'),
                        child: const Text(
                          "Sudah punya akun? Login",
                          style: TextStyle(color: Color(0xFF1D4F44)),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
