import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/user/alert_page.dart';
import 'package:disacare/pages/user/contact_detail_page.dart';
import 'package:disacare/pages/user/contact_page_form.dart';
import 'package:disacare/pages/user/main_home_page.dart';
import 'package:disacare/pages/user/map_page_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:math' as math;

class ContactPage extends StatefulWidget {
  const ContactPage({super.key});

  @override
  State<ContactPage> createState() => _ContactPageState();
}

class _ContactPageState extends State<ContactPage> {
  //firebase
  final _auth = FirebaseAuth.instance;

  //Navigation Bar Home Page
  int _selectedIndex = 3;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserMapPage(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AlertPage(),
        ),
      );
    } else if (index == 0) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const UserHomePage(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'List Kontak',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
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
            )),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: [
              const SizedBox(
                height: 15,
              ),
              Expanded(
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
                    var items = snapshot.data?.docs ?? [];
                    if (items.isEmpty) {
                      return const Center(
                        child: Text(
                          'Kontak kosong, silahkan tambah kontak',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.black,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      );
                    }
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 8.0),
                      child: ListView.builder(
                          itemBuilder: (context, index) {
                            var item = items[index].data();
                            return Card(
                              child: ListTile(
                                title: Text(
                                  item['nama_kontak'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
                                ),
                                subtitle: Text(
                                  item['nomor_kontak'],
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 15,
                                  ),
                                ),
                                trailing: Transform.rotate(
                                  angle: 180 * math.pi / 180,
                                  child: IconButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              ContactDetailPage(kontak: item),
                                        ),
                                      );
                                    },
                                    icon: const Icon(
                                      Icons.arrow_back_ios,
                                      size: 25,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          },
                          itemCount: snapshot.data!.docs.length),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user?.uid)
            .collection('list_kontak')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const CircularProgressIndicator();
          }
          var contactsCount = snapshot.data?.docs.length ?? 0;
          return FloatingActionButton(
            onPressed: contactsCount < 5
                ? () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const ContactFormPage(),
                      ),
                    );
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Anda tidak dapat menambah lebih dari 5 kontak.'),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
            foregroundColor: Colors.white,
            backgroundColor: contactsCount < 5
                ? Colors.blue
                : Colors
                    .grey,
            shape: const CircleBorder(),
            child: const Icon(
              Icons.add,
              size: 40,
            ),
          );
        },
      ),
      bottomNavigationBar: Material(
        child: BottomNavigationBar(
          backgroundColor: Colors.blue,
          unselectedItemColor: Colors.white,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          items: const <BottomNavigationBarItem>[
            BottomNavigationBarItem(
              icon: Icon(Icons.home),
              label: 'Home',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.warning),
              label: 'Alert',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.contacts),
              label: 'Kontak',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }
}
