import 'package:adbqr/app/home/home_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:qr_flutter/qr_flutter.dart';

// Add constants for paddings and styles
const double kCardPadding = 24.0;
const double kHorizontalPaddingDesktop = 32.0;
const double kHorizontalPaddingMobile = 16.0;

// Devices Section Widget
class DevicesSection extends StatelessWidget {
  final List<String> devices;
  final void Function(String device) onDisconnect;
  const DevicesSection({required this.devices, required this.onDisconnect, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Devices', style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            ...List.generate(
              devices.length,
              (index) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        devices[index],
                        style: Get.theme.textTheme.bodyLarge,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: Colors.red),
                      tooltip: 'Disconnect',
                      onPressed: () => onDisconnect(devices[index]),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// QR/Command Section Widget
class QrCommandSection extends StatelessWidget {
  final HomeController controller;
  final bool isDesktop;
  const QrCommandSection({required this.controller, required this.isDesktop, super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          } else if (controller.adbCommand.value.isEmpty) {
            return Center(
              child: Text(
                'No IP found',
                style: Get.theme.textTheme.bodyLarge,
              ),
            );
          } else {
            return Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                QrImageView(
                  data: controller.adbCommand.value,
                  version: QrVersions.auto,
                  size: 250.0,
                  backgroundColor: Get.theme.colorScheme.background,
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
                  textAlign: TextAlign.center,
                  style: Get.theme.textTheme.bodyLarge?.copyWith(
                    fontSize: isDesktop ? 22 : 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: () {
                    Clipboard.setData(
                      ClipboardData(
                        text: controller.adbCommand.value,
                      ),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          'Copied to clipboard!',
                          style: Get.theme.textTheme.bodyLarge,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                  label: Text(
                    'Copy Command',
                    style: Get.theme.textTheme.bodyLarge,
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    textStyle: Get.theme.textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          }
        }),
      ),
    );
  }
}

// Logcat Section Widget
class LogcatSection extends StatefulWidget {
  final HomeController controller;
  final bool isDesktop;
  const LogcatSection({required this.controller, required this.isDesktop, super.key});

  @override
  State<LogcatSection> createState() => _LogcatSectionState();
}

class _LogcatSectionState extends State<LogcatSection> {
  late final ScrollController logcatScrollController;

  @override
  void initState() {
    super.initState();
    logcatScrollController = ScrollController();
  }

  @override
  void dispose() {
    logcatScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(kCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final isNarrow = constraints.maxWidth < 250;
                return isNarrow
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.controller.startAdbLogcat,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'Start',
                              style: Get.theme.textTheme.bodyLarge,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: widget.controller.stopAdbLogcat,
                            icon: const Icon(Icons.stop),
                            label: Text(
                              'Stop',
                              style: Get.theme.textTheme.bodyLarge,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      )
                    : Row(
                        children: [
                          ElevatedButton.icon(
                            onPressed: widget.controller.startAdbLogcat,
                            icon: const Icon(Icons.play_arrow),
                            label: Text(
                              'Start',
                              style: Get.theme.textTheme.bodyLarge,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                          const SizedBox(width: 12),
                          ElevatedButton.icon(
                            onPressed: widget.controller.stopAdbLogcat,
                            icon: const Icon(Icons.stop),
                            label: Text(
                              'Stop',
                              style: Get.theme.textTheme.bodyLarge,
                            ),
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                          ),
                        ],
                      );
              },
            ),
            const SizedBox(height: 16),
            Text(
              'ADB Logcat Output:',
              style: Get.theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 250),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black,
                    border: Border.all(color: Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Obx(
                    () => Scrollbar(
                      controller: logcatScrollController,
                      thumbVisibility: true,
                      child: SingleChildScrollView(
                        controller: logcatScrollController,
                        padding: const EdgeInsets.all(8.0),
                        child: SelectableText(
                          widget.controller.adbLog.value,
                          style: Get.theme.textTheme.bodySmall?.copyWith(
                            fontFamily: 'monospace',
                            fontSize: widget.isDesktop ? 15 : null,
                            color: Colors.greenAccent,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class HomePage extends GetView<HomeController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = [
      TargetPlatform.windows,
      TargetPlatform.linux,
      TargetPlatform.macOS,
    ].contains(Theme.of(context).platform);
    final horizontalPadding = isDesktop ? kHorizontalPaddingDesktop : kHorizontalPaddingMobile;

    return Scaffold(
      appBar: AppBar(
        title: Text('ADB QR Generator', style: Get.theme.textTheme.titleLarge),
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: horizontalPadding, vertical: 24),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Devices Section
            Expanded(
              child: Obx(() => DevicesSection(
                devices: controller.devices,
                onDisconnect: controller.disconnectDevice,
              )),
            ),
            const SizedBox(width: 24),
            // QR/Command Section
            Expanded(
              flex: 2,
              child: QrCommandSection(controller: controller, isDesktop: isDesktop),
            ),
            const SizedBox(width: 24),
            // Logcat Section
            Expanded(
              flex: 2,
              child: LogcatSection(controller: controller, isDesktop: isDesktop),
            ),
          ],
        ),
      ),
    );
  }
}
