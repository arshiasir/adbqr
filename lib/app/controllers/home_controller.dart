import 'package:get/get.dart';
import '../services/adb_service.dart';

class HomeController extends GetxController {
  final AdbService _adbService = AdbService();

  var adbOutput = ''.obs;
  var devices = <String>[].obs;

  Future<void> listDevices() async {
    final output = await _adbService.listDevices();
    adbOutput.value = output;
    devices.value = _parseDevices(output);
  }

  Future<void> pairDevice(String ip, String port, String code) async {
    final output = await _adbService.pairDevice(ip, port, code);
    adbOutput.value = output;
    await listDevices();
  }

  Future<void> connectDevice(String ip) async {
    final output = await _adbService.connectDevice(ip);
    adbOutput.value = output;
    await listDevices();
  }

  void handleQrScan(String qr) {
    // Example QR: adb://192.168.1.100:12345?pairingCode=123456
    final uri = Uri.tryParse(qr);
    if (uri != null && uri.scheme == 'adb') {
      final ip = uri.host;
      final port = uri.port.toString();
      final code = uri.queryParameters['pairingCode'] ?? '';
      if (ip.isNotEmpty && port.isNotEmpty && code.isNotEmpty) {
        pairDevice(ip, port, code);
      }
    }
  }

  void handleQrScanWithFeedback(String qr, dynamic context) {
    final uri = Uri.tryParse(qr);
    if (uri != null && uri.scheme == 'adb') {
      final ip = uri.host;
      final port = uri.port.toString();
      final code = uri.queryParameters['pairingCode'] ?? '';
      if (ip.isNotEmpty && port.isNotEmpty && code.isNotEmpty) {
        pairDevice(ip, port, code);
        Get.snackbar('ADB Pairing', 'Attempting to pair with $ip:$port using code $code');
      } else {
        Get.snackbar('QR Error', 'QR code missing IP, port, or pairing code.');
      }
    } else {
      Get.snackbar('QR Error', 'Invalid QR code format.');
    }
  }

  List<String> _parseDevices(String output) {
    final lines = output.split('\n');
    return lines.where((line) => line.contains('\tdevice')).toList();
  }
} 