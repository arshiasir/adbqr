import 'package:get/get.dart';
import '../home/home_page.dart';
import '../home/home_binding.dart';

class AppPages {
  static const initial = '/';

  static final routes = [
    GetPage(
      name: '/',
      page: () => const HomePage(),
      binding: HomeBinding(),
    ),
  ];
} 