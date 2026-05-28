import 'package:get/get.dart';

class AppTranslations extends Translations {
  @override
  Map<String, Map<String, String>> get keys => {
        'en_US': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Scan',
          'total_documents': 'Total Documents',
          'total_pages': 'Total Pages',
          'recent_documents': 'Recent Documents',
          'no_documents': 'No documents yet',
          'start_scanning': 'Start scanning to create your first document',
          'quick_actions': 'Quick Actions',
          'my_documents': 'My Documents',
          'signatures': 'Signatures',

          // Scanner
          'scanner': 'Scanner',
          'capture': 'Capture',
          'gallery': 'Gallery',
          'flash': 'Flash',
          'switch_camera': 'Switch Camera',
          'document_name': 'Document Name',
          'add_more_pages': 'Add More Pages',
          'done': 'Done',
          'cancel': 'Cancel',

          // Crop Editor
          'crop_editor': 'Crop Editor',
          'crop': 'Crop',
          'rotate': 'Rotate',
          'apply': 'Apply',

          // Filters
          'filters': 'Filters',
          'original': 'Original',
          'black_white': 'Black & White',
          'grayscale': 'Grayscale',
          'high_contrast': 'High Contrast',
          'magic_color': 'Magic Color',

          // Documents
          'documents': 'Documents',
          'search': 'Search',
          'sort_by': 'Sort By',
          'date': 'Date',
          'name': 'Name',
          'size': 'Size',
          'all_documents': 'All Documents',
          'favorites': 'Favorites',
          'rename': 'Rename',
          'delete': 'Delete',
          'share': 'Share',
          'move_to_folder': 'Move to Folder',

          // PDF Generation
          'generate_pdf': 'Generate PDF',
          'pdf_quality': 'PDF Quality',
          'high': 'High',
          'medium': 'Medium',
          'low': 'Low',
          'folder': 'Folder',
          'generate': 'Generate',

          // PDF Viewer
          'pdf_viewer': 'PDF Viewer',
          'page': 'Page',
          'of': 'of',
          'zoom_in': 'Zoom In',
          'zoom_out': 'Zoom Out',

          // Signature
          'signature': 'Signature',
          'draw_signature': 'Draw Signature',
          'saved_signatures': 'Saved Signatures',
          'clear': 'Clear',
          'save': 'Save',

          // Settings
          'settings': 'Settings',
          'language': 'Language',
          'app_language': 'App Language',
          'choose_language': 'Choose your preferred language',
          'about': 'About',
          'privacy_policy': 'Privacy Policy',
          'terms_and_conditions': 'Terms & Conditions',
          'rate_app': 'Rate App',
          'app_version': 'App Version',
          'danger_zone': 'Danger Zone',
          'clear_all_data': 'Clear All Data',

          // Common
          'ok': 'OK',
          'yes': 'Yes',
          'no': 'No',
          'confirm': 'Confirm',
          'loading': 'Loading...',
          'error': 'Error',
          'could_not_open_privacy_policy': 'Could not open Privacy Policy',
          'could_not_open_terms': 'Could not open Terms & Conditions',
          'could_not_open_store': 'Could not open App Store',
          'success': 'Success',
          'warning': 'Warning',
        },
        'es_ES': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Escanear',
          'total_documents': 'Documentos Totales',
          'total_pages': 'Páginas Totales',
          'recent_documents': 'Documentos Recientes',
          'no_documents': 'Aún no hay documentos',
          'start_scanning':
              'Comienza a escanear para crear tu primer documento',
          'quick_actions': 'Acciones Rápidas',
          'my_documents': 'Mis Documentos',
          'signatures': 'Firmas',

          // Scanner
          'scanner': 'Escáner',
          'capture': 'Capturar',
          'gallery': 'Galería',
          'flash': 'Flash',
          'switch_camera': 'Cambiar Cámara',
          'document_name': 'Nombre del Documento',
          'add_more_pages': 'Agregar Más Páginas',
          'done': 'Hecho',
          'cancel': 'Cancelar',

          // Crop Editor
          'crop_editor': 'Editor de Recorte',
          'crop': 'Recortar',
          'rotate': 'Rotar',
          'apply': 'Aplicar',

