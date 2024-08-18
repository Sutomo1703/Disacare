class UpdateModel {
  String? uid;
  String? username;
  String? alamat;
  String? gambar;

  UpdateModel({this.uid, this.gambar, this.username, this.alamat});

  // receiving data from server
  factory UpdateModel.fromMap(map) {
    return UpdateModel(
      uid: map['uid'],
      gambar: map ['gambar'],
      username: map['username'],
      alamat: map['alamat'],
    );
  }

  //sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'username': username,
      'alamat': alamat,
    };
  }
}
