import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

class ProfileController extends GetxController {
  var name = ''.obs;
  var email = ''.obs;

  final box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    loadProfile();
  }

  void loadProfile() {
    name.value = box.read('name') ?? 'Tidak ada nama';
    email.value = box.read('email') ?? 'Tidak ada email';
  }

  void updateName(String newName) {
    name.value = newName;
    box.write('name', newName);
  }

  void logout() {
    box.erase();
  }
}
