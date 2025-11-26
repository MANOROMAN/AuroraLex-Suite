import 'package:flutter/material.dart';

class AppLocalizations {
  final Locale locale;

  AppLocalizations(this.locale);

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static final Map<String, Map<String, String>> _localizedValues = {
    'tr': {
      // Auth
      'welcome': 'Hoş Geldiniz',
      'email': 'E-posta',
      'password': 'Şifre',
      'login': 'Giriş Yap',
      'register': 'Kayıt Ol',
      'forgot_password': 'Şifremi Unuttum',
      'or_continue_with': 'veya devam et',
      'dont_have_account': 'Hesabınız yok mu?',
      'already_have_account': 'Zaten hesabınız var mı?',
      'sign_in_with_google': 'Google ile Giriş',
      'logout': 'Oturumu kapat',
      'logout_confirmation': 'Oturumu kapatmak istediğinizden emin misiniz?',
      'cancel': 'İptal',
      
      // Dashboard
      'overview': 'Genel Bakış',
      'case_tracker': 'Dava Takibi',
      'legal_dictionary': 'Sözlük',
      'ai_chat': 'AI Sohbet',
      'calendar': 'Takvim',
      'settings': 'Ayarlar',
      
      // Case Tracker
      'case_tracker': 'Dava Takip',
      'cases': 'Davalar',
      'my_cases': 'Davalarım',
      'add_case': 'Yeni Dava',
      'add_new_case': 'Yeni Dava Ekle',
      'case_title': 'Dava Başlığı',
      'case_number': 'Esas No',
      'court': 'Mahkeme',
      'next_hearing': 'Sonraki Duruşma',
      'select_date': 'Tarih Seç',
      'category': 'Kategori',
      'description': 'Açıklama',
      'status': 'Durum',
      'status_ongoing': 'Devam Ediyor',
      'status_won': 'Kazanıldı',
      'status_lost': 'Kaybedildi',
      'status_pending': 'Beklemede',
      'save': 'Kaydet',
      'update': 'Güncelle',
      'delete': 'Sil',
      'edit': 'Düzenle',
      'share': 'Paylaş',
      'preview': 'Önizle',
      'no_cases': 'Henüz dava eklenmedi',
      'add_first_case': 'İlk davanızı ekleyin',
      'case_added': 'Dava eklendi',
      'case_updated': 'Dava güncellendi',
      'case_deleted': 'Dava silindi',
      'delete_case_confirmation': 'Bu davayı silmek istediğinizden emin misiniz?',
      
      // Documents
      'documents': 'Belgeler',
      'add_document': 'Yeni Belge',
      'add_new_document': 'Yeni Belge Ekle',
      'document_title': 'Belge Başlığı',
      'select_file': 'Dosya Seç',
      'no_documents': 'Henüz belge eklenmedi',
      'add_first_document': 'İlk belgenizi ekleyin',
      'document_added': 'Belge eklendi',
      'document_updated': 'Belge güncellendi',
      'document_deleted': 'Belge silindi',
      'delete_document_confirmation': 'Bu belgeyi silmek istediğinizden emin misiniz?',
      'file_selected': 'Dosya Seçildi',
      'no_file_selected': 'Dosya Seçilmedi',
      
      // Document Categories
      'doc_category_hearing': 'Duruşma',
      'doc_category_analysis': 'Analiz',
      'doc_category_compliance': 'Uygunluk',
      'doc_category_documents': 'Belgeler',
      'doc_category_evidence': 'Delil',
      'doc_category_evidence_list': 'Delil Listesi',
      
      // Categories
      'criminal_law': 'Ceza Hukuku',
      'civil_law': 'Medeni Hukuk',
      'commercial_law': 'Ticaret Hukuku',
      'labor_law': 'İş Hukuku',
      'administrative_law': 'İdare Hukuku',
      'execution_bankruptcy_law': 'İcra İflas Hukuku',
      
      // Status
      'active': 'Aktif',
      'pending': 'Beklemede',
      'closed': 'Kapalı',
      'in_progress': 'Devam Ediyor',
      
      // Legal Dictionary
      'search_term': 'Hukuki terim ara...',
      'all_categories': 'Tümü',
      'criminal_law_category': 'Ceza Hukuku',
      'civil_law_category': 'Medeni Hukuk',
      'commercial_law_category': 'Ticaret Hukuku',
      'labor_law_category': 'İş Hukuku',
      'administrative_law_category': 'İdare Hukuku',
      'no_terms_found': 'Bu tarihte etkinlik bulunmuyor',
      
      // Calendar
      'add_event': 'Etkinlik Ekle',
      'new_event': 'Yeni Etkinlik',
      'edit_event': 'Etkinliği Düzenle',
      'delete_event': 'Etkinliği Sil',
      'event_title': 'Başlık',
      'event_description': 'Açıklama',
      'event_time': 'Saat',
      'select_color': 'Renk Seç',
      'no_events': 'Etkinlik Yok',
      'no_events_on_date': 'Bu tarihte etkinlik bulunmuyor',
      'todays_events': 'Bugünkü Etkinlikler',
      'selected_day_events': 'Seçili Gün Etkinlikleri',
      'event_added': 'Etkinlik eklendi',
      'event_updated': 'Etkinlik güncellendi',
      'event_deleted': 'Etkinlik silindi',
      'delete_event_confirmation': 'Bu etkinliği silmek istediğinizden emin misiniz?',
      'please_enter_title': 'Lütfen bir başlık girin',
      'reminder_on': 'Hatırlatıcıyı Kapat',
      'reminder_off': 'Hatırlatıcı Aç',
      
      // AI Chat
      'ask_anything': 'Hukuki bir soru sorun...',
      'send': 'Gönder',
      'ai_assistant': 'AI Asistanı',
      'start_conversation': 'Hukuki bir soru sorarak başlayın',
      'new_chat': 'Yeni Sohbet',
      'chat_history': 'Sohbet Geçmişi',
      'you': 'Siz',
      'no_chats_yet': 'Henüz kayıtlı sohbet yok',
      'type_message': 'Mesajınızı buraya yazın...',
      'analyzing_question': 'Sorunuz analiz ediliyor, lütfen bekleyin...',
      'delete_chat': 'Sohbeti Sil',
      'delete_chat_confirmation': 'Bu sohbeti silmek istediğinizden emin misiniz?',
      'chat_deleted': 'Sohbet silindi',
      'chat_delete_failed': 'Sohbet silinemedi',
      'welcome_message': 'Merhaba! Hukuk asistanınız olarak size nasıl yardımcı olabilirim? Sorularınızı sorabilirsiniz.',
      'please_wait_seconds': 'Lütfen {0} saniye bekleyin',
      'just_now': 'Az önce',
      'minutes_ago': '{0} dakika önce',
      'hours_ago': '{0} saat önce',
      'days_ago': '{0} gün önce',
      
      // Settings
      'profile': 'Profil',
      'appearance': 'Görünüm',
      'theme_mode': 'Tema modu',
      'language': 'Dil',
      'account': 'Hesap',
      'email_address': 'E-posta',
      'username': 'Kullanıcı Adı',
      'about': 'Hakkında',
      'version': 'Versiyon',
      'app_info': 'Uygulama Bilgisi',
      'app_description': 'AuroraLex Suite - Hukuki Belge Yönetim Sistemi',
      'system': 'Sistem',
      'light': 'Açık',
      'dark': 'Koyu',
      'turkish': 'Türkçe',
      'english': 'English',
      
      // Common
      'error': 'Bir hata oluştu',
      'loading': 'Yükleniyor...',
      'search': 'Ara',
      'filter': 'Filtrele',
      'sort': 'Sırala',
      'yes': 'Evet',
      'no': 'Hayır',
      'ok': 'Tamam',
      'close': 'Kapat',
      'back': 'Geri',
      'next': 'İleri',
      'done': 'Bitti',
      'please_fill_all_fields': 'Lütfen tüm alanları doldurun',
    },
    'en': {
      // Auth
      'welcome': 'Welcome',
      'email': 'Email',
      'password': 'Password',
      'login': 'Login',
      'register': 'Register',
      'forgot_password': 'Forgot Password',
      'or_continue_with': 'or continue with',
      'dont_have_account': "Don't have an account?",
      'already_have_account': 'Already have an account?',
      'sign_in_with_google': 'Sign in with Google',
      'logout': 'Logout',
      'logout_confirmation': 'Are you sure you want to logout?',
      'cancel': 'Cancel',
      
      // Dashboard
      'overview': 'Overview',
      'case_tracker': 'Case Tracker',
      'legal_dictionary': 'Dictionary',
      'ai_chat': 'AI Chat',
      'calendar': 'Calendar',
      'settings': 'Settings',
      
      // Case Tracker
      'cases': 'Cases',
      'my_cases': 'My Cases',
      'add_case': 'New Case',
      'add_new_case': 'Add New Case',
      'case_title': 'Case Title',
      'case_number': 'Case Number',
      'court': 'Court',
      'next_hearing': 'Next Hearing',
      'select_date': 'Select Date',
      'category': 'Category',
      'description': 'Description',
      'status': 'Status',
      'status_ongoing': 'Ongoing',
      'status_won': 'Won',
      'status_lost': 'Lost',
      'status_pending': 'Pending',
      'save': 'Save',
      'update': 'Update',
      'delete': 'Delete',
      'edit': 'Edit',
      'share': 'Share',
      'preview': 'Preview',
      'no_cases': 'No cases added yet',
      'add_first_case': 'Add your first case',
      'case_added': 'Case added',
      'case_updated': 'Case updated',
      'case_deleted': 'Case deleted',
      'delete_case_confirmation': 'Are you sure you want to delete this case?',
      
      // Documents
      'documents': 'Documents',
      'add_document': 'New Document',
      'add_new_document': 'Add New Document',
      'document_title': 'Document Title',
      'select_file': 'Select File',
      'no_documents': 'No documents added yet',
      'add_first_document': 'Add your first document',
      'document_added': 'Document added',
      'document_updated': 'Document updated',
      'document_deleted': 'Document deleted',
      'delete_document_confirmation': 'Are you sure you want to delete this document?',
      'file_selected': 'File Selected',
      'no_file_selected': 'No File Selected',
      
      // Document Categories
      'doc_category_hearing': 'Hearing',
      'doc_category_analysis': 'Analysis',
      'doc_category_compliance': 'Compliance',
      'doc_category_documents': 'Documents',
      'doc_category_evidence': 'Evidence',
      'doc_category_evidence_list': 'Evidence List',
      
      // Categories
      'criminal_law': 'Criminal Law',
      'civil_law': 'Civil Law',
      'commercial_law': 'Commercial Law',
      'labor_law': 'Labor Law',
      'administrative_law': 'Administrative Law',
      'execution_bankruptcy_law': 'Execution & Bankruptcy Law',
      
      // Status
      'active': 'Active',
      'pending': 'Pending',
      'closed': 'Closed',
      'in_progress': 'In Progress',
      
      // Legal Dictionary
      'search_term': 'Search legal term...',
      'all_categories': 'All',
      'criminal_law_category': 'Criminal Law',
      'civil_law_category': 'Civil Law',
      'commercial_law_category': 'Commercial Law',
      'labor_law_category': 'Labor Law',
      'administrative_law_category': 'Administrative Law',
      'no_terms_found': 'No events on this date',
      
      // Calendar
      'add_event': 'Add Event',
      'new_event': 'New Event',
      'edit_event': 'Edit Event',
      'delete_event': 'Delete Event',
      'event_title': 'Title',
      'event_description': 'Description',
      'event_time': 'Time',
      'select_color': 'Select Color',
      'no_events': 'No Events',
      'no_events_on_date': 'No events on this date',
      'todays_events': "Today's Events",
      'selected_day_events': 'Selected Day Events',
      'event_added': 'Event added',
      'event_updated': 'Event updated',
      'event_deleted': 'Event deleted',
      'delete_event_confirmation': 'Are you sure you want to delete this event?',
      'please_enter_title': 'Please enter a title',
      'reminder_on': 'Turn Off Reminder',
      'reminder_off': 'Turn On Reminder',
      
      // AI Chat
      'ask_anything': 'Ask a legal question...',
      'send': 'Send',
      'ai_assistant': 'AI Assistant',
      'start_conversation': 'Start by asking a legal question',
      'new_chat': 'New Chat',
      'chat_history': 'Chat History',
      'you': 'You',
      'no_chats_yet': 'No saved chats yet',
      'type_message': 'Type your message here...',
      'analyzing_question': 'Analyzing your question, please wait...',
      'delete_chat': 'Delete Chat',
      'delete_chat_confirmation': 'Are you sure you want to delete this chat?',
      'chat_deleted': 'Chat deleted',
      'chat_delete_failed': 'Failed to delete chat',
      'welcome_message': 'Hello! How can I assist you as your legal assistant? Feel free to ask your questions.',
      'please_wait_seconds': 'Please wait {0} seconds',
      'just_now': 'Just now',
      'minutes_ago': '{0} minutes ago',
      'hours_ago': '{0} hours ago',
      'days_ago': '{0} days ago',
      
      // Settings
      'profile': 'Profile',
      'appearance': 'Appearance',
      'theme_mode': 'Theme mode',
      'language': 'Language',
      'account': 'Account',
      'email_address': 'Email',
      'username': 'Username',
      'about': 'About',
      'version': 'Version',
      'app_info': 'App Info',
      'app_description': 'AuroraLex Suite - Legal Document Management System',
      'system': 'System',
      'light': 'Light',
      'dark': 'Dark',
      'turkish': 'Türkçe',
      'english': 'English',
      
      // Common
      'error': 'An error occurred',
      'loading': 'Loading...',
      'search': 'Search',
      'filter': 'Filter',
      'sort': 'Sort',
      'yes': 'Yes',
      'no': 'No',
      'ok': 'OK',
      'close': 'Close',
      'back': 'Back',
      'next': 'Next',
      'done': 'Done',
      'please_fill_all_fields': 'Please fill all fields',
    },
  };

