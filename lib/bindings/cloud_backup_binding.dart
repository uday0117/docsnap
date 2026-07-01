import 'package:get/get.dart';

import '../controllers/cloud_backup_controller.dart';
import '../repositories/document_repository.dart';
import '../services/cloud_backup_service.dart';

class CloudBackupBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CloudBackupController>(
      () => CloudBackupController(
        Get.find<CloudBackupService>(),
        Get.find<DocumentRepository>(),
      ),
      fenix: true,
    );
  }
}
