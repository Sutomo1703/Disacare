// ignore_for_file: use_build_context_synchronously, avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/user/contact_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class ContactFormPage extends StatefulWidget {
  const ContactFormPage({super.key});

  @override
  State<ContactFormPage> createState() => _ContactFormPageState();
}

class _ContactFormPageState extends State<ContactFormPage> {
  //firebase
  final _auth = FirebaseAuth.instance;

  //Form Key
  final _formKey = GlobalKey<FormState>();

  //Controller
  // ignore: non_constant_identifier_names
  final UserContactController = TextEditingController();
  // ignore: non_constant_identifier_names
  final ContactNumberController = TextEditingController();

  @override
  void dispose() {
    UserContactController.dispose();
    ContactNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //User Field
    final userContactField = TextFormField(
      controller: UserContactController,
      autofocus: false,
      keyboardType: TextInputType.name,
      validator: (value) {
        RegExp regex = RegExp(r'^.{3,}$');
        if (value!.isEmpty) {
          return ("Nama Kontak tidak boleh kosong");
        }
        if (!regex.hasMatch(value)) {
          return ("Masukkan Nama Valid(Min. 3 huruf)");
        }
        return null;
      },
      onSaved: (value) {
        UserContactController.text = value!;
      },
      textInputAction: TextInputAction.next,
      decoration: InputDecoration(
        prefixIcon: const Icon(Icons.person),
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Nama",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );

    //Contact Field
    final phoneContactField = IntlPhoneField(
      controller: ContactNumberController,
      autofocus: false,
      keyboardType: TextInputType.phone,
      onSaved: (value) {
        ContactNumberController.text = value! as String;
      },
      textInputAction: TextInputAction.done,
      decoration: InputDecoration(
        contentPadding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        hintText: "Nomor Hp",
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
      initialCountryCode: 'ID',
    );

    //Saved Button
    // ignore: non_constant_identifier_names
    final SavedButton = Material(
      elevation: 5,
      borderRadius: BorderRadius.circular(10),
      color: Colors.blue,
      child: MaterialButton(
        padding: const EdgeInsets.fromLTRB(20, 15, 20, 15),
        minWidth: MediaQuery.of(context).size.width,
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            addContactCollection();
            Fluttertoast.showToast(msg: 'Berhasil Menambah Kontak');
          }
        },
        child: const Text(
          "Simpan",
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
                  builder: (context) => const ContactPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.arrow_back,
              color: Colors.white,
            )),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              //UserText
              const SizedBox(
                height: 20,
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Nama Kontak',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              //userField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: userContactField,
              ),
              const SizedBox(
                height: 20,
              ),

              //Contact Text
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Text(
                  'Nomor Hp',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(
                height: 8,
              ),
              //contactField
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: phoneContactField,
              ),
              const SizedBox(
                height: 50,
              ),
              //Saved Button
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: SavedButton,
              ),
            ],
          ),
        ),
      ),
    );
  }

  //Post Contact to Firebase
  Future<void> addContactCollection() async {
    User? user = _auth.currentUser;
    CollectionReference<Map<String, dynamic>> listKontakRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .collection('list_kontak');

    try {
      DocumentReference<Map<String, dynamic>> addedDocRef =
          await listKontakRef.add({
        'nama_kontak': UserContactController.text,
        'nomor_kontak': ContactNumberController.text,
      });

      // Get the ID of the added document
      String docId = addedDocRef.id;

      // Update the document with the captured ID
      await addedDocRef.update({'document_id': docId});

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const ContactPage(),
        ),
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal Menambah Kontak');
    }
  }
}
