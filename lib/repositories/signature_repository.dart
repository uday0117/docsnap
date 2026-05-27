import 'dart:io';
import '../models/signature_model.dart';
import '../services/storage_service.dart';

class SignatureRepository {
  final StorageService _storage;

  SignatureRepository(this._storage);

  List<SignatureModel> getAllSignatures() {
    return _storage.readSignatures();
  }

  void saveSignature(SignatureModel signature) {
    final sigs = getAllSignatures();
    final index = sigs.indexWhere((s) => s.id == signature.id);
    if (index >= 0) {
      sigs[index] = signature;
    } else {
      sigs.insert(0, signature);
    }
    _storage.writeSignatures(sigs);
  }

  void deleteSignature(String id) {
    final sigs = getAllSignatures();
    final sig = sigs.firstWhere((s) => s.id == id,
        orElse: () => throw Exception('Signature not found'));

    final imgFile = File(sig.imagePath);
    if (imgFile.existsSync()) imgFile.deleteSync();

    sigs.removeWhere((s) => s.id == id);
    _storage.writeSignatures(sigs);
  }

  void renameSignature(String id, String newName) {
    final sigs = getAllSignatures();
    final index = sigs.indexWhere((s) => s.id == id);
    if (index >= 0) {
      sigs[index].name = newName;
      _storage.writeSignatures(sigs);
    }
  }
}
