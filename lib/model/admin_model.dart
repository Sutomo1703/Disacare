// ignore_for_file: unnecessary_this

class AdminModel {
  String? uid;
  String? username;
  String? usernameholder;
  String? email;
  String? alamat;
  String? password;
  String? repassword;
  String? gambar;
  String? role;
  String? gelar;
  int exp;
  List<String>? titles;

  AdminModel({
    this.uid,
    this.username,
    this.usernameholder,
    this.email,
    this.alamat,
    this.password,
    this.repassword,
    this.gambar,
    this.role,
    this.gelar,
    int? exp,
    List<String>? titles,
  })  : this.exp = exp ?? 0, 
        this.titles = titles ?? ['warga'];

  // Receiving data from server
  factory AdminModel.fromMap(map) {
    return AdminModel(
      uid: map['uid'],
      username: map['username'],
      usernameholder: map['username_holder'],
      email: map['email'],
      alamat: map['alamat'],
      password: map['password'],
      repassword: map['ulang kata sandi'],
      gambar: map['gambar'],
      role: map['role'],
      gelar: map['gelar'],
      exp: map['exp'] ?? 0,
      titles: map['titles'] != null ? List<String>.from(map['titles']) : [],
    );
  }

  // Sending data to the server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'username_holder': usernameholder,
      'email': email,
      'alamat': alamat,
      'password': password,
      'repassword': repassword,
      'gambar': gambar,
      'role': 'admin',
      'gelar': 'warga',
      'exp': exp,
      'titles': titles,
    };
  }
}
