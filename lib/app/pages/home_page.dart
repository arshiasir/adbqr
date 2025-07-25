import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:image/image.dart' as img;
import 'package:zxing2/qrcode.dart';
import '../controllers/home_controller.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({Key? key}) : super(key: key);

  Future<void> _pickAndDecodeQr(BuildContext context) async {
    final result = await FilePicker.platform.pickFiles(type: FileType.image);
    if (result != null && result.files.single.path != null) {
      final file = File(result.files.single.path!);
      final bytes = await file.readAsBytes();
      final image = img.decodeImage(bytes);
      if (image != null) {
        if (image.data == null) {
          Get.snackbar('QR Code', 'Image data is null.');
          return;
        }
        final luminanceSource = RGBLuminanceSource(
          image.width,
          image.height,
          image.data!.buffer.asInt32List(),
        );
        final bitmap = BinaryBitmap(HybridBinarizer(luminanceSource));
        final reader = QRCodeReader();
        try {
          final result = reader.decode(bitmap);
          if (result.text.isNotEmpty) {
            controller.handleQrScan(result.text);
            Get.snackbar('QR Code', 'QR code scanned: ${result.text}');
          } else {
            Get.snackbar('QR Code', 'No QR code found in image.');
          }
        } catch (e) {
          Get.snackbar('QR Code', 'Failed to decode QR code.');
        }
      } else {
        Get.snackbar('QR Code', 'Could not read image.');
      }
    }
  }

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
            const Text('Generate QR for ADB Pairing:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
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
              ],
            ),
            const SizedBox(height: 8),
            Obx(() {
              final ip = ipController.text;
              final port = portController.text;
              final code = codeController.text;
              final qrData = (ip.isNotEmpty && port.isNotEmpty && code.isNotEmpty)
                  ? 'adb://$ip:$port?pairingCode=$code'
                  : '';
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (qrData.isEmpty) {
                        Get.snackbar('Error', 'Please fill all fields to generate QR code.');
                      } else {
                        // Just trigger rebuild
                        (context as Element).markNeedsBuild();
                      }
                    },
                    child: const Text('Generate QR Code'),
                  ),
                  const SizedBox(height: 8),
                  if (qrData.isNotEmpty)
                    Center(
                      child: SizedBox(
                        width: 180,
                        height: 180,
                        child: Card(
                          elevation: 4,
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: QrImageView(
                              data: qrData,
                              version: QrVersions.auto,
                              size: 160.0,
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              );
            }),
            const SizedBox(height: 24),
            const Text('Scan QR to Pair:'),
            if (!Platform.isWindows)
              SizedBox(
                height: 200,
                child: MobileScanner(
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      if (barcode.rawValue != null) {
                        controller.handleQrScanWithFeedback(barcode.rawValue!, context);
                        break;
                      }
                    }
                  },
                ),
              )
            else
              ElevatedButton(
                onPressed: () => _pickAndDecodeQr(context),
                child: const Text('Upload QR Image'),
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