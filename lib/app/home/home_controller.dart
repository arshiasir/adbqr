


import 'dart:io';

import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString ipAddress = ''.obs;
  final RxString adbCommand = ''.obs;
  final int adbPort = 5555;
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    getLocalIp();
  }

  Future<void> getLocalIp() async {
    try {
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      );

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (!addr.isLoopback) {
            ipAddress.value = addr.address;
            adbCommand.value = 'adb connect ${addr.address}:$adbPort';
            isLoading.value = false;
            return;
          }
        }
      }

      adbCommand.value = '';
      isLoading.value = false;
    } catch (e) {
      adbCommand.value = 'Error: $e';
      isLoading.value = false;
    }
  }

}