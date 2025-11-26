import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final documentsServiceProvider = Provider((ref) => DocumentsService());

final userDocumentsProvider = StreamProvider<List<DocumentModel>>((ref) {
  final service = ref.watch(documentsServiceProvider);
  return service.getUserDocuments();
});

class DocumentsService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının belgelerini getir
  Stream<List<DocumentModel>> getUserDocuments() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => DocumentModel.fromFirestore(doc))
            .toList());
  }

  // Yeni belge ekle
  Future<void> addDocument({
    required String title,
    required String category,
    String? fileUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .add({
      'title': title,
      'category': category,
      'fileUrl': fileUrl,
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Belge sil
  Future<void> deleteDocument(String documentId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .doc(documentId)
        .delete();
  }

  // Belge güncelle
  Future<void> updateDocument({
    required String documentId,
    String? title,
    String? category,
    String? fileUrl,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final Map<String, dynamic> updateData = {
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (title != null) updateData['title'] = title;
    if (category != null) updateData['category'] = category;
    if (fileUrl != null) updateData['fileUrl'] = fileUrl;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('documents')
        .doc(documentId)
        .update(updateData);
  }
}

class DocumentModel {
  final String id;
  final String title;
  final String category;
  final String? fileUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  DocumentModel({
    required this.id,
    required this.title,
    required this.category,
    this.fileUrl,
    this.createdAt,
    this.updatedAt,
  });

  factory DocumentModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return DocumentModel(
      id: doc.id,
      title: data['title'] ?? '',
      category: data['category'] ?? '',
      fileUrl: data['fileUrl'],
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
    );
  }
}
