// ignore_for_file: avoid_print

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/components/side_navbar_admin.dart';
import 'package:disacare/pages/admin/add_news.dart';
import 'package:disacare/pages/admin/allnews_admin.dart';
import 'package:disacare/pages/admin/map_page_admin.dart';
import 'package:disacare/pages/admin/seenewshomeadmin.dart';
import 'package:disacare/style/button.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart' as painting;
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({super.key});

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
  //NavigationBar
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
    if (index == 1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AddNewsAdminPage(),
        ),
      );
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const AdminMapPage(),
        ),
      );
    }
  }

  //Get User Current Location to Show Address
  // ignore: unused_field
  LatLng? _currentLocation;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      LatLng location = await getCurrentLocation();
      String address = await getCurrentLocationAddress();
      if (mounted) {
        setState(() {
          _currentLocation = location;
          _currentAddress = address;
        });
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal Mendapatkan Lokasi');
    }
  }

  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Check if location services are enabled
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      // Location services are not enabled
      // Handle accordingly
      print('service disabled');
    }

    // Request location permission
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // Get current location
    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<String> getCurrentLocationAddress() async {
    // Get current location
    Position position = await Geolocator.getCurrentPosition();

    // Fetch the address from coordinates
    try {
      List<Placemark> placemarks =
          await placemarkFromCoordinates(position.latitude, position.longitude);

      // Extract street name
      if (placemarks.isNotEmpty) {
        Placemark placemark = placemarks.first;
        String street = placemark.street ?? '';
        return street.isNotEmpty ? street : 'Alamat Tidak Dikenal';
      }
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal Mendapatkan Jalan');
    }

    return 'Alamat Tidak Dikenal';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.blue,
        leading: Builder(
          builder: (context) => IconButton(
            onPressed: () => Scaffold.of(context).openDrawer(),
            icon: const Icon(
              Icons.menu,
              color: Colors.white,
              size: 28,
            ),
          ),
        ),
        title: const Text(
          'Disacare',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      drawer: const AdminSideNavbar(),
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: SafeArea(
          child: Column(
            children: [
              Stack(
                children: [
                  ClipPath(
                    clipper: CustomClipPath(),
                    child: Container(
                      color: Colors.blue,
                      height: 360,
                      child: Column(
                        children: [
                          const Padding(
                            padding: EdgeInsets.fromLTRB(14, 55, 0, 5),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                'Lokasi anda saat ini di',
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(14, 0, 0, 0),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.map,
                                  size: 25,
                                  color: Colors.white,
                                ),
                                const SizedBox(
                                  width: 5,
                                ),
                                if (_currentAddress != null)
                                  Text(
                                    _currentAddress!,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white,
                                      fontSize: 16,
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(15, 60, 15, 0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const Text(
                                  'Berita terpopuler',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            const AllNewsAdminPage(),
                                      ),
                                    );
                                  },
                                  child: const Text(
                                    'Lihat semua',
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                  //News Body
                  Column(children: [
                    const SizedBox(
                      height: 200,
                    ),
                    StreamBuilder<QuerySnapshot>(
                      stream: FirebaseFirestore.instance
                          .collection("berita")
                          .orderBy('date', descending: true)
                          .snapshots(),
                      builder:
                          (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        if (snapshot.hasData) {
                          List<QueryDocumentSnapshot> documents =
                              snapshot.data!.docs.take(3).toList();

                          return Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SizedBox(
                              height: 230,
                              width: double.infinity,
                              child: ListView(
                                scrollDirection: Axis.horizontal,
                                children: documents
                                    .map((note) => shapeCard(note))
                                    .toList(),
                              ),
                            ),
                          );
                        }
                        return const Text('Tidak ada berita sama sekali');
                      },
                    ),
                  ])
                ],
              ),
            ],
          ),
        ),
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
              icon: Icon(Icons.add),
              label: 'Add Berita',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.map),
              label: 'Map',
            ),
          ],
          currentIndex: _selectedIndex,
          selectedItemColor: Colors.black,
          onTap: _onItemTapped,
        ),
      ),
    );
  }

  //Card Berita
  Widget shapeCard(QueryDocumentSnapshot doc) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: const BorderSide(color: Colors.black, width: 1),
      ),
      child: SizedBox(
        width: 200,
        height: 150,
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                doc["judul"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              const SizedBox(
                height: 3,
              ),
              Text(
                doc["date"],
                style: const TextStyle(
                  fontSize: 12,
                ),
              ),
              const SizedBox(
                height: 15,
              ),
              Text(
                doc["isi"],
                overflow: TextOverflow.ellipsis,
                maxLines: 3,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
              ),
              const SizedBox(
                height: 30,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  //Lihat Isi Berita
                  ElevatedButton(
                    style: lihatberitabutton,
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => contentnewsHomeAdminPage(doc),
                        ),
                      );
                    },
                    child: const Text(
                      'Lihat',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomClipPath extends CustomClipper<painting.Path> {
  @override
  painting.Path getClip(Size size) {
    final path = painting.Path();

    path.moveTo(0, 0);
    path.lineTo(size.width * 1, size.height * 0.0001);
    path.lineTo(size.width * 1, size.height * 0.5);
    path.quadraticBezierTo(
      size.width * 0.7500000,
      size.height * 0.7000000,
      size.width * 0.5000000,
      size.height * 0.7000000,
    );
    path.quadraticBezierTo(
      size.width * 0.2500000,
      size.height * 0.7000000,
      0,
      size.height * 0.5000000,
    );
    path.lineTo(0, 0);
    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<painting.Path> oldClipper) {
    return false;
  }
}