  String translate(String key) {
    return _localizedValues[locale.languageCode]?[key] ?? key;
  }

  // Locale name for calendar and other widgets
  String get localeName => locale.languageCode;

  // Getter methods for easy access
  String get welcome => translate('welcome');
  String get email => translate('email');
  String get password => translate('password');
  String get login => translate('login');
  String get register => translate('register');
  String get forgotPassword => translate('forgot_password');
  String get orContinueWith => translate('or_continue_with');
  String get dontHaveAccount => translate('dont_have_account');
  String get alreadyHaveAccount => translate('already_have_account');
  String get signInWithGoogle => translate('sign_in_with_google');
  String get logout => translate('logout');
  String get logoutConfirmation => translate('logout_confirmation');
  String get cancel => translate('cancel');
  
  String get overview => translate('overview');
  String get caseTracker => translate('case_tracker');
  String get legalDictionary => translate('legal_dictionary');
  String get aiChat => translate('ai_chat');
  String get calendar => translate('calendar');
  String get settings => translate('settings');
  
  String get caseTrackerTitle => translate('case_tracker');
  String get cases => translate('cases');
  String get myCases => translate('my_cases');
  String get addCase => translate('add_case');
  String get addNewCase => translate('add_new_case');
  String get caseTitle => translate('case_title');
  String get caseNumber => translate('case_number');
  String get court => translate('court');
  String get nextHearing => translate('next_hearing');
  String get selectDate => translate('select_date');
  String get category => translate('category');
  String get description => translate('description');
  String get status => translate('status');
  String get statusOngoing => translate('status_ongoing');
  String get statusWon => translate('status_won');
  String get statusLost => translate('status_lost');
  String get statusPending => translate('status_pending');
  String get save => translate('save');
  String get update => translate('update');
  String get delete => translate('delete');
  String get edit => translate('edit');
  String get share => translate('share');
  String get preview => translate('preview');
  String get noCases => translate('no_cases');
  String get addFirstCase => translate('add_first_case');
  String get caseAdded => translate('case_added');
  String get caseUpdated => translate('case_updated');
  String get caseDeleted => translate('case_deleted');
  String get deleteCaseConfirmation => translate('delete_case_confirmation');
  