          // Filters
          'filters': 'Filtros',
          'original': 'Original',
          'black_white': 'Blanco y Negro',
          'grayscale': 'Escala de Grises',
          'high_contrast': 'Alto Contraste',
          'magic_color': 'Color Mágico',

          // Documents
          'documents': 'Documentos',
          'search': 'Buscar',
          'sort_by': 'Ordenar Por',
          'date': 'Fecha',
          'name': 'Nombre',
          'size': 'Tamaño',
          'all_documents': 'Todos los Documentos',
          'favorites': 'Favoritos',
          'rename': 'Renombrar',
          'delete': 'Eliminar',
          'share': 'Compartir',
          'move_to_folder': 'Mover a Carpeta',

          // PDF Generation
          'generate_pdf': 'Generar PDF',
          'pdf_quality': 'Calidad PDF',
          'high': 'Alta',
          'medium': 'Media',
          'low': 'Baja',
          'folder': 'Carpeta',
          'generate': 'Generar',

          // PDF Viewer
          'pdf_viewer': 'Visor de PDF',
          'page': 'Página',
          'of': 'de',
          'zoom_in': 'Acercar',
          'zoom_out': 'Alejar',

          // Signature
          'signature': 'Firma',
          'draw_signature': 'Dibujar Firma',
          'saved_signatures': 'Firmas Guardadas',
          'clear': 'Limpiar',
          'save': 'Guardar',

          // Settings
          'settings': 'Configuración',
          'language': 'Idioma',
          'app_language': 'Idioma de la Aplicación',
          'choose_language': 'Elige tu idioma preferido',
          'about': 'Acerca de',
          'privacy_policy': 'Política de Privacidad',
          'terms_and_conditions': 'Términos y Condiciones',
          'rate_app': 'Calificar Aplicación',
          'app_version': 'Versión de la Aplicación',
          'danger_zone': 'Zona de Peligro',
          'clear_all_data': 'Borrar Todos los Datos',

