


import 'dart:io';

import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString ipAddress = ''.obs;
  final RxString adbCommand = ''.obs;
  final int adbPort = 5555;
  final RxBool isLoading = true.obs;
  final RxList<String> devices = <String>[].obs;

  @override
  void onInit() {
    super.onInit();
    getLocalIp();
    fetchAdbDevices();
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

  Future<void> fetchAdbDevices() async {
    try {
      final result = await Process.run('adb', ['devices']);
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final deviceList = <String>[];
        for (var line in lines) {
          if (line.trim().isEmpty || line.startsWith('List of devices')) continue;
          final parts = line.split('\t');
          if (parts.length == 2 && parts[1] == 'device') {
            deviceList.add(parts[0]);
          }
        }
        devices.assignAll(deviceList);
      } else {
        devices.clear();
      }
    } catch (e) {
      devices.clear();
    }
  }
}