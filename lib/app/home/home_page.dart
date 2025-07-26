


import 'package:adbqr/app/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});


  @override
  Widget build(BuildContext context) {

    return  Scaffold(
      appBar: AppBar(title: Text('ADB QR Generator', style:Get.theme.textTheme.titleLarge)),
      body: Center(
        child: Obx(() {
          if (controller.isLoading.value) {
            return const CircularProgressIndicator();
          } else if (controller.adbCommand.value.isEmpty) {
            return Text('No IP found', style:Get.theme.textTheme.bodyLarge);
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (controller.devices.isNotEmpty) ...[
                  Text('Connected Devices:', style: Get.theme.textTheme.titleMedium),
                  ...controller.devices.map((d) => Text(d, style: Get.theme.textTheme.bodyMedium)),
                  const SizedBox(height: 20),
                ],
                QrImageView(
                  data: controller.adbCommand.value,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor:Get.theme.colorScheme.background,
                  eyeStyle: const QrEyeStyle(
                    eyeShape: QrEyeShape.square,
                    color: Colors.white,
                  ),
                  dataModuleStyle: const QrDataModuleStyle(
                    dataModuleShape: QrDataModuleShape.square,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 20),
                SelectableText(
                  controller.adbCommand.value,
                  style:Get.theme.textTheme.bodyLarge?.copyWith(fontSize: 18),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: controller.adbCommand.value));
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Copied to clipboard!', style:Get.theme.textTheme.bodyLarge)),
                    );
                  },
                  child: Text('Copy Command', style:Get.theme.textTheme.bodyLarge),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}