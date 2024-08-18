// ignore_for_file: prefer_final_fields, avoid_function_literals_in_foreach_calls, avoid_print, use_build_context_synchronously

import 'package:disacare/pages/user/main_home_page.dart';
import 'package:disacare/pages/user/map_tutorial_page.dart';
import 'package:disacare/pages/user/review_form_page.dart';
import 'package:disacare/pages/user/review_location_page.dart';
import 'package:disacare/pages/user/review_user_page.dart';
import 'package:disacare/pages/user/save_location_user_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class UserMapPage extends StatefulWidget {
  const UserMapPage({super.key});

  @override
  State<UserMapPage> createState() => _UserMapPageState();
}

class _UserMapPageState extends State<UserMapPage> {
  //firebase
  final _auth = FirebaseAuth.instance;

  final TextEditingController _controller = TextEditingController();

  //For Map
  LatLng? _currentLocation;
  List<Map<String, dynamic>> _markerLocations = [];
  List<dynamic> _locationSuggestions = [];
  bool _isSearching = false;
  LatLng? _selectedLocation;
  MapController _mapController = MapController();

  //Bottom Navbar Index
  int _selectedIndex = 0;

  //Pass docId
  String? docId;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _fetchMarkersFromFirestore();
  }

  @override
  void dispose() {
    super.dispose();
  }

  //Get Marker Document
  Future<void> _fetchMarkersFromFirestore() async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore.collection('lokasi').get();

      List<Map<String, dynamic>> markers = [];

      querySnapshot.docs.forEach((DocumentSnapshot document) {
        double latitude = document['latitude'];
        double longitude = document['longitude'];
        String locationName = document['locationName'];
        String streetAddress = document['streetAddress'];
        String locationId = document['location_id'];

        markers.add({
          'position': LatLng(latitude, longitude),
          'locationName': locationName,
          'streetAddress': streetAddress,
          'docId': locationId,
        });
      });

      setState(() {
        _markerLocations.addAll(markers);
      });
    } catch (e) {
      print('Failed to fetch markers: $e');
    }
  }

  //Get User Current Location
  Future<void> _getCurrentLocation() async {
    LatLng location = await getCurrentLocation();
    setState(() {
      _currentLocation = location;
    });
  }

  Future<LatLng> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('service disabled');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    Position position = await Geolocator.getCurrentPosition();
    return LatLng(position.latitude, position.longitude);
  }

  Future<void> _searchAndShowLocationOnMapFirebase(String locationName) async {
    try {
      final FirebaseFirestore firestore = FirebaseFirestore.instance;
      QuerySnapshot querySnapshot = await firestore
          .collection('lokasi')
          .where('locationName', isEqualTo: locationName)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        DocumentSnapshot document = querySnapshot.docs.first;
        double latitude = document['latitude'];
        double longitude = document['longitude'];
        LatLng latLng = LatLng(latitude, longitude);

        print(
            'Selected Location from Firestore - Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');

        setState(() {
          _selectedLocation = latLng;
          _controller.clear();
          _locationSuggestions = [];
          _isSearching = false;
        });
        
        FocusScope.of(context).unfocus();

        // Center the map's camera on the selected location
        _mapController.move(latLng, 17.0);
      } else {
        print('No location found in Firestore');
      }
    } catch (e) {
      print('Error searching and showing location on map from Firestore: $e');
    }
  }

  //Search and Show Location
  Future<void> _searchAndShowLocationOnMap(String locationName) async {
    try {
      List<Location> locations = await locationFromAddress(locationName);
      Location location = locations.first;
      LatLng latLng = LatLng(location.latitude, location.longitude);

      print(
          'Selected Location - Latitude: ${latLng.latitude}, Longitude: ${latLng.longitude}');

      setState(() {
        _selectedLocation = latLng;
        _controller.clear();
        _locationSuggestions = [];
        _isSearching = false;
      });

      FocusScope.of(context).unfocus();

      // Center the map's camera on the selected location
      _mapController.move(latLng, 17.0);
    } catch (e) {
      print('Error searching and showing location on map: $e');
    }
  }

  Future<void> _searchLocation(String query) async {
    if (query.isEmpty) {
      setState(() {
        _locationSuggestions = [];
      });
      return;
    }

    setState(() {
      _isSearching = true;
    });

    // Firebase Firestore search
    var collection = FirebaseFirestore.instance.collection('lokasi');
    var firebaseResults = await collection.get();

    var filteredFirebaseLocations = firebaseResults.docs.where((location) {
      String locationName =
          location['locationName_holder'].toString().toLowerCase();
      return locationName.contains(query.toLowerCase());
    }).toList();
    // Nominatim API search
    var nominatimUrl =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json';
    var response = await http.get(Uri.parse(nominatimUrl));

    if (response.statusCode == 200) {
      List<dynamic> nominatimResults = json.decode(response.body);
      setState(() {
        _locationSuggestions = [
          ...filteredFirebaseLocations,
          ...nominatimResults,
        ];
        _isSearching = false;
      });
    } else {
      setState(() {
        _isSearching = false;
      });
      throw Exception('Failed to load results from Nominatim API');
    }
  }

  //Center camera to user
  void _centerCameraToUserLocation() {
    if (_currentLocation != null) {
      _mapController.move(_currentLocation!, 17.0);
    }
  }

  //BuildMap UI
  Widget _buildMap() {
    return _currentLocation == null
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _selectedLocation ?? _currentLocation!,
              initialZoom: 17.0,
              onTap: (tapPosition, latLngPosition) {
                _addMarker(context, latLngPosition);
              },
              interactionOptions: const InteractionOptions(
                flags: ~InteractiveFlag.doubleTapZoom,
              ),
            ),
            children: [
              openStreetMapTileLayer,
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: TextField(
                  controller: _controller,
                  textInputAction: TextInputAction.search,
                  onChanged: _searchLocation,
                  decoration: InputDecoration(
                    labelText: 'Search Location',
                    filled: true,
                    fillColor: Colors.white,
                    border: const OutlineInputBorder(
                      borderRadius: BorderRadius.all(Radius.circular(50.0)),
                    ),
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _controller.clear();
                        _searchLocation('');
                      },
                    ),
                  ),
                ),
              ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: _currentLocation!,
                    width: 40.0,
                    height: 40.0,
                    child: const Icon(
                      Icons.location_on,
                      color: Colors.red,
                      size: 40.0,
                    ),
                  ),
                  for (var marker in _markerLocations)
                    Marker(
                      point: marker['position'],
                      width: 40.0,
                      height: 40.0,
                      child: GestureDetector(
                        onTap: () {
                          _showLocationDetails(
                            context,
                            marker['locationName'],
                            marker['streetAddress'],
                            marker['docId'],
                          );
                        },
                        child: const Icon(
                          Icons.location_on,
                          color: Colors.blue,
                          size: 40.0,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
  }

  //Show the BottomModalSheet when Clicking Marker
  void _showLocationDetails(BuildContext context, String? locationName,
      String? streetAddress, String? docId) async {
    FirebaseFirestore firestore = FirebaseFirestore.instance;
    try {
      DocumentSnapshot<Map<String, dynamic>> locationDoc =
          await firestore.collection('lokasi').doc(docId).get();

      double ratingScore = (locationDoc['rating_score'] ?? 0).toDouble();

      showModalBottomSheet<void>(
        context: context,
        builder: (BuildContext context) {
          return ClipRRect(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20.0),
              topRight: Radius.circular(20.0),
            ),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 210,
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          locationName ?? '',
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 0, 20.0, 10.0),
                    child: Row(
                      children: [
                        Text(
                          'Rating: $ratingScore',
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(
                          width: 3,
                        ),
                        RatingBarIndicator(
                          rating: ratingScore.toDouble(),
                          itemCount: 5,
                          itemSize: 20.0,
                          itemBuilder: (context, _) => const Icon(
                            Icons.star,
                            color: Colors.amber,
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),
                        StreamBuilder<QuerySnapshot>(
                          stream: FirebaseFirestore.instance
                              .collection('lokasi')
                              .doc(docId)
                              .collection('review')
                              .snapshots(),
                          builder: (BuildContext context,
                              AsyncSnapshot<QuerySnapshot> snapshot) {
                            if (snapshot.connectionState ==
                                ConnectionState.waiting) {
                              return const SizedBox.shrink();
                            }
                            int reviewCount = snapshot.data?.docs.length ?? 0;
                            return Text('($reviewCount)');
                          },
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20.0, 5.0, 20.0, 10.0),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined),
                        const SizedBox(
                          width: 10,
                        ),
                        Text(
                          streetAddress ?? '',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    height: 8,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        //Button Post Review
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            fixedSize: const Size(100, 30),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserReviewFormPage(
                                  locationName: locationName ?? '',
                                  docId: docId ?? '',
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.add,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Post',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),

                        //Button Location Review
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            fixedSize: const Size(117, 30),
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => UserLocationReviewPage(
                                  locationName: locationName ?? '',
                                  docId: docId ?? '',
                                ),
                              ),
                            );
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.reviews,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Review',
                                style: TextStyle(
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(
                          width: 5,
                        ),

                        //Button Saved Location
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.white,
                            foregroundColor: Colors.blue,
                            fixedSize: const Size(120, 30),
                          ),
                          onPressed: () {
                            _addSavedLocation(locationName ?? '',
                                streetAddress ?? '', docId ?? '');
                          },
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Icon(
                                Icons.save,
                                size: 16,
                              ),
                              SizedBox(
                                width: 5,
                              ),
                              Text(
                                'Simpan',
                                style: TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal mengambil detail lokasi');
    }
  }

  //Add Marker Question yes or no
  void _addMarker(BuildContext context, LatLng position) async {
    bool? showDialogToAddLocation = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Menambah Lokasi?'),
          content: const Text('Apakah Anda ingin menambah lokasi ?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text('Tambah'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Tidak'),
            ),
          ],
        );
      },
    );

    //Extended from addMarker if Answer is True
    if (showDialogToAddLocation == true) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          String locationName = '';

          return AlertDialog(
            title: const Text(
              'Berikan keterangan lokasi',
              style: TextStyle(fontSize: 22),
            ),
            content: TextField(
              onChanged: (value) {
                locationName = value;
              },
              decoration: const InputDecoration(
                labelText: 'Lokasi',
              ),
            ),
            actions: <Widget>[
              TextButton(
                onPressed: () async {
                  if (locationName.isNotEmpty) {
                    await _addMarkerToFirestore(
                        position.latitude, position.longitude, locationName);
                    Fluttertoast.showToast(msg: 'Berhasil Menambah Lokasi');
                  } else {
                    Fluttertoast.showToast(
                        msg: 'Nama Lokasi tidak boleh kosong');
                  }
                },
                child: const Text('Simpan'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: const Text('Tidak'),
              ),
            ],
          );
        },
      );
    }
  }

  //Post Saved Location to User Collection
  Future<void> _addSavedLocation(
      String locationName, String streetAddress, String locationId) async {
    User? user = _auth.currentUser;
    CollectionReference<Map<String, dynamic>> savedocRef = FirebaseFirestore
        .instance
        .collection('users')
        .doc(user?.uid)
        .collection('save_lokasi');

    try {
      // Check already existing location in document
      QuerySnapshot<Map<String, dynamic>> querySnapshot = await savedocRef
          .where('locationName', isEqualTo: locationName)
          .where('streetAddress', isEqualTo: streetAddress)
          .where('location_id', isEqualTo: locationId)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        Fluttertoast.showToast(
            msg: 'Lokasi ini sudah pernah disimpan sebelumnya', fontSize: 14);
        return;
      }

      DocumentReference<Map<String, dynamic>> addedDocRef =
          await savedocRef.add({
        'locationName': locationName,
        'streetAddress': streetAddress,
        'location_id': locationId,
      });

      // Get the ID of the added document
      String docId = addedDocRef.id;

      // Update the document with the captured ID
      await addedDocRef.update({'document_id': docId});

      Fluttertoast.showToast(msg: 'Berhasil menyimpan lokasi');

      Navigator.pop(context);
    } catch (e) {
      Fluttertoast.showToast(msg: 'Gagal Menyimpan lokasi');
    }
  }

  //Add Marker to Firestore
  Future<void> _addMarkerToFirestore(
      double latitude, double longitude, String locationName) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
      );

      final List<Placemark> placemarks =
          await placemarkFromCoordinates(latitude, longitude);
      final Placemark placemark = placemarks.first;

      final FirebaseFirestore firestore = FirebaseFirestore.instance;

      DocumentReference<Map<String, dynamic>> docRef =
          await firestore.collection('lokasi').add({
        'latitude': latitude,
        'longitude': longitude,
        'locationName': locationName,
        'locationName_holder': locationName.toLowerCase(),
        'streetAddress': placemark.street,
        'rating_score': 0,
      });

      docId = docRef.id;

      await docRef.update({'location_id': docId});

      setState(() {
        _markerLocations.add({
          'position': LatLng(latitude, longitude),
          'locationName': locationName,
          'streetAddress': placemark.street,
          'docId': docId,
          'icon': const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 40.0,
          ),
        });
      });

      Fluttertoast.showToast(msg: 'Berhasil Menambah Lokasi');
      Navigator.of(context).pop();

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserReviewFormPage(
            locationName: locationName,
            docId: docId ?? '',
          ),
        ),
      );
    } catch (e) {
      Navigator.of(context).pop();
      Fluttertoast.showToast(msg: 'Gagal menambah lokasi');
    }
  }

  @override
  Widget build(BuildContext context) {
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
          'Map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserMapTutorialPage(),
                ),
              );
            },
            icon: const Icon(
              Icons.lightbulb,
              color: Colors.white,
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Expanded(
                child: Stack(
                  children: [
                    _buildMap(),
                    if (_controller.text.isNotEmpty)
                      Positioned(
                        top: 80,
                        left: 0,
                        right: 0,
                        bottom: 0,
                        child: Container(
                          color: Colors.white,
                          child: _isSearching
                              ? const Center(child: CircularProgressIndicator())
                              : ListView.separated(
                                  itemCount: _locationSuggestions.length,
                                  separatorBuilder: (context, index) =>
                                      const Divider(),
                                  itemBuilder: (context, index) {
                                    var location = _locationSuggestions[index];
                                    if (location is DocumentSnapshot) {
                                      return ListTile(
                                        title: Text(location['locationName']),
                                        onTap: () {
                                          _searchAndShowLocationOnMapFirebase(
                                              location['locationName']);
                                        },
                                      );
                                    } else if (location
                                        is Map<String, dynamic>) {
                                      return ListTile(
                                        title: Text(location['display_name']),
                                        onTap: () {
                                          _searchAndShowLocationOnMap(
                                              location['display_name']);
                                        },
                                      );
                                    } else {
                                      return const ListTile(
                                        title: Text('Unknown location type'),
                                      );
                                    }
                                  },
                                ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
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
          if (index == 1) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const UserSavedLocation(),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _centerCameraToUserLocation();
        },
        foregroundColor: Colors.white,
        backgroundColor: Colors.blue,
        shape: const CircleBorder(),
        child: const Icon(
          Icons.my_location,
          size: 35,
        ),
      ),
    );
  }
}

TileLayer get openStreetMapTileLayer => TileLayer(
      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
      userAgentPackageName: 'dev.fleaflet.flutter_map.example',
    );