          // Common
          'ok': 'OK',
          'yes': 'Sí',
          'no': 'No',
          'confirm': 'Confirmar',
          'loading': 'Cargando...',
          'error': 'Error',
          'could_not_open_privacy_policy':
              'No se pudo abrir la Política de Privacidad',
          'could_not_open_terms':
              'No se pudieron abrir los Términos y Condiciones',
          'could_not_open_store': 'No se pudo abrir la Tienda de Aplicaciones',
          'success': 'Éxito',
          'warning': 'Advertencia',
        },
        'fr_FR': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Scanner',
          'total_documents': 'Documents Totaux',
          'total_pages': 'Pages Totales',
          'recent_documents': 'Documents Récents',
          'no_documents': 'Pas encore de documents',
          'start_scanning':
              'Commencez à scanner pour créer votre premier document',
          'quick_actions': 'Actions Rapides',
          'my_documents': 'Mes Documents',
          'signatures': 'Signatures',

          // Scanner
          'scanner': 'Scanner',
          'capture': 'Capturer',
          'gallery': 'Galerie',
          'flash': 'Flash',
          'switch_camera': 'Changer de Caméra',
          'document_name': 'Nom du Document',
          'add_more_pages': 'Ajouter Plus de Pages',
          'done': 'Terminé',
          'cancel': 'Annuler',

          // Crop Editor
          'crop_editor': 'Éditeur de Recadrage',
          'crop': 'Recadrer',
          'rotate': 'Pivoter',
          'apply': 'Appliquer',

          // Filters
          'filters': 'Filtres',
          'original': 'Original',
          'black_white': 'Noir et Blanc',
          'grayscale': 'Niveaux de Gris',
          'high_contrast': 'Contraste Élevé',
          'magic_color': 'Couleur Magique',

          // Documents
          'documents': 'Documents',
          'search': 'Rechercher',
          'sort_by': 'Trier Par',
          'date': 'Date',
          'name': 'Nom',
          'size': 'Taille',
          'all_documents': 'Tous les Documents',
          'favorites': 'Favoris',
          'rename': 'Renommer',
          'delete': 'Supprimer',
          'share': 'Partager',
          'move_to_folder': 'Déplacer vers le Dossier',

          // PDF Generation
          'generate_pdf': 'Générer PDF',
          'pdf_quality': 'Qualité PDF',
          'high': 'Haute',
          'medium': 'Moyenne',
          'low': 'Basse',
          'folder': 'Dossier',
          'generate': 'Générer',

          // PDF Viewer
          'pdf_viewer': 'Visionneuse PDF',
          'page': 'Page',
          'of': 'sur',
          'zoom_in': 'Zoomer',
          'zoom_out': 'Dézoomer',

          // Signature
          'signature': 'Signature',
          'draw_signature': 'Dessiner une Signature',
          'saved_signatures': 'Signatures Enregistrées',
          'clear': 'Effacer',
          'save': 'Enregistrer',

          // Settings
          'settings': 'Paramètres',
          'language': 'Langue',
          'app_language': 'Langue de l\'Application',
          'choose_language': 'Choisissez votre langue préférée',
          'about': 'À Propos',
          'privacy_policy': 'Politique de Confidentialité',
          'terms_and_conditions': 'Termes et Conditions',
          'rate_app': 'Évaluer l\'Application',
          'app_version': 'Version de l\'Application',
          'danger_zone': 'Zone de Danger',
          'clear_all_data': 'Effacer Toutes les Données',

          // Common
          'ok': 'OK',
          'yes': 'Oui',
          'no': 'Non',
          'confirm': 'Confirmer',
          'loading': 'Chargement...',
          'error': 'Erreur',
          'could_not_open_privacy_policy':
              'Impossible d\'ouvrir la Politique de Confidentialité',
          'could_not_open_terms':
              'Impossible d\'ouvrir les Termes et Conditions',
          'could_not_open_store': 'Impossible d\'ouvrir l\'App Store',
          'success': 'Succès',
          'warning': 'Avertissement',
        },
        'de_DE': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Scannen',
          'total_documents': 'Dokumente Gesamt',
          'total_pages': 'Seiten Gesamt',
          'recent_documents': 'Neueste Dokumente',
          'no_documents': 'Noch keine Dokumente',
          'start_scanning':
              'Beginnen Sie mit dem Scannen, um Ihr erstes Dokument zu erstellen',
          'quick_actions': 'Schnellaktionen',
          'my_documents': 'Meine Dokumente',
          'signatures': 'Unterschriften',

          // Scanner
          'scanner': 'Scanner',
          'capture': 'Aufnehmen',
          'gallery': 'Galerie',
          'flash': 'Blitz',
          'switch_camera': 'Kamera Wechseln',
          'document_name': 'Dokumentname',
          'add_more_pages': 'Weitere Seiten Hinzufügen',
          'done': 'Fertig',
          'cancel': 'Abbrechen',

          // Crop Editor
          'crop_editor': 'Zuschneiden Editor',
          'crop': 'Zuschneiden',
          'rotate': 'Drehen',
          'apply': 'Anwenden',

          // Filters
          'filters': 'Filter',
          'original': 'Original',
          'black_white': 'Schwarz-Weiß',
          'grayscale': 'Graustufen',
          'high_contrast': 'Hoher Kontrast',
          'magic_color': 'Magische Farbe',

          // Documents
          'documents': 'Dokumente',
          'search': 'Suchen',
          'sort_by': 'Sortieren Nach',
          'date': 'Datum',
          'name': 'Name',
          'size': 'Größe',
          'all_documents': 'Alle Dokumente',
          'favorites': 'Favoriten',
          'rename': 'Umbenennen',
          'delete': 'Löschen',
          'share': 'Teilen',
          'move_to_folder': 'In Ordner Verschieben',

          // PDF Generation
          'generate_pdf': 'PDF Erstellen',
          'pdf_quality': 'PDF-Qualität',
          'high': 'Hoch',
          'medium': 'Mittel',
          'low': 'Niedrig',
          'folder': 'Ordner',
          'generate': 'Erstellen',

          // PDF Viewer
          'pdf_viewer': 'PDF-Betrachter',
          'page': 'Seite',
          'of': 'von',
          'zoom_in': 'Vergrößern',
          'zoom_out': 'Verkleinern',

          // Signature
          'signature': 'Unterschrift',
          'draw_signature': 'Unterschrift Zeichnen',
          'saved_signatures': 'Gespeicherte Unterschriften',
          'clear': 'Löschen',
          'save': 'Speichern',

          // Settings
          'settings': 'Einstellungen',
          'language': 'Sprache',
          'app_language': 'App-Sprache',
          'choose_language': 'Wählen Sie Ihre bevorzugte Sprache',
          'about': 'Über',
          'privacy_policy': 'Datenschutzrichtlinie',
          'terms_and_conditions': 'Geschäftsbedingungen',
          'rate_app': 'App Bewerten',
          'app_version': 'App-Version',
          'danger_zone': 'Gefahrenzone',
          'clear_all_data': 'Alle Daten Löschen',

          // Common
          'ok': 'OK',
          'yes': 'Ja',
          'no': 'Nein',
          'confirm': 'Bestätigen',
          'loading': 'Laden...',
          'error': 'Fehler',
          'could_not_open_privacy_policy':
              'Datenschutzrichtlinie konnte nicht geöffnet werden',
          'could_not_open_terms':
              'Geschäftsbedingungen konnten nicht geöffnet werden',
          'could_not_open_store': 'App Store konnte nicht geöffnet werden',
          'success': 'Erfolg',
          'warning': 'Warnung',
        },
        'it_IT': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Scansiona',
          'total_documents': 'Documenti Totali',
          'total_pages': 'Pagine Totali',
          'recent_documents': 'Documenti Recenti',
          'no_documents': 'Nessun documento ancora',
          'start_scanning':
              'Inizia a scansionare per creare il tuo primo documento',
          'quick_actions': 'Azioni Rapide',
          'my_documents': 'I Miei Documenti',
          'signatures': 'Firme',

          // Scanner
          'scanner': 'Scanner',
          'capture': 'Cattura',
          'gallery': 'Galleria',
          'flash': 'Flash',
          'switch_camera': 'Cambia Fotocamera',
          'document_name': 'Nome Documento',
          'add_more_pages': 'Aggiungi Altre Pagine',
          'done': 'Fatto',
          'cancel': 'Annulla',

          // Crop Editor
          'crop_editor': 'Editor di Ritaglio',
          'crop': 'Ritaglia',
          'rotate': 'Ruota',
          'apply': 'Applica',

          // Filters
          'filters': 'Filtri',
          'original': 'Originale',
          'black_white': 'Bianco e Nero',
          'grayscale': 'Scala di Grigi',
          'high_contrast': 'Alto Contrasto',
          'magic_color': 'Colore Magico',

          // Documents
          'documents': 'Documenti',
          'search': 'Cerca',
          'sort_by': 'Ordina Per',
          'date': 'Data',
          'name': 'Nome',
          'size': 'Dimensione',
          'all_documents': 'Tutti i Documenti',
          'favorites': 'Preferiti',
          'rename': 'Rinomina',
          'delete': 'Elimina',
          'share': 'Condividi',
          'move_to_folder': 'Sposta in Cartella',

          // PDF Generation
          'generate_pdf': 'Genera PDF',
          'pdf_quality': 'Qualità PDF',
          'high': 'Alta',
          'medium': 'Media',
          'low': 'Bassa',
          'folder': 'Cartella',
          'generate': 'Genera',

          // PDF Viewer
          'pdf_viewer': 'Visualizzatore PDF',
          'page': 'Pagina',
          'of': 'di',
          'zoom_in': 'Ingrandisci',
          'zoom_out': 'Riduci',

          // Signature
          'signature': 'Firma',
          'draw_signature': 'Disegna Firma',
          'saved_signatures': 'Firme Salvate',
          'clear': 'Cancella',
          'save': 'Salva',

          // Settings
          'settings': 'Impostazioni',
          'language': 'Lingua',
          'app_language': 'Lingua dell\'App',
          'choose_language': 'Scegli la tua lingua preferita',
          'about': 'Informazioni',
          'privacy_policy': 'Politica sulla Privacy',
          'terms_and_conditions': 'Termini e Condizioni',
          'rate_app': 'Valuta App',
          'app_version': 'Versione App',
          'danger_zone': 'Zona di Pericolo',
          'clear_all_data': 'Cancella Tutti i Dati',

          // Common
          'ok': 'OK',
          'yes': 'Sì',
          'no': 'No',
          'confirm': 'Conferma',
          'loading': 'Caricamento...',
          'error': 'Errore',
          'could_not_open_privacy_policy':
              'Impossibile aprire la Politica sulla Privacy',
          'could_not_open_terms': 'Impossibile aprire i Termini e Condizioni',
          'could_not_open_store': 'Impossibile aprire l\'App Store',
          'success': 'Successo',
          'warning': 'Avviso',
        },
        'pt_PT': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'Digitalizar',
          'total_documents': 'Documentos Totais',
          'total_pages': 'Páginas Totais',
          'recent_documents': 'Documentos Recentes',
          'no_documents': 'Ainda não há documentos',
          'start_scanning':
              'Comece a digitalizar para criar seu primeiro documento',
          'quick_actions': 'Ações Rápidas',
          'my_documents': 'Meus Documentos',
          'signatures': 'Assinaturas',

          // Scanner
          'scanner': 'Scanner',
          'capture': 'Capturar',
          'gallery': 'Galeria',
          'flash': 'Flash',
          'switch_camera': 'Trocar Câmera',
          'document_name': 'Nome do Documento',
          'add_more_pages': 'Adicionar Mais Páginas',
          'done': 'Concluído',
          'cancel': 'Cancelar',

          // Crop Editor
          'crop_editor': 'Editor de Corte',
          'crop': 'Cortar',
          'rotate': 'Girar',
          'apply': 'Aplicar',

          // Filters
          'filters': 'Filtros',
          'original': 'Original',
          'black_white': 'Preto e Branco',
          'grayscale': 'Escala de Cinza',
          'high_contrast': 'Alto Contraste',
          'magic_color': 'Cor Mágica',

          // Documents
          'documents': 'Documentos',
          'search': 'Pesquisar',
          'sort_by': 'Ordenar Por',
          'date': 'Data',
          'name': 'Nome',
          'size': 'Tamanho',
          'all_documents': 'Todos os Documentos',
          'favorites': 'Favoritos',
          'rename': 'Renomear',
          'delete': 'Excluir',
          'share': 'Compartilhar',
          'move_to_folder': 'Mover para Pasta',

          // PDF Generation
          'generate_pdf': 'Gerar PDF',
          'pdf_quality': 'Qualidade do PDF',
          'high': 'Alta',
          'medium': 'Média',
          'low': 'Baixa',
          'folder': 'Pasta',
          'generate': 'Gerar',

          // PDF Viewer
          'pdf_viewer': 'Visualizador de PDF',
          'page': 'Página',
          'of': 'de',
          'zoom_in': 'Ampliar',
          'zoom_out': 'Reduzir',

          // Signature
          'signature': 'Assinatura',
          'draw_signature': 'Desenhar Assinatura',
          'saved_signatures': 'Assinaturas Salvas',
          'clear': 'Limpar',
          'save': 'Salvar',

          // Settings
          'settings': 'Configurações',
          'language': 'Idioma',
          'app_language': 'Idioma do Aplicativo',
          'choose_language': 'Escolha seu idioma preferido',
          'about': 'Sobre',
          'privacy_policy': 'Política de Privacidade',
          'terms_and_conditions': 'Termos e Condições',
          'rate_app': 'Avaliar Aplicativo',
          'app_version': 'Versão do Aplicativo',
          'danger_zone': 'Zona de Perigo',
          'clear_all_data': 'Limpar Todos os Dados',

          // Common
          'ok': 'OK',
          'yes': 'Sim',
          'no': 'Não',
          'confirm': 'Confirmar',
          'loading': 'Carregando...',
          'error': 'Erro',
          'could_not_open_privacy_policy':
              'Não foi possível abrir a Política de Privacidade',
          'could_not_open_terms':
              'Não foi possível abrir os Termos e Condições',
          'could_not_open_store': 'Não foi possível abrir a App Store',
          'success': 'Sucesso',
          'warning': 'Aviso',
        },
        'ar_SA': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'مسح',
          'total_documents': 'إجمالي المستندات',
          'total_pages': 'إجمالي الصفحات',
          'recent_documents': 'المستندات الأخيرة',
          'no_documents': 'لا توجد مستندات بعد',
          'start_scanning': 'ابدأ المسح لإنشاء مستندك الأول',
          'quick_actions': 'إجراءات سريعة',
          'my_documents': 'مستنداتي',
          'signatures': 'التوقيعات',

          // Scanner
          'scanner': 'الماسح الضوئي',
          'capture': 'التقاط',
          'gallery': 'المعرض',
          'flash': 'الفلاش',
          'switch_camera': 'تبديل الكاميرا',
          'document_name': 'اسم المستند',
          'add_more_pages': 'إضافة المزيد من الصفحات',
          'done': 'تم',
          'cancel': 'إلغاء',

          // Crop Editor
          'crop_editor': 'محرر القص',
          'crop': 'قص',
          'rotate': 'تدوير',
          'apply': 'تطبيق',

          // Filters
          'filters': 'المرشحات',
          'original': 'الأصلي',
          'black_white': 'أبيض وأسود',
          'grayscale': 'تدرج الرمادي',
          'high_contrast': 'تباين عالي',
          'magic_color': 'لون سحري',

          // Documents
          'documents': 'المستندات',
          'search': 'بحث',
          'sort_by': 'ترتيب حسب',
          'date': 'التاريخ',
          'name': 'الاسم',
          'size': 'الحجم',
          'all_documents': 'كل المستندات',
          'favorites': 'المفضلة',
          'rename': 'إعادة تسمية',
          'delete': 'حذف',
          'share': 'مشاركة',
          'move_to_folder': 'نقل إلى المجلد',

          // PDF Generation
          'generate_pdf': 'إنشاء PDF',
          'pdf_quality': 'جودة PDF',
          'high': 'عالية',
          'medium': 'متوسطة',
          'low': 'منخفضة',
          'folder': 'المجلد',
          'generate': 'إنشاء',

          // PDF Viewer
          'pdf_viewer': 'عارض PDF',
          'page': 'صفحة',
          'of': 'من',
          'zoom_in': 'تكبير',
          'zoom_out': 'تصغير',

          // Signature
          'signature': 'التوقيع',
          'draw_signature': 'رسم التوقيع',
          'saved_signatures': 'التوقيعات المحفوظة',
          'clear': 'مسح',
          'save': 'حفظ',

          // Settings
          'settings': 'الإعدادات',
          'language': 'اللغة',
          'app_language': 'لغة التطبيق',
          'choose_language': 'اختر لغتك المفضلة',
          'about': 'حول',
          'privacy_policy': 'سياسة الخصوصية',
          'terms_and_conditions': 'الشروط والأحكام',
          'rate_app': 'تقييم التطبيق',
          'app_version': 'إصدار التطبيق',
          'danger_zone': 'منطقة الخطر',
          'clear_all_data': 'مسح جميع البيانات',

          // Common
          'ok': 'موافق',
          'yes': 'نعم',
          'no': 'لا',
          'confirm': 'تأكيد',
          'loading': 'جاري التحميل...',
          'error': 'خطأ',
          'could_not_open_privacy_policy': 'لا يمكن فتح سياسة الخصوصية',
          'could_not_open_terms': 'لا يمكن فتح الشروط والأحكام',
          'could_not_open_store': 'لا يمكن فتح متجر التطبيقات',
          'success': 'نجاح',
          'warning': 'تحذير',
        },
        'zh_CN': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': '扫描',
          'total_documents': '总文档数',
          'total_pages': '总页数',
          'recent_documents': '最近文档',
          'no_documents': '暂无文档',
          'start_scanning': '开始扫描以创建您的第一个文档',
          'quick_actions': '快速操作',
          'my_documents': '我的文档',
          'signatures': '签名',

          // Scanner
          'scanner': '扫描仪',
          'capture': '捕获',
          'gallery': '图库',
          'flash': '闪光灯',
          'switch_camera': '切换相机',
          'document_name': '文档名称',
          'add_more_pages': '添加更多页面',
          'done': '完成',
          'cancel': '取消',

          // Crop Editor
          'crop_editor': '裁剪编辑器',
          'crop': '裁剪',
          'rotate': '旋转',
          'apply': '应用',

          // Filters
          'filters': '滤镜',
          'original': '原始',
          'black_white': '黑白',
          'grayscale': '灰度',
          'high_contrast': '高对比度',
          'magic_color': '魔术颜色',

          // Documents
          'documents': '文档',
          'search': '搜索',
          'sort_by': '排序方式',
          'date': '日期',
          'name': '名称',
          'size': '大小',
          'all_documents': '所有文档',
          'favorites': '收藏',
          'rename': '重命名',
          'delete': '删除',
          'share': '分享',
          'move_to_folder': '移动到文件夹',

          // PDF Generation
          'generate_pdf': '生成 PDF',
          'pdf_quality': 'PDF 质量',
          'high': '高',
          'medium': '中',
          'low': '低',
          'folder': '文件夹',
          'generate': '生成',

          // PDF Viewer
          'pdf_viewer': 'PDF 查看器',
          'page': '页',
          'of': '共',
          'zoom_in': '放大',
          'zoom_out': '缩小',

          // Signature
          'signature': '签名',
          'draw_signature': '绘制签名',
          'saved_signatures': '已保存的签名',
          'clear': '清除',
          'save': '保存',

          // Settings
          'settings': '设置',
          'language': '语言',
          'app_language': '应用语言',
          'choose_language': '选择您的首选语言',
          'about': '关于',
          'privacy_policy': '隐私政策',
          'terms_and_conditions': '条款和条件',
          'rate_app': '评价应用',
          'app_version': '应用版本',
          'danger_zone': '危险区',
          'clear_all_data': '清除所有数据',

          // Common
          'ok': '确定',
          'yes': '是',
          'no': '否',
          'confirm': '确认',
          'loading': '加载中...',
          'error': '错误',
          'could_not_open_privacy_policy': '无法打开隐私政策',
          'could_not_open_terms': '无法打开条款和条件',
          'could_not_open_store': '无法打开应用商店',
          'success': '成功',
          'warning': '警告',
        },
        'ja_JP': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'スキャン',
          'total_documents': '総ドキュメント数',
          'total_pages': '総ページ数',
          'recent_documents': '最近のドキュメント',
          'no_documents': 'まだドキュメントがありません',
          'start_scanning': '最初のドキュメントを作成するにはスキャンを開始してください',
          'quick_actions': 'クイックアクション',
          'my_documents': 'マイドキュメント',
          'signatures': '署名',

          // Scanner
          'scanner': 'スキャナー',
          'capture': 'キャプチャ',
          'gallery': 'ギャラリー',
          'flash': 'フラッシュ',
          'switch_camera': 'カメラ切替',
          'document_name': 'ドキュメント名',
          'add_more_pages': 'ページを追加',
          'done': '完了',
          'cancel': 'キャンセル',

          // Crop Editor
          'crop_editor': 'クロップエディター',
          'crop': 'トリミング',
          'rotate': '回転',
          'apply': '適用',

          // Filters
          'filters': 'フィルター',
          'original': 'オリジナル',
          'black_white': '白黒',
          'grayscale': 'グレースケール',
          'high_contrast': 'ハイコントラスト',
          'magic_color': 'マジックカラー',

          // Documents
          'documents': 'ドキュメント',
          'search': '検索',
          'sort_by': '並べ替え',
          'date': '日付',
          'name': '名前',
          'size': 'サイズ',
          'all_documents': 'すべてのドキュメント',
          'favorites': 'お気に入り',
          'rename': '名前を変更',
          'delete': '削除',
          'share': '共有',
          'move_to_folder': 'フォルダに移動',

          // PDF Generation
          'generate_pdf': 'PDF生成',
          'pdf_quality': 'PDF品質',
          'high': '高',
          'medium': '中',
          'low': '低',
          'folder': 'フォルダ',
          'generate': '生成',

          // PDF Viewer
          'pdf_viewer': 'PDFビューア',
          'page': 'ページ',
          'of': '/  ',
          'zoom_in': '拡大',
          'zoom_out': '縮小',

          // Signature
          'signature': '署名',
          'draw_signature': '署名を描く',
          'saved_signatures': '保存された署名',
          'clear': 'クリア',
          'save': '保存',

          // Settings
          'settings': '設定',
          'language': '言語',
          'app_language': 'アプリの言語',
          'choose_language': '希望する言語を選択してください',
          'about': '情報',
          'privacy_policy': 'プライバシーポリシー',
          'terms_and_conditions': '利用規約',
          'rate_app': 'アプリを評価',
          'app_version': 'アプリのバージョン',
          'danger_zone': '危険ゾーン',
          'clear_all_data': 'すべてのデータを削除',

          // Common
          'ok': 'OK',
          'yes': 'はい',
          'no': 'いいえ',
          'confirm': '確認',
          'loading': '読み込み中...',
          'error': 'エラー',
          'could_not_open_privacy_policy': 'プライバシーポリシーを開けませんでした',
          'could_not_open_terms': '利用規約を開けませんでした',
          'could_not_open_store': 'アプリストアを開けませんでした',
          'success': '成功',
          'warning': '警告',
        },
        'hi_IN': {
          // Home Screen
          'app_name': 'DocSnap',
          'scan': 'स्कैन',
          'total_documents': 'कुल दस्तावेज़',
          'total_pages': 'कुल पृष्ठ',
          'recent_documents': 'हाल के दस्तावेज़',
          'no_documents': 'अभी तक कोई दस्तावेज़ नहीं',
          'start_scanning':
              'अपना पहला दस्तावेज़ बनाने के लिए स्कैनिंग शुरू करें',
          'quick_actions': 'त्वरित कार्य',
          'my_documents': 'मेरे दस्तावेज़',
          'signatures': 'हस्ताक्षर',

          // Scanner
          'scanner': 'स्कैनर',
          'capture': 'कैप्चर',
          'gallery': 'गैलरी',
          'flash': 'फ़्लैश',
          'switch_camera': 'कैमरा बदलें',
          'document_name': 'दस्तावेज़ का नाम',
          'add_more_pages': 'अधिक पृष्ठ जोड़ें',
          'done': 'पूर्ण',
          'cancel': 'रद्द करें',

          // Crop Editor
          'crop_editor': 'क्रॉप संपादक',
          'crop': 'क्रॉप',
          'rotate': 'घुमाएं',
          'apply': 'लागू करें',

          // Filters
          'filters': 'फ़िल्टर',
          'original': 'मूल',
          'black_white': 'श्वेत और श्याम',
          'grayscale': 'ग्रेस्केल',
          'high_contrast': 'उच्च कंट्रास्ट',
          'magic_color': 'जादुई रंग',

          // Documents
          'documents': 'दस्तावेज़',
          'search': 'खोजें',
          'sort_by': 'इसके अनुसार क्रमबद्ध करें',
          'date': 'तारीख',
          'name': 'नाम',
          'size': 'आकार',
          'all_documents': 'सभी दस्तावेज़',
          'favorites': 'पसंदीदा',
          'rename': 'नाम बदलें',
          'delete': 'हटाएं',
          'share': 'साझा करें',
          'move_to_folder': 'फ़ोल्डर में ले जाएं',

          // PDF Generation
          'generate_pdf': 'PDF जनरेट करें',
          'pdf_quality': 'PDF गुणवत्ता',
          'high': 'उच्च',
          'medium': 'मध्यम',
          'low': 'निम्न',
          'folder': 'फ़ोल्डर',
          'generate': 'जनरेट करें',

          // PDF Viewer
          'pdf_viewer': 'PDF व्यूअर',
          'page': 'पृष्ठ',
          'of': 'का',
          'zoom_in': 'ज़ूम इन',
          'zoom_out': 'ज़ूम आउट',

          // Signature
          'signature': 'हस्ताक्षर',
          'draw_signature': 'हस्ताक्षर बनाएं',
          'saved_signatures': 'सहेजे गए हस्ताक्षर',
          'clear': 'साफ़ करें',
          'save': 'सहेजें',

          // Settings
          'settings': 'सेटिंग्स',
          'language': 'भाषा',
          'app_language': 'ऐप की भाषा',
          'choose_language': 'अपनी पसंदीदा भाषा चुनें',
          'about': 'के बारे में',
          'privacy_policy': 'गोपनीयता नीति',
          'terms_and_conditions': 'नियम और शर्तें',
          'rate_app': 'ऐप को रेट करें',
          'app_version': 'ऐप संस्करण',
          'danger_zone': 'खतरनाक क्षेत्र',
          'clear_all_data': 'सभी डेटा साफ़ करें',

          // Common
          'ok': 'ठीक है',
          'yes': 'हाँ',
          'no': 'नहीं',
          'confirm': 'पुष्टि करें',
          'loading': 'लोड हो रहा है...',
          'error': 'त्रुटि',
          'could_not_open_privacy_policy': 'गोपनीयता नीति नहीं खोली जा सकी',
          'could_not_open_terms': 'नियम और शर्तें नहीं खोली जा सकीं',
          'could_not_open_store': 'ऐप स्टोर नहीं खोला जा सका',
          'success': 'सफलता',
          'warning': 'चेतावनी',
        },
      };
}
