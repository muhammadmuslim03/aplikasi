import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../controller/profile_controller.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ProfileController controller = Get.find<ProfileController>();

  late TextEditingController nameController;
  late TextEditingController emailController;
  late TextEditingController phoneController;
  late TextEditingController nikController;

  File? _profileImage;

  @override
  void initState() {
    super.initState();
    // Inisialisasi dari controller (data sudah di-load dari storage)
    nameController = TextEditingController(text: controller.name.value);
    emailController = TextEditingController(text: controller.email.value);
    phoneController = TextEditingController(text: controller.phone.value);
    nikController =
        TextEditingController(text: controller.identityNumber.value);
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    nikController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final XFile? pickedImage = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 80,
    );
    if (pickedImage != null) {
      setState(() => _profileImage = File(pickedImage.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7F6),
      appBar: AppBar(
        centerTitle: true,
        title: const Text('Profil Saya'),
        titleTextStyle: const TextStyle(color: Colors.white, fontSize: 18),
        backgroundColor: const Color(0xFF1D4F44),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // ── Avatar ──
            Stack(
              alignment: Alignment.bottomRight,
              children: [
                CircleAvatar(
                  radius: 60,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _profileImage != null
                      ? FileImage(_profileImage!) as ImageProvider
                      : const AssetImage('assets/default_profile.png'),
                ),
                Positioned(
                  bottom: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: _pickImage,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: const BoxDecoration(
                        color: Color(0xFF1D4F44),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(Icons.camera_alt,
                          color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),

            // Nama dan role
            Obx(() => Text(
                  controller.name.value.isNotEmpty
                      ? controller.name.value
                      : 'Pendaki',
                  style: const TextStyle(
                      fontSize: 18, fontWeight: FontWeight.bold),
                )),
            Obx(() => Container(
                  margin: const EdgeInsets.only(top: 4),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFF1D4F44).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    controller.role.value == 'admin' ? 'Admin' : 'Pendaki',
                    style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF1D4F44),
                        fontWeight: FontWeight.w600),
                  ),
                )),
            const SizedBox(height: 24),

            // ── Form Edit Profil ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _sectionLabel('Informasi Pribadi'),
                  const SizedBox(height: 16),

                  // Nama Lengkap (editable)
                  _buildTextField(
                    label: 'Nama Lengkap',
                    controller: nameController,
                    icon: Icons.person_outline,
                  ),
                  const SizedBox(height: 14),

                  // No. HP (editable)
                  _buildTextField(
                    label: 'Nomor HP',
                    controller: phoneController,
                    icon: Icons.phone_outlined,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(13),
                    ],
                  ),
                  const SizedBox(height: 14),

                  // Email (read-only)
                  _buildTextField(
                    label: 'Email',
                    controller: emailController,
                    icon: Icons.email_outlined,
                    readOnly: true,
                    helperText: 'Email tidak dapat diubah',
                  ),
                  const SizedBox(height: 14),

                  // NIK (read-only — data identitas tidak boleh diubah sembarangan)
                  _buildTextField(
                    label: 'NIK / Nomor Paspor',
                    controller: nikController,
                    icon: Icons.badge_outlined,
                    readOnly: true,
                    helperText: 'Hubungi admin untuk mengubah data identitas',
                  ),
                  const SizedBox(height: 24),

                  // Tombol Simpan
                  Obx(() => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: controller.isUpdating.value
                              ? null
                              : () => controller.updateProfile(
                                    newName: nameController.text.trim(),
                                    newPhone: phoneController.text.trim(),
                                  ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF1D4F44),
                            disabledBackgroundColor:
                                const Color(0xFF1D4F44).withOpacity(0.6),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: controller.isUpdating.value
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2, color: Colors.white),
                                )
                              : const Icon(Icons.save, color: Colors.white),
                          label: Text(
                            controller.isUpdating.value
                                ? 'Menyimpan...'
                                : 'Simpan Perubahan',
                            style: const TextStyle(
                                color: Colors.white, fontSize: 15),
                          ),
                        ),
                      )),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Tombol Logout ──
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.15),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: OutlinedButton.icon(
                onPressed: () => _showLogoutDialog(context),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  'Keluar',
                  style: TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    Get.dialog(
      AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: const Text('Apakah kamu yakin ingin keluar dari akun ini?'),
        actions: [
          TextButton(
            onPressed: () => Get.back(),
            child: const Text('Batal',
                style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () {
              Get.back();
              controller.logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Keluar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

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
        Text(label,
            style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: Color(0xFF1D4F44))),
      ],
    );
  }

  Widget _buildTextField({
    required String label,
    required TextEditingController controller,
    IconData? icon,
    bool readOnly = false,
    String? helperText,
    TextInputType keyboardType = TextInputType.text,
    List<TextInputFormatter>? inputFormatters,
  }) {
    return TextField(
      controller: controller,
      readOnly: readOnly,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      style: TextStyle(color: readOnly ? Colors.grey[600] : Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        helperText: helperText,
        helperStyle: const TextStyle(fontSize: 11),
        prefixIcon: Icon(icon,
            color: readOnly ? Colors.grey : const Color(0xFF1D4F44)),
        filled: readOnly,
        fillColor: Colors.grey[100],
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        focusedBorder: OutlineInputBorder(
          borderSide:
              const BorderSide(color: Color(0xFF1D4F44), width: 1.5),
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}