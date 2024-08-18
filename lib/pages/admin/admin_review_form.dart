// ignore_for_file: use_build_context_synchronously, curly_braces_in_flow_control_structures, prefer_interpolation_to_compose_strings
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/model/user_model.dart';
import 'package:disacare/pages/admin/map_page_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class AdminReviewFormPage extends StatefulWidget {
  final String locationName;
  final String? docId;
  const AdminReviewFormPage({super.key, required this.locationName, this.docId});

  @override
  State<AdminReviewFormPage> createState() => _AdminReviewFormPageState();
}

class _AdminReviewFormPageState extends State<AdminReviewFormPage> {
  double _rating = 0;
  File? _image;
  final picker = ImagePicker();
  final isireviewController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();
  bool _hideUsername = false;

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
  void dispose() {
    isireviewController.dispose();
    super.dispose();
  }

  Future<String?> _uploadImageToStorage(
      File imageFile, String locationName) async {
    try {
      Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('lokasi')
          .child(locationName)
          .child(DateTime.now().toString());
      UploadTask uploadTask = storageReference.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      Fluttertoast.showToast(msg: 'Failed to upload image');
      return null;
    }
  }

  void checkAndUpdateTitle(int currentExp) {
    if (currentExp >= 50 &&
        loggedInUser.titles?.contains('Penjelajah') != true) {
      loggedInUser.titles ??= [];
      loggedInUser.titles!.add('Penjelajah');
      updateUserTitles(loggedInUser.titles!);
    } else if (currentExp >= 100 &&
        loggedInUser.titles?.contains('Guru Informasi') != true) {
      loggedInUser.titles ??= [];
      loggedInUser.titles!.add('Guru Informasi');
      updateUserTitles(loggedInUser.titles!);
    }
  }

