import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final String uid;
  final String email;
  final String name;
  final List<String> role; // List for future flexibility
  final DateTime createdAt;
  final String password;

  UserModel({
    required this.uid,
    required this.email,
    required this.name,
    required this.role,
    required this.createdAt,
    required this.password,
  });

  // factory to cretae user model as firesotre documnt
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      role: List<String>.from(map['role'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      password: map['password'],
    );
  }

  // tomap of user mode
  Map<String, dynamic> toMap() {
    return {
      "uid": uid,
      "email": email,
      "name": name,
      "role": role,
      "createdAt": Timestamp.fromDate(createdAt),
      "password": password,
    };
  }


  // get user data
  Future<UserModel?> getUserData(String uid) async {
  DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();

  if (doc.exists) {
    return UserModel.fromMap(doc.data() as Map<String, dynamic>);
  } else {
    return null;
  }
}

}
