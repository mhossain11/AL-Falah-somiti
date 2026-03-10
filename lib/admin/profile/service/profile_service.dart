import 'package:cloud_firestore/cloud_firestore.dart';
import '../model/profile_model.dart';

class ProfileService{
  final _firestore = FirebaseFirestore.instance;

  Future<ProfileModel?> getUserById(String userId) async {
    final doc = await _firestore.collection('users').doc(userId).get();
    if (doc.exists) {
      return ProfileModel.fromFirestore(doc);
    } else {
      return null;
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await _firestore.collection('users').doc(userId).update(data);
  }
}