class UserModel {
  final String id;
  final String userName;
  final String email;
  final String imageProfile;

  UserModel({
    required this.id,
    required this.userName,
    required this.email,
    required this.imageProfile,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userName': userName,
      'email': email,
      'imageProfile': imageProfile,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      userName: map['userName'] ?? '',
      email: map['email'] ?? '',
      imageProfile: map['imageProfile'] ?? '',
    );
  }
}
