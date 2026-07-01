import 'package:flutter/material.dart';

enum ScanMode {
  document,
  receipt,
  passport,
  idCard,
  businessCard,
  book,
  whiteboard,
  ;

  static ScanMode fromString(String? value) {
    return ScanMode.values.firstWhere(
      (m) => m.name == value,
      orElse: () => ScanMode.document,
    );
  }
}

extension ScanModeX on ScanMode {
  String get analyticsName => name;

  bool get isIdCard => this == ScanMode.idCard;

  bool get isBookMode => this == ScanMode.book;

  String get labelKey {
    switch (this) {
      case ScanMode.document:
        return 'scan_mode_document';
      case ScanMode.receipt:
        return 'scan_mode_receipt';
      case ScanMode.passport:
        return 'scan_mode_passport';
      case ScanMode.idCard:
        return 'scan_mode_id_card';
      case ScanMode.businessCard:
        return 'scan_mode_business_card';
      case ScanMode.book:
        return 'scan_mode_book';
      case ScanMode.whiteboard:
        return 'scan_mode_whiteboard';
    }
  }

  IconData get icon {
    switch (this) {
      case ScanMode.document:
        return Icons.description_rounded;
      case ScanMode.receipt:
        return Icons.receipt_long_rounded;
      case ScanMode.passport:
        return Icons.card_travel_rounded;
      case ScanMode.idCard:
        return Icons.badge_rounded;
      case ScanMode.businessCard:
        return Icons.contact_page_rounded;
      case ScanMode.book:
        return Icons.menu_book_rounded;
      case ScanMode.whiteboard:
        return Icons.draw_rounded;
    }
  }

  /// Default filter applied after capture for smart scan modes.
  String get defaultFilter {
    switch (this) {
      case ScanMode.receipt:
        return 'Receipt';
      case ScanMode.passport:
      case ScanMode.idCard:
      case ScanMode.businessCard:
        return 'Document';
      case ScanMode.book:
        return 'Auto Enhance';
      case ScanMode.whiteboard:
        return 'High Contrast';
      case ScanMode.document:
        return 'Original';
    }
  }

  double? get overlayAspectRatio {
    switch (this) {
      case ScanMode.idCard:
      case ScanMode.businessCard:
        return 1.586;
      case ScanMode.passport:
        return 0.704;
      case ScanMode.receipt:
        return 0.45;
      default:
        return null;
    }
  }
}

enum IdCardSide {
  front,
  back,
}
