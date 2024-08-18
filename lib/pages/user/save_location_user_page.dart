import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/user/map_page_user.dart';
import 'package:disacare/pages/user/review_location_page.dart';
import 'package:disacare/pages/user/review_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class UserSavedLocation extends StatefulWidget {
  const UserSavedLocation({super.key});

  @override
  State<UserSavedLocation> createState() => _UserSavedLocationState();
}

class _UserSavedLocationState extends State<UserSavedLocation> {
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
                builder: (context) => const UserMapPage(),
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
                          builder: (context) => UserLocationReviewPage(
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
                builder: (context) => const UserMapPage(),
              ),
            );
          } else if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserReviewPage(),
              ),
            );
          }
        },
      ),
    );
  }
}
