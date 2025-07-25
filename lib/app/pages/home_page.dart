import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../controllers/home_controller.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ipController = TextEditingController();
    final portController = TextEditingController();
    final codeController = TextEditingController();
    final connectIpController = TextEditingController();

    return Scaffold(
      appBar: AppBar(title: const Text('ADB QR Connect')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: ipController,
                    decoration: const InputDecoration(labelText: 'IP'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: portController,
                    decoration: const InputDecoration(labelText: 'Port'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: codeController,
                    decoration: const InputDecoration(labelText: 'Pairing Code'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.pairDevice(
                      ipController.text,
                      portController.text,
                      codeController.text,
                    );
                  },
                  child: const Text('Pair'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: connectIpController,
                    decoration: const InputDecoration(labelText: 'Connect IP'),
                  ),
                ),
                const SizedBox(width: 8),
                ElevatedButton(
                  onPressed: () {
                    controller.connectDevice(connectIpController.text);
                  },
                  child: const Text('Connect'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: controller.listDevices,
              child: const Text('List Devices'),
            ),
            const SizedBox(height: 16),
            const Text('Scan QR to Pair:'),
            SizedBox(
              height: 200,
              child: MobileScanner(
                onDetect: (barcode, args) {
                  if (barcode.rawValue != null) {
                    controller.handleQrScan(barcode.rawValue!);
                  }
                },
              ),
            ),
            const SizedBox(height: 16),
            const Text('ADB Output:'),
            Obx(() => Text(controller.adbOutput.value)),
            const SizedBox(height: 16),
            const Text('Connected Devices:'),
            Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: controller.devices.map((d) => Text(d)).toList(),
            )),
          ],
        ),
      ),
    );
  }
} 