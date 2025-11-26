import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/ai_service.dart';
import '../core/i18n/app_localizations.dart';

/// Hukuki AI Sohbet Ekranı - Google Gemini
class AILegalChatScreen extends StatefulWidget {
  const AILegalChatScreen({Key? key}) : super(key: key);

  @override
  State<AILegalChatScreen> createState() => _AILegalChatScreenState();
}

class _AILegalChatScreenState extends State<AILegalChatScreen> {
  final TextEditingController _questionController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  
  late GeminiLegalService _aiService;
  bool _isLoading = false;
  String _apiKey = '';
  DateTime? _lastQuestionTime;
  bool _welcomeMessageAdded = false;
  
  // Sohbet yönetimi
  List<ChatSession> _savedChats = [];
  String? _currentChatId;

  @override
  void initState() {
    super.initState();
    _initializeAI();
    _loadSavedChats();
    _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
  }
  
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // İlk açılışta hoş geldin mesajı ekle (sadece bir kez)
    if (!_welcomeMessageAdded && _messages.isEmpty) {
      _addWelcomeMessage(context);
      _welcomeMessageAdded = true;
    }
  }

  void _initializeAI() {
    // API anahtarı gizli - kod içinde saklı
    _apiKey = 'YOUR_GEMINI_API_KEY_HERE'; 
    
    if (_apiKey.isNotEmpty) {
      _aiService = GeminiLegalService(apiKey: _apiKey);
    }
  }

  void _addWelcomeMessage(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    _messages.add(
      ChatMessage(
        text: l10n.welcomeMessage,
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  // Yeni sohbet başlat
  void _startNewChat() {
    setState(() {
      _currentChatId = DateTime.now().millisecondsSinceEpoch.toString();
      _messages.clear();
      _lastQuestionTime = null;
    });
  }

  // Sohbetleri yükle
  Future<void> _loadSavedChats() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = prefs.getString('saved_chats') ?? '[]';
      final List<dynamic> chatsList = jsonDecode(chatsJson);
      
      setState(() {
        _savedChats = chatsList.map((json) => ChatSession.fromJson(json)).toList();
      });
    } catch (e) {
      print('Sohbetler yüklenemedi: $e');
    }
  }

  // Mevcut sohbeti kaydet
  Future<void> _saveCurrentChat(BuildContext context) async {
    // Sadece kullanıcı mesajı varsa kaydet (hoşgeldin mesajı hariç)
    final userMessageCount = _messages.where((msg) => msg.isUser).length;
    if (userMessageCount == 0) {
      return;
    }
    
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Mevcut sohbeti bul veya yeni ekle
      final existingIndex = _savedChats.indexWhere((chat) => chat.id == _currentChatId);
      
      final chatSession = ChatSession(
        id: _currentChatId!,
        title: _generateChatTitle(context),
        messages: List.from(_messages), // Deep copy
        lastUpdated: DateTime.now(),
      );
      
      if (existingIndex != -1) {
        _savedChats[existingIndex] = chatSession;
      } else {
        _savedChats.insert(0, chatSession);
      }
      
      // En fazla 50 sohbet sakla
      if (_savedChats.length > 50) {
        _savedChats = _savedChats.sublist(0, 50);
      }
      
      final chatsJson = jsonEncode(_savedChats.map((chat) => chat.toJson()).toList());
      await prefs.setString('saved_chats', chatsJson);
    } catch (e) {
      print('Sohbet kaydedilemedi: $e');
    }
  }

  // Sohbet başlığı oluştur (ilk kullanıcı mesajından)
  String _generateChatTitle(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final firstUserMessage = _messages.firstWhere(
      (msg) => msg.isUser && !msg.isFile,
      orElse: () => ChatMessage(text: l10n.newChat, isUser: true, timestamp: DateTime.now()),
    );
    
    String title = firstUserMessage.text;
    if (title.length > 40) {
      title = '${title.substring(0, 40)}...';
    }
    return title;
  }

  // Sohbeti yükle
  void _loadChat(ChatSession chat) {
    Navigator.pop(context); // Önce dialog'u kapat
    
    setState(() {
      _currentChatId = chat.id;
      _messages.clear();
      // Deep copy yaparak mesajları ekle
      for (var msg in chat.messages) {
        _messages.add(ChatMessage(
          text: msg.text,
          isUser: msg.isUser,
          timestamp: msg.timestamp,
          isFile: msg.isFile,
          isLoading: msg.isLoading,
        ));
      }
      _lastQuestionTime = null;
    });
    
    // Mesajları yükledikten sonra en alta scroll et
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollToBottom();
      }
    });
  }

  // Sohbeti sil
  Future<void> _deleteChat(String chatId) async {
    final l10n = AppLocalizations.of(context);
    try {
      setState(() {
        _savedChats.removeWhere((chat) => chat.id == chatId);
      });
      
      final prefs = await SharedPreferences.getInstance();
      final chatsJson = jsonEncode(_savedChats.map((chat) => chat.toJson()).toList());
      await prefs.setString('saved_chats', chatsJson);
      
      // Silinen sohbet aktif sohbet ise yeni sohbet başlat
      if (chatId == _currentChatId) {
        Navigator.pop(context); // Dialog'u kapat
        _startNewChat();
        _addWelcomeMessage(context); // Hoş geldin mesajı ekle
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatDeleted),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Sohbet silinemedi: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.chatDeleteFailed),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // Geçmiş sohbetleri göster
  void _showChatHistory() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF192633),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.history, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  l10n.chatHistory,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Expanded(
              child: _savedChats.isEmpty
                  ? Center(
                      child: Text(
                        l10n.noChatsYet,
                        style: const TextStyle(color: Colors.white60),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _savedChats.length,
                      itemBuilder: (context, index) {
                        final chat = _savedChats[index];
                        return Container(
                          margin: const EdgeInsets.only(bottom: 10),
                          decoration: BoxDecoration(
                            color: const Color(0xFF101922),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            leading: const CircleAvatar(
                              backgroundColor: Color(0xFF1173D4),
                              child: Icon(Icons.chat, color: Colors.white, size: 20),
                            ),
                            title: Text(
                              chat.title,
                              style: const TextStyle(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            subtitle: Text(
                              _formatDate(chat.lastUpdated, context),
                              style: const TextStyle(color: Colors.white60, fontSize: 12),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () async {
                                final l10nDialog = AppLocalizations.of(context);
                                final confirm = await showDialog<bool>(
                                  context: context,
                                  builder: (context) => AlertDialog(
                                    backgroundColor: const Color(0xFF192633),
                                    title: Text(
                                      l10nDialog.deleteChat,
                                      style: const TextStyle(color: Colors.white),
                                    ),
                                    content: Text(
                                      l10nDialog.deleteChatConfirmation,
                                      style: const TextStyle(color: Colors.white70),
                                    ),
                                    actions: [
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, false),
                                        child: Text(l10nDialog.cancel),
                                      ),
                                      TextButton(
                                        onPressed: () => Navigator.pop(context, true),
                                        child: Text(
                                          l10nDialog.delete,
                                          style: const TextStyle(color: Colors.red),
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                                
                                if (confirm == true) {
                                  await _deleteChat(chat.id);
                                }
                              },
                            ),
                            onTap: () => _loadChat(chat),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date, BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final now = DateTime.now();
    final diff = now.difference(date);
    
    if (diff.inMinutes < 1) return l10n.justNow;
    if (diff.inHours < 1) return l10n.minutesAgo(diff.inMinutes);
    if (diff.inDays < 1) return l10n.hoursAgo(diff.inHours);
    if (diff.inDays < 7) return l10n.daysAgo(diff.inDays);
    
    return '${date.day}/${date.month}/${date.year}';
  }

  void _addWelcomeMessage_OLD() {
    _messages.add(
      ChatMessage(
        text: 'Merhaba! Hukuk asistanınız olarak size nasıl yardımcı olabilirim? Bir dava dosyası yükleyebilir veya sorularınızı sorabilirsiniz.',
        isUser: false,
        timestamp: DateTime.now(),
      ),
    );
  }

  Future<void> _askQuestion() async {
    final question = _questionController.text.trim();
    
    if (question.isEmpty) return;

    // API key kontrolü - artık her zaman hazır
    if (_apiKey.isEmpty) {
      return;
    }

    // Rate limit kontrolü - 60 saniye aralık zorunlu
    if (_lastQuestionTime != null) {
      final timeSinceLastQuestion = DateTime.now().difference(_lastQuestionTime!);
      if (timeSinceLastQuestion.inSeconds < 60) {
        final waitTime = 60 - timeSinceLastQuestion.inSeconds;
        final l10n = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseWaitSeconds(waitTime)),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    // Kullanıcı mesajını ekle
    setState(() {
      _messages.add(
        ChatMessage(
          text: question,
          isUser: true,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = true;
    });

    _questionController.clear();
    _scrollToBottom();

    // Son soru zamanını güncelle
    _lastQuestionTime = DateTime.now();

    // Konuşma geçmişini hazırla (son 10 mesaj)
    List<Map<String, String>> chatHistory = [];
    for (var i = math.max(0, _messages.length - 10); i < _messages.length; i++) {
      final msg = _messages[i];
      if (!msg.isFile && !msg.isLoading) {
        chatHistory.add({
          'role': msg.isUser ? 'user' : 'model',
          'text': msg.text,
        });
      }
    }

    // AI'dan yanıt al
    final answer = await _aiService.askLegalQuestion(question, chatHistory: chatHistory);

    setState(() {
      _messages.add(
        ChatMessage(
          text: answer,
          isUser: false,
          timestamp: DateTime.now(),
        ),
      );
      _isLoading = false;
    });

    _scrollToBottom();
    _saveCurrentChat(context); // Sohbeti kaydet
  }

  void _scrollToBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _clearChat(BuildContext context) {
    setState(() {
      _messages.clear();
      _addWelcomeMessage(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF101922) : const Color(0xFFF6F7F8),
      appBar: AppBar(
        title: Text(l10n.aiAssistant, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: isDark ? const Color(0xFF101922) : Colors.white,
        foregroundColor: isDark ? Colors.white : Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.add),
          onPressed: () {
            _saveCurrentChat(context); // Mevcut sohbeti kaydet
            _startNewChat(); // Yeni sohbet başlat
            _addWelcomeMessage(context); // Hoş geldin mesajı ekle
          },
          tooltip: l10n.newChat,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.history),
            onPressed: _showChatHistory,
            tooltip: l10n.chatHistory,
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              key: ValueKey('chat_$_currentChatId'),
              controller: _scrollController,
              padding: const EdgeInsets.all(16),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                return _buildMessageBubble(_messages[index], isDark);
              },
            ),
          ),

          if (_isLoading)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: const Color(0xFF1173D4),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/tokmak.png',
                        width: 24,
                        height: 24,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: isDark ? const Color(0xFF192633) : Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.aiAssistant,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? const Color(0xFF92ADC9) : const Color(0xFF6B7280),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(l10n.analyzingQuestion),
                          const SizedBox(height: 8),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(999),
                            child: LinearProgressIndicator(
                              value: 0.45,
                              backgroundColor: const Color(0xFF1173D4).withOpacity(0.2),
                              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF1173D4)),
                              minHeight: 6,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),

          _buildInputArea(isDark),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message, bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        mainAxisAlignment: message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1173D4),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/tokmak.png',
                  width: 24,
                  height: 24,
                  fit: BoxFit.cover,
                ),
              ),
            ),
            const SizedBox(width: 12),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                Text(
                  message.isUser ? l10n.you : l10n.aiAssistant,
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? const Color(0xFF92ADC9) : const Color(0xFF6B7280),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: message.isUser 
                        ? const Color(0xFF1173D4) 
                        : (isDark ? const Color(0xFF192633) : Colors.white),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(message.isUser ? 12 : 0),
                      topRight: Radius.circular(message.isUser ? 0 : 12),
                      bottomLeft: const Radius.circular(12),
                      bottomRight: const Radius.circular(12),
                    ),
                  ),
                  child: message.isFile
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.insert_drive_file, size: 16, color: Colors.white),
                            const SizedBox(width: 8),
                            Text(
                              message.text,
                              style: const TextStyle(color: Colors.white, fontSize: 14),
                            ),
                          ],
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser 
                                ? Colors.white 
                                : (isDark ? Colors.white : Colors.black87),
                            fontSize: 14,
                          ),
                        ),
                ),
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 12),
            CircleAvatar(
              radius: 16,
              backgroundColor: const Color(0xFF1173D4),
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInputArea(bool isDark) {
    final l10n = AppLocalizations.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF101922) : Colors.white,
        border: Border(
          top: BorderSide(
            color: isDark ? const Color(0xFF192633).withOpacity(0.5) : const Color(0xFFF6F7F8),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF192633) : const Color(0xFFF6F7F8),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: TextField(
                  controller: _questionController,
                  decoration: InputDecoration(
                    hintText: l10n.typeMessage,
                    hintStyle: TextStyle(
                      color: isDark ? const Color(0xFF92ADC9) : const Color(0xFF6B7280),
                      fontSize: 14,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                  ),
                  style: TextStyle(
                    color: isDark ? Colors.white : Colors.black87,
                    fontSize: 14,
                  ),
                  maxLines: 5,
                  minLines: 1,
                  enabled: !_isLoading,
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _isLoading ? null : _askQuestion,
              child: Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF1173D4),
                  borderRadius: BorderRadius.circular(24),
                ),
                child: const Icon(
                  Icons.send,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _questionController.dispose();
    _scrollController.dispose();
    super.dispose();
  }
}

/// Sohbet mesajı modeli
class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;
  final bool isFile;
  final bool isLoading;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
    this.isFile = false,
    this.isLoading = false,
  });

  Map<String, dynamic> toJson() => {
    'text': text,
    'isUser': isUser,
    'timestamp': timestamp.toIso8601String(),
    'isFile': isFile,
    'isLoading': isLoading,
  };

  factory ChatMessage.fromJson(Map<String, dynamic> json) => ChatMessage(
    text: json['text'] ?? '',
    isUser: json['isUser'] ?? false,
    timestamp: DateTime.parse(json['timestamp']),
    isFile: json['isFile'] ?? false,
    isLoading: json['isLoading'] ?? false,
  );
}

/// Sohbet oturumu modeli
class ChatSession {
  final String id;
  final String title;
  final List<ChatMessage> messages;
  final DateTime lastUpdated;

  ChatSession({
    required this.id,
    required this.title,
    required this.messages,
    required this.lastUpdated,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'messages': messages.map((m) => m.toJson()).toList(),
    'lastUpdated': lastUpdated.toIso8601String(),
  };

  factory ChatSession.fromJson(Map<String, dynamic> json) => ChatSession(
    id: json['id'] ?? '',
    title: json['title'] ?? 'Yeni Sohbet',
    messages: (json['messages'] as List?)
        ?.map((m) => ChatMessage.fromJson(m))
        .toList() ?? [],
    lastUpdated: DateTime.parse(json['lastUpdated']),
  );
}
