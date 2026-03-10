import 'package:cloud_firestore/cloud_firestore.dart';

class CreateIdService{
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String authId = 'QsJHPbgZMs6mGlIFdQQ5';

  // 🔹 Add Admin/User
  Future<String?> addUserId({
    required String role, // "admin" or "user"
    required String userId,
  }) async {
    final trimmedUserId = userId.trim();

    // 1️⃣ Check if user_id already exists
    final querySnapshot = await _firestore
        .collection('auth')
        .doc(authId)
        .collection(role)
        .where('user_id', isEqualTo: trimmedUserId)
        .get();

    if (querySnapshot.docs.isNotEmpty) {
      // Already exists
      return null; // ✅ allowed now
    }

    // 3️⃣ Otherwise, add new user_id
    final docRef = await _firestore
        .collection('auth')
        .doc(authId)
        .collection(role)
        .add({'user_id': trimmedUserId});

    print("User ID added successfully!");
    return docRef.id;
  }


  // 🔹 Update Admin/User
  Future<void> updateUserId({
    required String role,
    required String docId,
    required String newUserId,
  }) async {
    await _firestore
        .collection('auth')
        .doc(authId)
        .collection(role)
        .doc(docId.trim())
        .update({'user_id': newUserId.trim()});
  }


}