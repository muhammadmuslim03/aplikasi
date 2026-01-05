import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:provider/provider.dart';

import 'controller/booking_controller.dart';
import 'controller/history_controller.dart';
import 'controller/navigation_controller.dart';

import 'view/login_screen.dart';
import 'view/register_screen.dart';
import 'view/forgot_screen.dart';
import 'view/bottomnavigation.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => NavigationController()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'GoTrip',
      debugShowCheckedModeBanner: false,

      initialBinding: BindingsBuilder(() {
        Get.put(BookingController(), permanent: true);
        Get.put(BookingHistoryController(), permanent: true);
      }),

      theme: ThemeData(
        primarySwatch: Colors.blueGrey,
        scaffoldBackgroundColor: Colors.grey[50],
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.blueGrey,
          foregroundColor: Colors.white,
        ),
      ),

      initialRoute: '/login',

      getPages: [
        GetPage(name: '/login', page: () => const LoginScreen()),
        GetPage(name: '/register', page: () => const RegisterScreen()),
        GetPage(name: '/forgot', page: () => const ForgotPasswordScreen()),
        GetPage(name: '/home', page: () => const Bottomnavigation()),
      ],
    );
  }
}