  String get documents => translate('documents');
  String get addDocument => translate('add_document');
  String get addNewDocument => translate('add_new_document');
  String get documentTitle => translate('document_title');
  String get selectFile => translate('select_file');
  String get noDocuments => translate('no_documents');
  String get addFirstDocument => translate('add_first_document');
  String get documentAdded => translate('document_added');
  String get documentUpdated => translate('document_updated');
  String get documentDeleted => translate('document_deleted');
  String get deleteDocumentConfirmation => translate('delete_document_confirmation');
  String get fileSelected => translate('file_selected');
  String get noFileSelected => translate('no_file_selected');
  
  String get docCategoryHearing => translate('doc_category_hearing');
  String get docCategoryAnalysis => translate('doc_category_analysis');
  String get docCategoryCompliance => translate('doc_category_compliance');
  String get docCategoryDocuments => translate('doc_category_documents');
  String get docCategoryEvidence => translate('doc_category_evidence');
  String get docCategoryEvidenceList => translate('doc_category_evidence_list');
  
  String get criminalLaw => translate('criminal_law');
  String get civilLaw => translate('civil_law');
  String get commercialLaw => translate('commercial_law');
  String get laborLaw => translate('labor_law');
  String get administrativeLaw => translate('administrative_law');
  String get executionBankruptcyLaw => translate('execution_bankruptcy_law');
  
