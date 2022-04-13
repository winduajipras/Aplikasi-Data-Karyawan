class UserAppsReference {
  UserAppsReference(
      this.role, this.email, this.id, this.nama, this.password, this.avatarUrl);
  final String role;
  final String email;
  final int id;
  final String nama;
  final String password;
  final String avatarUrl;

  factory UserAppsReference.fromMap(Map<String, dynamic> data) {
    if (data == null) {
      return null;
    }

    final String role = data['role'];
    final String email = data['email'];
    final int id = data['id'];
    final String nama = data['nama'];
    final String password = data['password'];
    final String avatarUrl = data['avatarUrl'];

    if (role == null ||
        email == null ||
        id == null ||
        nama == null ||
        password == null ||
        avatarUrl == null) {
      return null;
    }
    return UserAppsReference(role, email, id, nama, password, avatarUrl);
  }

  Map<String, dynamic> toMap() {
    return {
      'role': role,
      'email': email,
      'id': id,
      'nama': nama,
      'password': password,
      'avatarUrl': avatarUrl,
    };
  }

  Map<String, dynamic> toMapAvatarOnly() {
    return {
      'avatarUrl': avatarUrl,
    };
  }

  Map<String, dynamic> toMapPasswordOnly() {
    return {
      'password': password,
    };
  }
}
