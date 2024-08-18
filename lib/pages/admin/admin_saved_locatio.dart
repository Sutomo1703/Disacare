import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/admin/admin_location_review.dart';
import 'package:disacare/pages/admin/admin_review.dart';
import 'package:disacare/pages/admin/map_page_admin.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AdminSavedLocationPage extends StatefulWidget {
  const AdminSavedLocationPage({super.key});

  @override
  State<AdminSavedLocationPage> createState() => _AdminSavedLocationPageState();
}

class _AdminSavedLocationPageState extends State<AdminSavedLocationPage> {
  //firebase auth
  final _auth = FirebaseAuth.instance;

  //Bottom Navbar Index
  int _selectedIndex = 1;

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
                builder: (context) => const AdminMapPage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Saved',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: StreamBuilder(
          stream: FirebaseFirestore.instance
              .collection('users')
              .doc(user?.uid)
              .collection('save_lokasi')
              .snapshots(),
          builder: ((context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

            var items = snapshot.data!.docs;
            if (items.isEmpty) {
              return const Center(
                child: Text(
                  'Belum ada lokasi yang pernah disimpan',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              );
            }

            return Padding(
              padding: const EdgeInsets.all(12),
              child: ListView.separated(
                itemBuilder: (context, index) {
                  var item = items[index].data();
                  return InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AdminLocationReviewPage(
                            locationName: item['locationName'],
                            docId: item['location_id'],
                          ),
                        ),
                      );
                    },
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(8.0),
                        color: Colors.white,
                      ),
                      child: ListTile(
                        title: Text(
                          item['locationName'],
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 19,
                          ),
                        ),
                        subtitle: Text(
                          item['streetAddress'],
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ),
                  );
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 10),
                itemCount: snapshot.data!.docs.length,
              ),
            );
          }),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.blue,
        unselectedItemColor: Colors.white,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.save),
            label: 'Save',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.reviews),
            label: 'Kontribusi',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.black,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminMapPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const AdminReviewPage(),
              ),
            );
          }
        },
      ),
    );
  }
}