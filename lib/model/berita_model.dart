class BeritaModel {
  String? uid;
  String? judul;
  String? file;
  String? isi;
  String? date;

  BeritaModel({this.uid, this.judul, this.file, this.isi, this.date});

  // receiving data from server
  factory BeritaModel.fromMap(map) {
    return BeritaModel(
        uid: map['uid'],
        judul: map['judul'],
        file: map['file'],
        isi: map['isi'],
        date: map['date']);
  }

  //sending data to the server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'judul': judul,
      'file': file,
      'isi': isi,
      'date': date,
    };
  }
}
