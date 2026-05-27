import 'dart:io';
import '../models/document_model.dart';
import '../services/storage_service.dart';

class DocumentRepository {
  final StorageService _storage;

  DocumentRepository(this._storage);

  List<DocumentModel> getAllDocuments() {
    return _storage.readDocuments();
  }

  DocumentModel? getDocumentById(String id) {
    final docs = getAllDocuments();
    try {
      return docs.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }

  List<DocumentModel> getDocumentsByFolder(String folder) {
    if (folder == 'All Documents') return getAllDocuments();
    return getAllDocuments().where((d) => d.folder == folder).toList();
  }

  List<DocumentModel> getFavoriteDocuments() {
    return getAllDocuments().where((d) => d.isFavorite).toList();
  }

  List<DocumentModel> searchDocuments(String query) {
    final lower = query.toLowerCase();
    return getAllDocuments()
        .where((d) => d.name.toLowerCase().contains(lower))
        .toList();
  }

  void saveDocument(DocumentModel doc) {
    final docs = getAllDocuments();
    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index >= 0) {
      docs[index] = doc;
    } else {
      docs.insert(0, doc);
    }
    _storage.writeDocuments(docs);
  }

  void deleteDocument(String id) {
    final docs = getAllDocuments();
    final doc = docs.firstWhere((d) => d.id == id, orElse: () => throw Exception('Not found'));

    // Remove PDF file
    final pdfFile = File(doc.pdfPath);
    if (pdfFile.existsSync()) pdfFile.deleteSync();

    // Remove page images
    for (final path in doc.pageImagePaths) {
      final imgFile = File(path);
      if (imgFile.existsSync()) imgFile.deleteSync();
    }

    // Remove thumbnail
    if (doc.thumbnailPath != null) {
      final thumbFile = File(doc.thumbnailPath!);
      if (thumbFile.existsSync()) thumbFile.deleteSync();
    }

    docs.removeWhere((d) => d.id == id);
    _storage.writeDocuments(docs);
  }

  void toggleFavorite(String id) {
    final docs = getAllDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(isFavorite: !docs[index].isFavorite);
      _storage.writeDocuments(docs);
    }
  }

  void renameDocument(String id, String newName) {
    final docs = getAllDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(
        name: newName,
        updatedAt: DateTime.now(),
      );
      _storage.writeDocuments(docs);
    }
  }

  void moveToFolder(String id, String folder) {
    final docs = getAllDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(folder: folder);
      _storage.writeDocuments(docs);
    }
  }
}