  String get active => translate('active');
  String get pending => translate('pending');
  String get closed => translate('closed');
  String get inProgress => translate('in_progress');
  
  String get searchTerm => translate('search_term');
  String get allCategories => translate('all_categories');
  String get criminalLawCategory => translate('criminal_law_category');
  String get civilLawCategory => translate('civil_law_category');
  String get commercialLawCategory => translate('commercial_law_category');
  String get laborLawCategory => translate('labor_law_category');
  String get administrativeLawCategory => translate('administrative_law_category');
  String get noTermsFound => translate('no_terms_found');
  
  String get addEvent => translate('add_event');
  String get newEvent => translate('new_event');
  String get editEvent => translate('edit_event');
  String get deleteEvent => translate('delete_event');
  String get eventTitle => translate('event_title');
  String get eventDescription => translate('event_description');
  String get eventTime => translate('event_time');
  String get selectColor => translate('select_color');
  String get noEvents => translate('no_events');
  String get noEventsOnDate => translate('no_events_on_date');
  String get todaysEvents => translate('todays_events');
  String get selectedDayEvents => translate('selected_day_events');
  String get eventAdded => translate('event_added');
  String get eventUpdated => translate('event_updated');
  String get eventDeleted => translate('event_deleted');
  String get deleteEventConfirmation => translate('delete_event_confirmation');
  String get pleaseEnterTitle => translate('please_enter_title');
  String get reminderOn => translate('reminder_on');
  String get reminderOff => translate('reminder_off');
  
