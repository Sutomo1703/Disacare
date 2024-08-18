// ignore_for_file: use_build_context_synchronously

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/model/user_model.dart';
import 'package:disacare/pages/user/edit_profile_user.dart';
import 'package:disacare/pages/user/main_home_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({super.key});

  @override
  State<UserProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<UserProfilePage> {
  //Firebase
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  //Firebase for Image
  final CollectionReference cthgambar =
      FirebaseFirestore.instance.collection("users");

  //Image Shown Profile
  String imageUrl = '';

  Future<void> updateGambar() async {
    return cthgambar.doc(user!.uid).update({'gambar': imageUrl}).then((value) {
      Fluttertoast.showToast(msg: 'Gambar Berhasil Terganti');
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserHomePage(),
        ),
      );
    });
  }

  //Retrieve Collection of User
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());
      setState(() {});
    });
  }

  @override
  Widget build(BuildContext context) {
    //Edit Profile Button
    final editProfileButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(35),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const UserEditProfilePage(),
            ),
          );
        },
        child: const Text(
          'Edit Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
            fontSize: 18,
          ),
        ),
      ),
    );

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserHomePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(
                  height: 15,
                ),
                //Profile picture
                Stack(
                  children: [
                    SizedBox(
                      height: 100,
                      width: 100,
                      child: Center(
                        child: CircleAvatar(
                            radius: 50,
                            child: loggedInUser.gambar != null
                                ? ClipOval(
                                    child: Image.network(
                                      '${loggedInUser.gambar}',
                                      fit: BoxFit.cover,
                                      height: 100,
                                      width: 100,
                                    ),
                                  )
                                : const CircleAvatar(
                                    child: Icon(
                                      Icons.person,
                                    ),
                                  )),
                      ),
                    ),
                    Positioned(
                      bottom: -11,
                      left: 60,
                      child: IconButton(
                        icon: const Icon(Icons.add_a_photo),
                        onPressed: () async {
                          changeProfile();
                        },
                      ),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 10,
                ),
                //Username
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      '${loggedInUser.username}',
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 50,
                ),
                //Email
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.email_outlined,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Text(
                        '${loggedInUser.email}',
                        style: const TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey[400],
                ),
                const SizedBox(
                  height: 10,
                ),
                //Address
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.map_outlined,
                        size: 30,
                      ),
                      const SizedBox(
                        width: 50,
                      ),
                      Expanded(
                        child: Text(
                          '${loggedInUser.alamat}',
                          style: const TextStyle(fontSize: 16),
                        ),
                      )
                    ],
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                Divider(
                  thickness: 0.5,
                  color: Colors.grey[400],
                ),
                const SizedBox(
                  height: 50,
                ),
                //Edit Profile Button
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 25.0),
                  child: editProfileButton,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> changeProfile() async {
    //Send Image to FirebaseStorage
    final file = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (file == null) return;

    String filename = DateTime.now().microsecondsSinceEpoch.toString();

    //Get FirebaseStorage Reference Root
    Reference referenceRoot = FirebaseStorage.instance.ref();
    Reference referenceDireImages = referenceRoot.child('gambar');

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
          File(file.path), SettableMetadata(contentType: 'image/png'));

      imageUrl = await referenceImageToUpload.getDownloadURL();
      updateGambar();
    } catch (error) {
      Fluttertoast.showToast(msg: 'Gagal Mengunggah Gambar');
    }
  }
}
