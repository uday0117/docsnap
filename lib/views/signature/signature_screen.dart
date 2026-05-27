import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:signature/signature.dart' as sig_pkg;
import '../../controllers/signature_controller.dart';
import '../../models/signature_model.dart';
import '../../themes/app_theme.dart';
import '../../widgets/common_widgets.dart';

class SignatureScreen extends GetView<SignatureController> {
  const SignatureScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final drawController = sig_pkg.SignatureController(
      penStrokeWidth: 3,
      penColor: Colors.black,
      exportBackgroundColor: Colors.white,
    );

    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: GradientAppBar(
          title: 'Signature',
          actions: const [],
        ),
        body: Column(
          children: [
            const TabBar(
              indicatorColor: AppTheme.primaryColor,
              labelColor: AppTheme.primaryColor,
              unselectedLabelColor: Colors.grey,
              tabs: [
                Tab(text: 'Draw Signature'),
                Tab(text: 'Saved Signatures'),
              ],
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _DrawSignatureTab(
                    signatureCtrl: controller,
                    drawController: drawController,
                  ),
                  _SavedSignaturesTab(ctrl: controller),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DrawSignatureTab extends StatelessWidget {
  final SignatureController signatureCtrl;
  final sig_pkg.SignatureController drawController;

  const _DrawSignatureTab({
    required this.signatureCtrl,
    required this.drawController,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 12),
          _buildStrokeOptions(context),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.primaryColor.withAlpha(50),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 12,
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: sig_pkg.Signature(
                  controller: drawController,
                  backgroundColor: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: drawController.clear,
                  icon: const Icon(Icons.refresh_rounded),
                  label: const Text('Clear'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () async {
                    if (drawController.isEmpty) {
                      Get.snackbar(
                        'Empty',
                        'Please draw a signature first',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                      return;
                    }
                    final data = await drawController.toPngBytes();
                    if (data != null) {
                      await signatureCtrl.saveSignature(data);
                    }
                  },
                  icon: const Icon(Icons.save_rounded),
                  label: const Text('Save'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildStrokeOptions(BuildContext context) {
    return Row(
      children: [
        const Text('Stroke Width:',
            style: TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(width: 12),
        Expanded(
          child: Obx(
            () => Slider(
              value: signatureCtrl.strokeWidth.value,
              min: 1.0,
              max: 8.0,
              divisions: 7,
              activeColor: AppTheme.primaryColor,
              onChanged: signatureCtrl.setStrokeWidth,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Obx(
          () => Text(
            '${signatureCtrl.strokeWidth.value.round()}px',
            style: const TextStyle(fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }
}

class _SavedSignaturesTab extends StatelessWidget {
  final SignatureController ctrl;

  const _SavedSignaturesTab({required this.ctrl});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (ctrl.signatures.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.draw_outlined, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              const Text(
                'No saved signatures',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Draw a signature in the Draw tab to save it.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        );
      }

      return GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 1.4,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
        ),
        itemCount: ctrl.signatures.length,
        itemBuilder: (_, index) {
          final sig = ctrl.signatures[index];
          return _SignatureCard(
            signature: sig,
            onSelect: () => ctrl.selectSavedSignature(sig),
            onDelete: () => ctrl.deleteSignature(sig),
          );
        },
      );
    });
  }
}

class _SignatureCard extends StatelessWidget {
  final SignatureModel signature;
  final VoidCallback onSelect;
  final VoidCallback onDelete;

  const _SignatureCard({
    required this.signature,
    required this.onSelect,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onSelect,
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                children: [
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        color: Colors.grey.shade100,
                        child: File(signature.imagePath).existsSync()
                            ? Image.file(
                                File(signature.imagePath),
                                fit: BoxFit.contain,
                              )
                            : const Icon(Icons.draw, color: Colors.grey),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    signature.name,
                    style: const TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            Positioned(
              top: 4,
              right: 4,
              child: GestureDetector(
                onTap: onDelete,
                child: Container(
                  width: 24,
                  height: 24,
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.close, size: 14, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
