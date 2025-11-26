import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final chatServiceProvider = Provider((ref) => ChatService());

final userChatsProvider = StreamProvider<List<ChatModel>>((ref) {
  final service = ref.watch(chatServiceProvider);
  return service.getUserChats();
});

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının sohbetlerini getir
  Stream<List<ChatModel>> getUserChats() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => ChatModel.fromFirestore(doc))
            .toList());
  }

  // Yeni sohbet oluştur
  Future<String> createChat({required String title}) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final docRef = await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .add({
      'title': title,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    return docRef.id;
  }

  // Sohbet sil
  Future<void> deleteChat(String chatId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // Mesaj ekle
  Future<void> addMessage({
    required String chatId,
    required String content,
    required bool isUser,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add({
      'content': content,
      'isUser': isUser,
      'timestamp': FieldValue.serverTimestamp(),
    });

    // Sohbet güncelleme zamanını güncelle
    await _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .update({
      'updatedAt': FieldValue.serverTimestamp(),
      'title': content.length > 30 ? '${content.substring(0, 30)}...' : content,
    });
  }

  // Sohbet mesajlarını getir
  Stream<List<MessageModel>> getChatMessages(String chatId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => MessageModel.fromFirestore(doc))
            .toList());
  }
}

class ChatModel {
  final String id;
  final String title;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ChatModel({
    required this.id,
    required this.title,
    this.createdAt,
    this.updatedAt,
  });

  factory ChatModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatModel(
      id: doc.id,
      title: data['title'] ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}

class MessageModel {
  final String id;
  final String content;
  final bool isUser;
  final DateTime? timestamp;

  MessageModel({
    required this.id,
    required this.content,
    required this.isUser,
    this.timestamp,
  });

  factory MessageModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return MessageModel(
      id: doc.id,
      content: data['content'] ?? '',
      isUser: data['isUser'] ?? false,
      timestamp: (data['timestamp'] as Timestamp?)?.toDate(),
    );
  }
}
