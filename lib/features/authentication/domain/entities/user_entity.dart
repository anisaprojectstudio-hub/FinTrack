/// Entity murni domain — tidak tahu apa-apa tentang Firebase.
class UserEntity {
  final String uid;
  final String name;
  final String email;
  final String? photoUrl;

  const UserEntity({
    required this.uid,
    required this.name,
    required this.email,
    this.photoUrl,
  });
}
