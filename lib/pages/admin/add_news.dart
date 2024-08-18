// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/admin/admin_home.dart';
import 'package:disacare/style/button.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class AddNewsAdminPage extends StatefulWidget {
  const AddNewsAdminPage({super.key});

  @override
  State<AddNewsAdminPage> createState() => _AddNewsAdminPageState();
}

class _AddNewsAdminPageState extends State<AddNewsAdminPage> {
  //ImageURl
  String imageUrl = '';

  //Show Image
  File? _image;

  //Firebase Auth
  final _auth = FirebaseAuth.instance;
  final CollectionReference _berita =
      FirebaseFirestore.instance.collection('berita');

  //Form Key
  final _formKey = GlobalKey<FormState>();

  //TextEditing Controller
  final judulberitaController = TextEditingController();
  final isiberitaController = TextEditingController();

  @override
  void dispose() {
    judulberitaController.dispose();
    isiberitaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Judul Berita Field
    final judulberitaField = TextFormField(
      autofocus: false,
      controller: judulberitaController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Judul Berita Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        judulberitaController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        isDense: true,
        contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 20),
        hintText: 'Judul',
        hintStyle: const TextStyle(fontSize: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Isi Berita Field
    final isiberitaField = TextFormField(
      autofocus: false,
      controller: isiberitaController,
      keyboardType: TextInputType.name,
      validator: (value) {
        if (value!.isEmpty) {
          return ("isi Berita Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        isiberitaController.text = value!;
      },
      decoration: InputDecoration(
          isDense: true,
          hintText: 'Ketik Sesuatu',
          hintStyle: const TextStyle(fontSize: 14),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(0))),
      maxLines: 6,
    );

    //Post Button
    final postButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            postDetailsToFirestore();
          }
        },
        child: const Text(
          "Post",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminHomePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Menambah Berita',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                //Judul Berita
                const SizedBox(
                  height: 25,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Judul Berita:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),

                //Judul Berita Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: judulberitaField,
                ),
                //Pilih File
                const SizedBox(
                  height: 25,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Text(
                    'File/Gambar:',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(
                  height: 5.0,
                ),
                //Pilih File Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      ElevatedButton(
                        style: pilihgambarbutton,
                        onPressed: () async {
                          pickImage();
                        },
                        child: const Text(
                          'Pilih File',
                          style: TextStyle(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: _image == null
                      ? const Text('Tidak ada gambar yang dipilih')
                      : Image.file(_image!),
                ),

                //Isi Berita
                const SizedBox(
                  height: 25,
                ),
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    children: [
                      Text(
                        'Konten Berita:',
                        style: TextStyle(
                          fontSize: 16,
                        ),
                      ),
                      Text(
                        '*',
                        style: TextStyle(
                          color: Colors.red,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15.0,
                ),
                //Isi Berita Field
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: isiberitaField,
                ),
                const SizedBox(
                  height: 50.0,
                ),
                //Post Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: postButton,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }

  //Image Picker
  Future pickImage() async {
    final XFile? pickedFile =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;
    String filename = DateTime.now().microsecondsSinceEpoch.toString();

    //Get FirebaseStorage Reference Root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDireImages = referenceRoot.child('Berita_gambar');

    Reference referenceImageToUpload = referenceDireImages.child(filename);

    //Catch Error
    try {
      showDialog(
        context: context,
        builder: (context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      await referenceImageToUpload.putFile(
          File(pickedFile.path), SettableMetadata(contentType: 'image/png'));
      Navigator.pop(context);
      setState(() {
        _image = File(pickedFile.path);
      });
      imageUrl = await referenceImageToUpload.getDownloadURL();
    } catch (error) {
      Fluttertoast.showToast(msg: 'Gagal Memilih File');
    }
  }

  //Post to firestore
  Future<void> postDetailsToFirestore() async {
    User? user = _auth.currentUser;
    final String uid = user!.uid;
    DateTime now = DateTime.now();
    String date = DateFormat('yyyy-MM-dd – kk:mm').format(now);
    final String judulBerita = judulberitaController.text;
    final String isiBerita = isiberitaController.text;
    try {
      if (_formKey.currentState!.validate()) {
        await _berita.add({
          "uid": uid,
          "judul": judulBerita,
          "file": imageUrl,
          "isi": isiBerita,
          "date": date
        });
        Fluttertoast.showToast(msg: 'Berita Berhasil di Post');
      }
      Navigator.pushAndRemoveUntil(
          (context),
          MaterialPageRoute(builder: (context) => const AdminHomePage()),
          (route) => false);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengirim berita');
    }
  }
}
