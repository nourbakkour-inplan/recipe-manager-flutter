import 'package:hive/hive.dart';

/// User model stored in Hive local database.
class User extends HiveObject {
  String id;
  String username;
  String passwordHash;
  DateTime createdAt;

  User({
    required this.id,
    required this.username,
    required this.passwordHash,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'id': id,
        'username': username,
        'passwordHash': passwordHash,
        'createdAt': createdAt.toIso8601String(),
      };

  factory User.fromMap(Map<dynamic, dynamic> map) => User(
        id: map['id'] as String,
        username: map['username'] as String,
        passwordHash: map['passwordHash'] as String,
        createdAt: DateTime.parse(map['createdAt'] as String),
      );
}

class UserAdapter extends TypeAdapter<User> {
  @override
  final int typeId = 0;

  @override
  User read(BinaryReader reader) => User.fromMap(reader.readMap());

  @override
  void write(BinaryWriter writer, User obj) => writer.writeMap(obj.toMap());
}
