class User {
  final int id;
  final String username;

  User({required this.id, required this.username});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: int.parse(map['user_id'].toString()),
      username: map['username'] ?? '',
    );
  }
}
