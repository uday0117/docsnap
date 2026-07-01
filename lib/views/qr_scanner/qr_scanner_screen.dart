import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../services/permission_service.dart';
import '../../services/storage_service.dart';
import '../../themes/app_theme.dart';
import '../../utils/app_helpers.dart';
import '../../widgets/common_widgets.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen>
    with SingleTickerProviderStateMixin {
  final MobileScannerController _scannerCtrl = MobileScannerController(
    detectionSpeed: DetectionSpeed.noDuplicates,
    facing: CameraFacing.back,
  );
  bool _torchOn = false;

  late TabController _tabController;
  bool _scanned = false;
  List<Map<String, dynamic>> _history = [];
  final TextEditingController _generateController = TextEditingController();
  String _generateValue = 'https://uksolutions.app';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadHistory();
    _generateController.text = _generateValue;
    _requestCameraPermission();
  }

  void _onTabChanged() {
    if (!mounted) return;
    if (_tabController.index == 0 && !_scanned) {
      _scannerCtrl.start();
    } else if (_tabController.index != 0) {
      _scannerCtrl.stop();
    }
    setState(() {});
  }

  Future<void> _requestCameraPermission() async {
    if (Get.isRegistered<PermissionService>()) {
      await Get.find<PermissionService>().requestCameraPermission();
    }
  }

  void _loadHistory() {
    final history = Get.find<StorageService>().readQrHistory();
    setState(() {
      _history = history;
    });
  }

  void _saveToHistory(String value, String type) {
    final entry = {
      'value': value,
      'type': type,
      'timestamp': DateTime.now().toIso8601String(),
    };
    _history.insert(0, entry);
    if (_history.length > 50) _history = _history.take(50).toList();
    Get.find<StorageService>().writeQrHistory(_history);
  }

  void _onDetect(BarcodeCapture capture) {
    if (_scanned) return;

    final barcode = capture.barcodes.firstOrNull;
    if (barcode == null || barcode.rawValue == null) return;

    setState(() => _scanned = true);
    _scannerCtrl.stop();

    final value = barcode.rawValue!;
    final type = _barcodeType(barcode.format);

    _saveToHistory(value, type);
    HapticFeedback.mediumImpact();

    _showResultSheet(value, type);
  }

  String _barcodeType(BarcodeFormat format) {
    switch (format) {
      case BarcodeFormat.qrCode:
        return 'QR Code';
      case BarcodeFormat.ean13:
        return 'EAN-13';
      case BarcodeFormat.ean8:
        return 'EAN-8';
      case BarcodeFormat.code128:
        return 'Code 128';
      case BarcodeFormat.code39:
        return 'Code 39';
      case BarcodeFormat.upcA:
        return 'UPC-A';
      case BarcodeFormat.pdf417:
        return 'PDF417';
      case BarcodeFormat.dataMatrix:
        return 'Data Matrix';
      default:
        return 'Barcode';
    }
  }

  void _showResultSheet(String value, String type) {
    final isUrl = value.startsWith('http://') || value.startsWith('https://');

    Get.bottomSheet(
      Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withAlpha(20),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.qr_code_rounded,
                      color: AppTheme.primaryColor),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'scan_result'.tr,
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 16),
                      ),
                      Text(
                        type,
                        style: const TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withAlpha(15)
                    : Colors.grey.withAlpha(20),
                borderRadius: BorderRadius.circular(12),
              ),
              child: SelectableText(
                value,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: [
                _ResultAction(
                  icon: Icons.copy_rounded,
                  label: 'copy'.tr,
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: value));
                    Get.back();
                    AppHelpers.showSnackbar('text_copied'.tr,
                        title: 'copied'.tr);
                  },
                ),
                if (isUrl)
                  _ResultAction(
                    icon: Icons.open_in_browser_rounded,
                    label: 'open_url'.tr,
                    color: Colors.blue,
                    onTap: () async {
                      Get.back();
                      final uri = Uri.parse(value);
                      if (await canLaunchUrl(uri)) {
                        await launchUrl(uri,
                            mode: LaunchMode.externalApplication);
                      }
                    },
                  ),
                _ResultAction(
                  icon: Icons.share_rounded,
                  label: 'share'.tr,
                  color: Colors.purple,
                  onTap: () {
                    Get.back();
                    Share.share(value);
                  },
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  Get.back();
                  setState(() => _scanned = false);
                  _scannerCtrl.start();
                },
                icon: const Icon(Icons.qr_code_scanner_rounded),
                label: Text('scan_again'.tr),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),
            ),
            SizedBox(height: MediaQuery.of(context).padding.bottom + 8),
          ],
        ),
      ),
      isScrollControlled: true,
    ).then((_) {
      if (!mounted || _tabController.index != 0) return;
      setState(() => _scanned = false);
      _scannerCtrl.start();
    });
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _scannerCtrl.dispose();
    _tabController.dispose();
    _generateController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isScannerTab = _tabController.index == 0;

    return Scaffold(
      backgroundColor: isScannerTab ? Colors.black : null,
      appBar: GradientAppBar(
        title: 'qr_barcode_scanner'.tr,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(58),
          child: AppSegmentedTabs(
            controller: _tabController,
            tabs: [
              AppSegmentedTabItem(
                icon: Icons.qr_code_scanner_rounded,
                label: 'tab_scanner'.tr,
              ),
              AppSegmentedTabItem(
                icon: Icons.qr_code_2_rounded,
                label: 'tab_generate'.tr,
              ),
              AppSegmentedTabItem(
                icon: Icons.history_rounded,
                label: 'tab_history'.tr,
              ),
            ],
          ),
        ),
        actions: [
          if (isScannerTab)
            IconButton(
              icon: Icon(
                _torchOn ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                color: _torchOn ? Colors.amber : Colors.white,
              ),
              onPressed: () async {
                await _scannerCtrl.toggleTorch();
                setState(() => _torchOn = !_torchOn);
              },
            ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildScannerView(),
          _buildGenerateView(),
          _buildHistoryView(),
        ],
      ),
    );
  }

  Widget _buildScannerView() {
    return LayoutBuilder(
      builder: (context, constraints) {
        final frameSize = (constraints.maxWidth * 0.68).clamp(200.0, 280.0);

        return Stack(
          fit: StackFit.expand,
          children: [
            MobileScanner(
              controller: _scannerCtrl,
              onDetect: _onDetect,
            ),
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withAlpha(120),
                BlendMode.srcOut,
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.srcOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: frameSize,
                      height: frameSize,
                      decoration: BoxDecoration(
                        color: Colors.black,
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: frameSize,
                    height: frameSize,
                    child: const _ScannerCorners(),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 24),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: Text(
                      'point_qr_code'.tr,
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildGenerateView() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          TextField(
            controller: _generateController,
            maxLines: 3,
            onChanged: (v) => setState(() => _generateValue = v),
            decoration: InputDecoration(
              labelText: 'text_or_url'.tr,
              hintText: 'hint_text_url'.tr,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              filled: true,
            ),
          ),
          const SizedBox(height: 24),
          if (_generateValue.trim().isNotEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(20),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: QrImageView(
                data: _generateValue.trim(),
                version: QrVersions.auto,
                size: 220,
                backgroundColor: Colors.white,
                eyeStyle: const QrEyeStyle(
                  eyeShape: QrEyeShape.square,
                  color: AppTheme.primaryColor,
                ),
                dataModuleStyle: const QrDataModuleStyle(
                  dataModuleShape: QrDataModuleShape.square,
                  color: AppTheme.primaryDark,
                ),
              ),
            ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: _generateValue.trim().isEmpty
                      ? null
                      : () {
                          Clipboard.setData(
                            ClipboardData(text: _generateValue.trim()),
                          );
                          AppHelpers.showSnackbar(
                            'text_copied'.tr,
                            title: 'copied'.tr,
                          );
                        },
                  icon: const Icon(Icons.copy_rounded),
                  label: Text('copy'.tr),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: _generateValue.trim().isEmpty
                      ? null
                      : () => Share.share(_generateValue.trim()),
                  icon: const Icon(Icons.share_rounded),
                  label: Text('share'.tr),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryView() {
    if (_history.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.history_rounded,
              size: 60,
              color: Colors.grey.withAlpha(160),
            ),
            const SizedBox(height: 12),
            Text(
              'no_scan_history'.tr,
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: _history.length,
      itemBuilder: (context, index) {
        final item = _history[index];
        final value = item['value'] as String;
        final type = item['type'] as String;
        final ts = DateTime.tryParse(item['timestamp'] ?? '');

        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          child: ListTile(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppTheme.primaryColor.withAlpha(30),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.qr_code_rounded,
                  color: AppTheme.primaryColor, size: 20),
            ),
            title: Text(
              value,
              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Text(
              '$type • ${ts != null ? AppHelpers.formatDate(ts) : ''}',
              style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.copy_rounded,
                      color: Colors.grey, size: 18),
                  onPressed: () {
                    Clipboard.setData(ClipboardData(text: value));
                    AppHelpers.showSnackbar('text_copied'.tr,
                        title: 'copied'.tr);
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.share_rounded,
                      color: Colors.grey, size: 18),
                  onPressed: () => Share.share(value),
                ),
              ],
            ),
            onTap: () => _showResultSheet(value, type),
          ),
        );
      },
    );
  }
}

class _ScannerCorners extends StatelessWidget {
  const _ScannerCorners();

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CornerPainter(color: AppTheme.primaryColor),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  _CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const len = 30.0;
    final corners = [
      [Offset(0, len), Offset.zero, Offset(len, 0)],
      [
        Offset(size.width - len, 0),
        Offset(size.width, 0),
        Offset(size.width, len)
      ],
      [
        Offset(size.width, size.height - len),
        Offset(size.width, size.height),
        Offset(size.width - len, size.height)
      ],
      [
        Offset(len, size.height),
        Offset(0, size.height),
        Offset(0, size.height - len)
      ],
    ];

    for (final corner in corners) {
      final path = Path()
        ..moveTo(corner[0].dx, corner[0].dy)
        ..lineTo(corner[1].dx, corner[1].dy)
        ..lineTo(corner[2].dx, corner[2].dy);
      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(_CornerPainter old) => old.color != color;
}

class _ResultAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color? color;
  final VoidCallback onTap;

  const _ResultAction({
    required this.icon,
    required this.label,
    required this.onTap,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTheme.primaryColor;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          width: 96,
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: c.withAlpha(20),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: c.withAlpha(60)),
          ),
          child: Column(
            children: [
              Icon(icon, color: c, size: 22),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: c,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