  String get askAnything => translate('ask_anything');
  String get send => translate('send');
  String get aiAssistant => translate('ai_assistant');
  String get startConversation => translate('start_conversation');
  String get newChat => translate('new_chat');
  String get chatHistory => translate('chat_history');
  String get you => translate('you');
  String get noChatsYet => translate('no_chats_yet');
  String get typeMessage => translate('type_message');
  String get analyzingQuestion => translate('analyzing_question');
  String get deleteChat => translate('delete_chat');
  String get deleteChatConfirmation => translate('delete_chat_confirmation');
  String get chatDeleted => translate('chat_deleted');
  String get chatDeleteFailed => translate('chat_delete_failed');
  String get welcomeMessage => translate('welcome_message');
  String pleaseWaitSeconds(int seconds) => translate('please_wait_seconds').replaceAll('{0}', seconds.toString());
  String get justNow => translate('just_now');
  String minutesAgo(int minutes) => translate('minutes_ago').replaceAll('{0}', minutes.toString());
  String hoursAgo(int hours) => translate('hours_ago').replaceAll('{0}', hours.toString());
  String daysAgo(int days) => translate('days_ago').replaceAll('{0}', days.toString());
  
  String get profile => translate('profile');
  String get appearance => translate('appearance');
  String get themeMode => translate('theme_mode');
  String get language => translate('language');
  String get account => translate('account');
  String get emailAddress => translate('email_address');
  String get username => translate('username');
  String get about => translate('about');
  String get version => translate('version');
  String get appInfo => translate('app_info');
  String get appDescription => translate('app_description');
  String get system => translate('system');
  String get light => translate('light');
  String get dark => translate('dark');
  String get turkish => translate('turkish');
  String get english => translate('english');
  
  String get error => translate('error');
  String get loading => translate('loading');
  String get search => translate('search');
  String get filter => translate('filter');
  String get sort => translate('sort');
  String get yes => translate('yes');
  String get no => translate('no');
  String get ok => translate('ok');
  String get close => translate('close');
  String get back => translate('back');
  String get next => translate('next');
  String get done => translate('done');
  String get pleaseFillAllFields => translate('please_fill_all_fields');
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['tr', 'en'].contains(locale.languageCode);
  }

  @override
  Future<AppLocalizations> load(Locale locale) async {
    return AppLocalizations(locale);
  }

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