  void updateUserTitles(List<String> titles) {
    User? user = _auth.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection("users").doc(user.uid).update({
        'titles': titles,
      }).then((_) {});
    }
  }

  String formatDate(DateTime dateTime) {
    return '${dateTime.month}/${dateTime.day}/${dateTime.year}-${dateTime.hour}:${dateTime.minute}:${dateTime.second}';
  }

  String obfuscateUsername(String username) {
    if (username.length <= 2) return username;
    return username[0] + '***' + username[username.length - 1];
  }

  Future<void> _updateOverallRating() async {
    // Get all reviews for the location
    QuerySnapshot reviewsSnapshot = await FirebaseFirestore.instance
        .collection('lokasi')
        .doc(widget.docId)
        .collection('review')
        .get();

    // Calculate new overall rating score
    double totalRating = 0;
    int totalReviews = reviewsSnapshot.docs.length;
    for (QueryDocumentSnapshot review in reviewsSnapshot.docs) {
      totalRating += review['rating'];
    }
    double overallRating = totalRating / totalReviews;

    // Round overall rating to one decimal place
    overallRating = double.parse(overallRating.toStringAsFixed(1));

    // Update overall rating score in Firestore
    await FirebaseFirestore.instance
        .collection('lokasi')
        .doc(widget.docId)
        .update({'rating_score': overallRating});
  }

  void _postReview() async {
    if (_formKey.currentState!.validate()) {
      if (_rating < 1) {
        Fluttertoast.showToast(msg: 'Berikan nilai rating minimal 1');
        return;
      }
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const AlertDialog(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                CircularProgressIndicator(),
                SizedBox(height: 16),
                Text("Posting review..."),
              ],
            ),
          );
        },
      );

      try {
        String reviewContent = isireviewController.text;
        String? imageUrl;
        int likes = 0;
        int dislikes = 0;
        if (_image != null) {
          imageUrl = await _uploadImageToStorage(_image!, widget.locationName);
        }

        DateTime now = DateTime.now();

        String formattedDateTime = formatDate(now);

        User? user = FirebaseAuth.instance.currentUser;
        DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(user!.uid)
            .get();
        String namaUser = userSnapshot['username'];
        if (_hideUsername) {
          namaUser = obfuscateUsername(namaUser);
        }

        //Send review collection to lokasi collection
        // ignore: unused_local_variable
        DocumentReference reviewRefLokasi = await FirebaseFirestore.instance
            .collection('lokasi')
            .doc(widget.docId)
            .collection('review')
            .add({
          'rating': _rating,
          'review_content': reviewContent,
          'userId': user.uid,
          'picture': imageUrl,
          'username': namaUser,
          'likeCount': likes,
          'dislikeCount': dislikes,
          'likedBy': [],
          'dislikedBy': [],
          'timestamp': formattedDateTime,
        });

        String userId = FirebaseAuth.instance.currentUser!.uid;
        //Send review collection to users collection
        DocumentSnapshot locationSnapshot = await FirebaseFirestore.instance
            .collection('lokasi')
            .doc(widget.docId)
            .get();
        String locationName = locationSnapshot['locationName'];
        String streetAddress = locationSnapshot['streetAddress'];
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .collection('review')
            .add({
          'rating': _rating,
          'review_content': reviewContent,
          'picture': imageUrl,
          'locationName': locationName,
          'streetAddress': streetAddress,
          'timestamp': formattedDateTime,
        });

        int currentExp = userSnapshot['exp'] ?? 0;
        int newExp = currentExp + 5;
        if (newExp >= 100) {
          newExp = 100;
        }
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .update({'exp': newExp});

        checkAndUpdateTitle(newExp);

        await _updateOverallRating();

        Fluttertoast.showToast(msg: "Berhasil mengpost review");
        Navigator.pop(context);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const AdminMapPage(),
          ),
        );
      } catch (e) {
        Navigator.pop(context);
        Fluttertoast.showToast(
            msg: "Gagal mengpost review. Silahkan lakukan beberapa saat lagi");
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isireviewField = TextFormField(
      autofocus: false,
      controller: isireviewController,
      keyboardType: TextInputType.name,
      onSaved: (value) {
        isireviewController.text = value!;
      },
      decoration: InputDecoration(
          isDense: true,
          hintText: 'Berikan informasi tentang aksesibilitas di lokasi ini',
          hintStyle: const TextStyle(fontSize: 16),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
      maxLines: 6,
    );

    final postButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(30),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: _postReview,
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
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        leading: IconButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminMapPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: Text(
          widget.locationName,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Form(
            key: _formKey,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bagaimana Aksesibilitas di tempat ini?',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(
                    height: 10,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Aksesibilitas:',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      RatingBar.builder(
                        initialRating: _rating,
                        minRating: 0,
                        direction: Axis.horizontal,
                        allowHalfRating: false,
                        itemCount: 5,
                        itemSize: 25,
                        itemBuilder: (context, _) => const Icon(
                          Icons.star,
                          color: Colors.amber,
                        ),
                        onRatingUpdate: (rating) {
                          setState(() {
                            _rating = rating;
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 25),
                  isireviewField,
                  const SizedBox(
                    height: 40,
                  ),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.blue,
                    ),
                    onPressed: getImage,
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_a_photo),
                        SizedBox(
                          width: 5,
                        ),
                        Text(
                          "Add Image",
                          style: TextStyle(fontSize: 15),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 20,
                  ),
                  _image == null
                      ? Container()
                      : Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(5),
                            border: Border.all(color: Colors.grey),
                          ),
                          child: Image.file(
                            _image!,
                            height: 100,
                            width: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Checkbox(
                        value: _hideUsername,
                        onChanged: (bool? value) {
                          setState(() {
                            _hideUsername = value!;
                          });
                        },
                      ),
                      const Text('Sembunyikan Nama'),
                    ],
                  ),
                  const SizedBox(
                    height: 35,
                  ),
                  postButton,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      } else {
        Fluttertoast.showToast(msg: 'Tidak ada gambar yang dipilih');
      }
    });
  }
}