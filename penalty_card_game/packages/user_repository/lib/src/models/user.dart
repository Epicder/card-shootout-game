import 'package:equatable/equatable.dart';
import '../entities/entities.dart';

class MyUser extends Equatable {
  final String userId;
  final String name;
  final String email;

  const MyUser({
    required this.userId,
    required this.name,
    required this.email,
  });

  static const empty = MyUser(
    userId: '',
    name: '',
    email: ''
    );

  MyUser copyWith({
    String? userId,
    String? name,
    String? email,
  }) {
    return MyUser(
      userId: userId ?? this.userId,
      name: name ?? this.name,
      email: email ?? this.email
    );
  }

  MyUserEntity toEntity() {
    return MyUserEntity(
      userId: userId,
      name: name,
      email: email,
    );
  }

  static MyUser fromEntity(MyUserEntity entity) {
    return MyUser(
      userId: entity.userId,
      name: entity.name,
      email: entity.email
    );
  }

  @override
  List<Object> get props => [userId, name, email];

}