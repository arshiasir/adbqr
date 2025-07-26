import 'dart:io';
import 'dart:async';

import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString ipAddress = ''.obs;
  final RxString adbCommand = ''.obs;
  final int adbPort = 5555;
  final RxBool isLoading = true.obs;
  RxList<String> devices = <String>[].obs;
  final RxString adbLog = ''.obs;
  Process? _logcatProcess;
  Timer? _deviceRefreshTimer;

  @override
  void onInit() {
    super.onInit();
    getLocalIp();
    fetchAdbDevices();
    _deviceRefreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchAdbDevices();
    });
  }

  @override
  void onClose() {
    _deviceRefreshTimer?.cancel();
    super.onClose();
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
          if (line.trim().isEmpty || line.startsWith('List of devices'))
            continue;
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

  Future<void> startAdbLogcat() async {
    try {
      _logcatProcess = await Process.start('adb', ['logcat']);
      adbLog.value = '';
      _logcatProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
        adbLog.value += data;
      });
      _logcatProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
        adbLog.value += '\n[stderr] $data';
      });
    } catch (e) {
      adbLog.value = 'Error starting logcat: $e';
    }
  }

  Future<void> stopAdbLogcat() async {
    try {
      await _logcatProcess?.kill();
      _logcatProcess = null;
    } catch (e) {
      adbLog.value += '\nError stopping logcat: $e';
    }
  }

  Future<void> disconnectDevice(String device) async {
    try {
      final result = await Process.run('adb', ['disconnect', device]);
      if (result.exitCode == 0) {
        fetchAdbDevices();
      } else {
        // Optionally handle error
      }
    } catch (e) {
      // Optionally handle error
    }
  }
}
