import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final casesServiceProvider = Provider((ref) => CasesService());

final userCasesProvider = StreamProvider<List<CaseModel>>((ref) {
  final service = ref.watch(casesServiceProvider);
  return service.getUserCases();
});

class CasesService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Kullanıcının davalarını getir
  Stream<List<CaseModel>> getUserCases() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('cases')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CaseModel.fromFirestore(doc))
            .toList());
  }

  // Yeni dava ekle
  Future<void> addCase({
    required String title,
    required String caseNumber,
    required String court,
    required String status,
    required DateTime nextHearing,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cases')
        .add({
      'title': title,
      'caseNumber': caseNumber,
      'court': court,
      'status': status,
      'nextHearing': Timestamp.fromDate(nextHearing),
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Dava sil
  Future<void> deleteCase(String caseId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('cases')
        .doc(caseId)
        .delete();
  }
}

class CaseModel {
  final String id;
  final String title;
  final String caseNumber;
  final String court;
  final String status;
  final DateTime? nextHearing;
  final DateTime? createdAt;

  CaseModel({
    required this.id,
    required this.title,
    required this.caseNumber,
    required this.court,
    required this.status,
    this.nextHearing,
    this.createdAt,
  });

  factory CaseModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return CaseModel(
      id: doc.id,
      title: data['title'] ?? '',
      caseNumber: data['caseNumber'] ?? '',
      court: data['court'] ?? '',
      status: data['status'] ?? '',
      nextHearing: (data['nextHearing'] as Timestamp?)?.toDate(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate(),
    );
  }
}
