import 'dart:io';
import '../models/document_model.dart';
import '../services/storage_service.dart';

class DocumentRepository {
  final StorageService _storage;

  DocumentRepository(this._storage);

  List<DocumentModel> getAllDocuments({bool includeDeleted = false}) {
    final docs = _storage.readDocuments();
    if (includeDeleted) return docs;
    return docs.where((d) => !d.isDeleted).toList();
  }

  List<DocumentModel> getTrashDocuments() {
    return _storage.readDocuments().where((d) => d.isDeleted).toList();
  }

  List<DocumentModel> getPinnedDocuments() {
    return getAllDocuments().where((d) => d.isPinned).toList();
  }

  DocumentModel? getDocumentById(String id) {
    final docs = _storage.readDocuments();
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

  List<DocumentModel> searchDocuments(
    String query, {
    bool searchOcr = true,
  }) {
    final lower = query.toLowerCase().trim();
    if (lower.isEmpty) return getAllDocuments();

    return getAllDocuments().where((d) {
      if (d.name.toLowerCase().contains(lower)) return true;
      if (searchOcr &&
          d.ocrText != null &&
          d.ocrText!.toLowerCase().contains(lower)) {
        return true;
      }
      if (d.tags.any((t) => t.toLowerCase().contains(lower))) return true;
      if (d.folder.toLowerCase().contains(lower)) return true;
      return false;
    }).toList();
  }

  void replaceAllDocuments(List<DocumentModel> docs) {
    _storage.writeDocuments(docs);
  }

  void saveDocument(DocumentModel doc) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == doc.id);
    if (index >= 0) {
      docs[index] = doc;
    } else {
      docs.insert(0, doc);
    }
    _storage.writeDocuments(docs);
  }

  void deleteDocument(String id, {bool permanent = false}) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index < 0) return;

    if (!permanent) {
      docs[index] = docs[index].copyWith(
        isDeleted: true,
        updatedAt: DateTime.now(),
      );
      _storage.writeDocuments(docs);
      return;
    }

    final doc = docs[index];
    _deleteFiles(doc);
    docs.removeAt(index);
    _storage.writeDocuments(docs);
  }

  void restoreDocument(String id) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(
        isDeleted: false,
        updatedAt: DateTime.now(),
      );
      _storage.writeDocuments(docs);
    }
  }

  void emptyTrash() {
    final docs = _storage.readDocuments();
    final trash = docs.where((d) => d.isDeleted).toList();
    for (final doc in trash) {
      _deleteFiles(doc);
    }
    docs.removeWhere((d) => d.isDeleted);
    _storage.writeDocuments(docs);
  }

  void _deleteFiles(DocumentModel doc) {
    final pdfFile = File(doc.pdfPath);
    if (pdfFile.existsSync()) pdfFile.deleteSync();

    for (final path in doc.pageImagePaths) {
      final imgFile = File(path);
      if (imgFile.existsSync()) imgFile.deleteSync();
    }

    if (doc.thumbnailPath != null) {
      final thumbFile = File(doc.thumbnailPath!);
      if (thumbFile.existsSync()) thumbFile.deleteSync();
    }
  }

  void toggleFavorite(String id) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(isFavorite: !docs[index].isFavorite);
      _storage.writeDocuments(docs);
    }
  }

  void togglePinned(String id) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(isPinned: !docs[index].isPinned);
      _storage.writeDocuments(docs);
    }
  }

  void updateOcrText(String id, String text) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(
        ocrText: text,
        updatedAt: DateTime.now(),
      );
      _storage.writeDocuments(docs);
    }
  }

  void updateTags(String id, List<String> tags) {
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(
        tags: tags,
        updatedAt: DateTime.now(),
      );
      _storage.writeDocuments(docs);
    }
  }

  void renameDocument(String id, String newName) {
    final docs = _storage.readDocuments();
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
    final docs = _storage.readDocuments();
    final index = docs.indexWhere((d) => d.id == id);
    if (index >= 0) {
      docs[index] = docs[index].copyWith(folder: folder);
      _storage.writeDocuments(docs);
    }
  }

  DocumentModel duplicateDocument(String id) {
    final doc = getDocumentById(id);
    if (doc == null) throw Exception('Document not found');

    final copy = DocumentModel(
      name: '${doc.name} (Copy)',
      pdfPath: doc.pdfPath,
      pageImagePaths: List<String>.from(doc.pageImagePaths),
      pageCount: doc.pageCount,
      folder: doc.folder,
      sizeBytes: doc.sizeBytes,
      thumbnailPath: doc.thumbnailPath,
      tags: List<String>.from(doc.tags),
      ocrText: doc.ocrText,
    );
    saveDocument(copy);
    return copy;
  }
}
