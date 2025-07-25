import 'dart:io';

class AdbService {
  Future<String> listDevices() async {
    final result = await Process.run('adb', ['devices']);
    return result.stdout.toString();
  }

  Future<String> pairDevice(String ip, String port, String code) async {
    final result = await Process.run('adb', ['pair', '$ip:$port', code]);
    return result.stdout.toString();
  }

  Future<String> connectDevice(String ip) async {
    final result = await Process.run('adb', ['connect', ip]);
    return result.stdout.toString();
  }
} 