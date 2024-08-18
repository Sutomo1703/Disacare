import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/model/updateuser_model.dart';
import 'package:disacare/model/user_model.dart';
import 'package:disacare/pages/admin/profile_page_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  //Firebase
  final _auth = FirebaseAuth.instance;
  final _formKey = GlobalKey<FormState>();
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  //Controller
  final usernameprofileController = TextEditingController();
  final alamatprofileController = TextEditingController();

  //PassToogle
  bool repassToogle = true;
  bool passToogle = true;

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
      setState(() {
        usernameprofileController.text = loggedInUser.username ?? '';
        alamatprofileController.text = loggedInUser.alamat ?? '';
      });
    });
  }

  @override
  void dispose() {
    usernameprofileController.dispose();
    alamatprofileController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //Username Field
    final usernamefield = TextFormField(
      autofocus: false,
      controller: usernameprofileController,
      keyboardType: TextInputType.text,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Nama Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        usernameprofileController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Address Field
    final alamatfield = TextFormField(
      autofocus: false,
      controller: alamatprofileController,
      validator: (value) {
        if (value!.isEmpty) {
          return ("Alamat Tidak Boleh Kosong");
        }
        return null;
      },
      onSaved: (value) {
        alamatprofileController.text = value!;
      },
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.map),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Save Changes Button
    final saveChangeButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Edit();
          }
        },
        child: const Text(
          "Simpan Perubahan",
          textAlign: TextAlign.center,
          style: TextStyle(
              fontSize: 18, color: Colors.white, fontWeight: FontWeight.bold),
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
                builder: (context) => const AdminProfilePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Edit Profile',
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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 100,
                    width: 100,
                    child: Center(
                      child: CircleAvatar(
                        radius: 50,
                        child: loggedInUser.gambar != null
                            ? ClipOval(
                                child: Image.network(
                                  loggedInUser.gambar!,
                                  fit: BoxFit.cover,
                                  height: 100,
                                  width: 100,
                                ),
                              )
                            : const CircleAvatar(
                                child: Icon(Icons.person),
                              ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 35),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: usernamefield,
                  ),
                  const SizedBox(height: 20),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: alamatfield,
                  ),
                  const SizedBox(height: 50),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: saveChangeButton,
                  ),
                  const SizedBox(height: 25),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ignore: non_constant_identifier_names
  void Edit() async {
    if (_formKey.currentState!.validate()) {
      await postDetailsToFirestore();
    }
  }

  Future<void> postDetailsToFirestore() async {
    FirebaseFirestore firebaseFirestore = FirebaseFirestore.instance;
    User? user = _auth.currentUser;

    String userId = user!.uid;
    String newUsername = usernameprofileController.text;

    UpdateModel updateModel = UpdateModel(
      uid: userId,
      username: newUsername,
      alamat: alamatprofileController.text,
    );

    await firebaseFirestore
        .collection("users")
        .doc(userId)
        .update(updateModel.toMap());

    await updateUsernamesInReviews(userId, newUsername);

    Fluttertoast.showToast(msg: "Berhasil Menyimpan Perubahan");

    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const AdminProfilePage()),
      );
    }
  }

  Future<void> updateUsernamesInReviews(
      String userId, String newUsername) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;

    try {
      QuerySnapshot lokasiSnapshot = await firestore.collection('lokasi').get();

      WriteBatch batch = firestore.batch();

      for (QueryDocumentSnapshot lokasiDoc in lokasiSnapshot.docs) {
        QuerySnapshot reviewSnapshot = await lokasiDoc.reference
            .collection('review')
            .where('userId', isEqualTo: userId)
            .get();

        for (QueryDocumentSnapshot reviewDoc in reviewSnapshot.docs) {
          String currentUsername = reviewDoc['username'];

          if (currentUsername.contains('*')) {
            String firstLetter = newUsername.substring(0, 1);
            String lastLetter = newUsername.substring(newUsername.length - 1);

            String updatedUsername = firstLetter +
                currentUsername.substring(1, currentUsername.length - 1) +
                lastLetter;

            batch.update(reviewDoc.reference, {'username': updatedUsername});
          } else {
            batch.update(reviewDoc.reference, {'username': newUsername});
          }
        }
      }

      await batch.commit();
      // ignore: empty_catches
    } catch (e) {}
  }
}
