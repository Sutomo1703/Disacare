import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/user/main_home_page.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable, camel_case_types
class contentnewsHomeUserPage extends StatefulWidget {
  contentnewsHomeUserPage(this.doc, {super.key});
  QueryDocumentSnapshot doc;

  @override
  State<contentnewsHomeUserPage> createState() => _contentnewsHomeUserPageState();
}

// ignore: camel_case_types
class _contentnewsHomeUserPageState extends State<contentnewsHomeUserPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        automaticallyImplyLeading: false,
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
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 18.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const  SizedBox(height: 5,),
                Text(
                  widget.doc["judul"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
                const  SizedBox(height: 10,),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.doc["file"] != null &&
                                widget.doc["file"].isNotEmpty
                            ? Image.network(
                                widget.doc["file"],
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  widget.doc["isi"],
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(
                  height: 30,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}