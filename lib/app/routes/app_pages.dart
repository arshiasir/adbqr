import 'package:get/get.dart';
import '../pages/home_page.dart';
import '../bindings/home_binding.dart';

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