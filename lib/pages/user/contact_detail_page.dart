import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/user/contact_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:url_launcher/url_launcher.dart';

// ignore: must_be_immutable
class ContactDetailPage extends StatefulWidget {
  final Map<String, dynamic> kontak;
  const ContactDetailPage({super.key, required this.kontak});

  @override
  State<ContactDetailPage> createState() => _ContactDetailPageState();
}

class _ContactDetailPageState extends State<ContactDetailPage> {
  //firebase
  final _auth = FirebaseAuth.instance;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
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
          ),
        ),
      ),
      body: SafeArea(
          child: Center(
        child: Column(
          children: [
            const SizedBox(
              height: 100,
            ),
            Card(
              elevation: 0,
              color: Colors.blue,
              child: SizedBox(
                width: 350,
                height: 180,
                child: StreamBuilder(
                  stream: FirebaseFirestore.instance
                      .collection('users')
                      .doc(user?.uid)
                      .collection('list_kontak')
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                    return Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 10,
                          ),
                          Text(
                            widget.kontak["nama_kontak"],
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 26,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Mobile +62",
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                widget.kontak["nomor_kontak"],
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(
                            height: 20,
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              IconButton(
                                onPressed: () {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            //Go to Whatsapp
                                            TextButton(
                                              onPressed: () {
                                                gowhatsapp(widget
                                                    .kontak["nomor_kontak"]);
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Iya'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Tidak'),
                                            ),
                                          ],
                                        )
                                      ],
                                      title:
                                          const Text('Pengarahan ke Whatsapp'),
                                      contentPadding:
                                          const EdgeInsets.all(20.0),
                                      content: const Text(
                                          'Anda akan diarahkan menuju ke whatsapp. Apakah anda yakin?'),
                                    ),
                                  );
                                },
                                icon: Image.asset(
                                  'assets/img/whatsapp.png',
                                  width: 40,
                                  height: 40,
                                ),
                              ),
                              const SizedBox(
                                width: 30,
                              ),
                              IconButton(
                                onPressed: () async {
                                  showDialog(
                                    context: context,
                                    builder: (context) => AlertDialog(
                                      actions: [
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            //Delete Button
                                            TextButton(
                                              onPressed: () {
                                                deleteCollection(widget.kontak["document_id"]);
                                                Navigator.push(
                                                  context,
                                                  MaterialPageRoute(
                                                    builder: (context) =>
                                                        const ContactPage(),
                                                  ),
                                                );
                                                Fluttertoast.showToast(
                                                    msg:
                                                        'kontak Berhasil Dihapus');
                                              },
                                              child: const Text('Iya'),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.pop(context);
                                              },
                                              child: const Text('Tidak'),
                                            ),
                                          ],
                                        )
                                      ],
                                      title: const Text('Hapus Kontak'),
                                      contentPadding:
                                          const EdgeInsets.all(20.0),
                                      content: const Text(
                                          'Apakah anda ingin menghapus kontak ini?'),
                                    ),
                                  );
                                },
                                icon: const Icon(
                                  Icons.delete,
                                  size: 40,
                                  color: Colors.red,
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      )),
    );
  }

  //Delete Contact
  Future<void> deleteCollection(String documentId) async {
    User? user = _auth.currentUser;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user?.uid)
          .collection('list_kontak')
          .doc(documentId)
          .delete();
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal Menghapus Kontak');
    }
  }

  //Go To Whatsapp
  Future<void> gowhatsapp(String phoneno) async {
    final Uri whatsapp = Uri.parse('https://wa.me/+62$phoneno');
    launchUrl(whatsapp);
  }

//   Future<void> gowhatsapp(String phoneno) async {
//   // Construct the message
//   String message = 'Hello, nice to meet you!';
//   // Encode message for URL
//   String encodedMessage = Uri.encodeComponent(message);
//   // Construct the WhatsApp URL with the phone number and encoded message
//   final Uri whatsapp = Uri.parse('https://wa.me/+62$phoneno?text=$encodedMessage');
//   // Launch the URL
//   launchUrl(whatsapp);
// }
}
