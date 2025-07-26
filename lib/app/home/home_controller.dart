import 'dart:io';
import 'dart:async';


import 'package:get/get.dart';

class HomeController extends GetxController {
  final RxString ipAddress = ''.obs;
  final RxString adbCommand = ''.obs;
  final int adbPort = 5555;
  final RxBool isLoading = true.obs;
  RxList<String> devices = <String>[].obs;
  // final RxString adbLog = ''.obs;
  // final RxString logcatSearchQuery = ''.obs;
  // RxList<String> get filteredLogcatLines {
  //   if (logcatSearchQuery.value.isEmpty) {
  //     return adbLog.value.split('\n').obs;
  //   }
  //   final query = logcatSearchQuery.value.toLowerCase();
  //   return adbLog.value
  //       .split('\n')
  //       .where((line) => line.toLowerCase().contains(query))
  //       .toList()
  //       .obs;
  // }
  // Process? _logcatProcess;
  Timer? _deviceRefreshTimer;
  // late final ScrollController logcatScrollController;

  @override 
  void onInit() {
    super.onInit();
    getLocalIp();
    fetchAdbDevices();
    _deviceRefreshTimer = Timer.periodic(Duration(seconds: 3), (timer) {
      fetchAdbDevices();
    });
    // logcatScrollController = ScrollController();
  }

  @override
  void onClose() {
    _deviceRefreshTimer?.cancel();
    // logcatScrollController.dispose();
    super.onClose();
  }

  Future<void> getLocalIp() async {
    try {
      // Add a timeout to avoid hanging
      final interfaces = await NetworkInterface.list(
        includeLinkLocal: false,
        type: InternetAddressType.IPv4,
      ).timeout(const Duration(seconds: 2), onTimeout: () => []);

      // Filter for interfaces that are up and not loopback/virtual
      for (var interface in interfaces) {
        if (interface.name.toLowerCase().contains('virtual') ||
            interface.name.toLowerCase().contains('vmware') ||
            interface.name.toLowerCase().contains('loopback')) {
          continue;
        }
        for (var addr in interface.addresses) {
          if (!addr.isLoopback && addr.type == InternetAddressType.IPv4) {
            ipAddress.value = addr.address;
            adbCommand.value = 'adb connect  [1m${addr.address}:$adbPort [0m';
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
      print('adb devices output: \nstdout: \n'+result.stdout.toString()+' \nstderr: \n'+result.stderr.toString());
      if (result.exitCode == 0) {
        final lines = (result.stdout as String).split('\n');
        final deviceList = <String>[];
        for (var line in lines) {
          line = line.trim();
          if (line.isEmpty || line.startsWith('List of devices')) continue;
          if (!line.contains('\t')) continue;
          final parts = line.split('\t');
          if (parts.length == 2) {
            deviceList.add('${parts[0]} (${parts[1]})');
          }
        }
        devices.assignAll(deviceList);
        print('Parsed devices: $deviceList');
      } else {
        print('adb devices failed with exit code: '+result.exitCode.toString());
        devices.clear();
      }
    } catch (e) {
      print('Error fetching adb devices: $e');
      devices.clear();
    }
  }

  Future<void> connectToDevice(String address) async {
    try {
      print('Connecting to device: adb connect $address');
      final result = await Process.run('adb', ['connect', address]);
      print('adb connect output: \nstdout: \n'+result.stdout.toString()+' \nstderr: \n'+result.stderr.toString());
      if (result.exitCode == 0) {
        fetchAdbDevices();
      } else {
        print('adb connect failed with exit code: \n'+result.exitCode.toString());
      }
    } catch (e) {
      print('Error connecting to device: $e');
    }
  }

  // Future<void> startAdbLogcat() async {
  //   try {
  //     _logcatProcess = await Process.start('adb', ['logcat']);
  //     adbLog.value = '';
  //     _logcatProcess!.stdout.transform(SystemEncoding().decoder).listen((data) {
  //       adbLog.value += data;
  //     });
  //     _logcatProcess!.stderr.transform(SystemEncoding().decoder).listen((data) {
  //       adbLog.value += '\n[stderr] $data';
  //     });
  //   } catch (e) {
  //     adbLog.value = 'Error starting logcat: $e';
  //   }
  // }

  // Future<void> stopAdbLogcat() async {
  //   try {
  //     await _logcatProcess?.kill();
  //     _logcatProcess = null;
  //   } catch (e) {
  //     adbLog.value += '\nError stopping logcat: $e';
  //   }
  // }

  Future<void> disconnectDevice(String device) async {
    try {
      // Extract IP address and port from device string (e.g., "192.168.1.100:5555 (device)" -> "192.168.1.100:5555")
      final deviceAddress = device.split(' ').first;
      print('Disconnecting device: adb disconnect $deviceAddress');
      final result = await Process.run('adb', ['disconnect', deviceAddress]);
      print('adb disconnect output: \nstdout: \n${result.stdout.toString()} \nstderr: \n${result.stderr.toString()}');
      if (result.exitCode == 0) {
        fetchAdbDevices();
      } else {
        print('adb disconnect failed with exit code: ${result.exitCode}');
      }
    } catch (e) {
      print('Error disconnecting device: $e');
    }
  }
}
