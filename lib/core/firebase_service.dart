import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> saveUserData({
    required String name,
    required String email,
    required String password,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final userDoc = await userRef.get();

      if (!userDoc.exists) {
        await userRef.set({
          'name': name,
          'email': email,
          'password': password,
          'uid': user.uid,
        });
      }
    }
  }

  Future<void> saveQuizResult({
    required int correctAnswers,
    required int totalQuestions,
    required String category,
  }) async {
    final user = _auth.currentUser;
    if (user != null) {
      final userRef = _firestore.collection('users').doc(user.uid);
      final resultsRef = userRef.collection('results');

      final existing = await resultsRef
          .where('category', isEqualTo: category)
          .limit(1)
          .get();

      if (existing.docs.isNotEmpty) {
        final doc = existing.docs.first;
        final oldData = doc.data();

        final updatedCorrect =
            (oldData['correctAnswers'] ?? 0) + correctAnswers;
        final updatedTotal = (oldData['totalQuestions'] ?? 0) + totalQuestions;

        await doc.reference.update({
          'correctAnswers': updatedCorrect,
          'totalQuestions': updatedTotal,
          'timestamp': FieldValue.serverTimestamp(),
        });
      } else {
        await resultsRef.add({
          'correctAnswers': correctAnswers,
          'totalQuestions': totalQuestions,
          'category': category,
          'timestamp': FieldValue.serverTimestamp(),
        });
      }
    }
  }
}
