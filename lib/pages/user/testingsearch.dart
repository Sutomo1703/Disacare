import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:disacare/pages/user/main_home_page.dart';

class TestingSearchPage extends StatefulWidget {
  const TestingSearchPage({super.key});

  @override
  State<TestingSearchPage> createState() => _TestingSearchPageState();
}

class _TestingSearchPageState extends State<TestingSearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> _searchResults = [];
  bool _isSearching = false;

  void _searchLocations(String query) async {
    if (query.isEmpty) {
      setState(() {
        _searchResults = [];
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
      String locationName = location['locationName_holder'].toString().toLowerCase();
      return locationName.contains(query.toLowerCase());
    }).toList();

    // Nominatim API search
    var nominatimUrl =
        'https://nominatim.openstreetmap.org/search?q=$query&format=json';
    var response = await http.get(Uri.parse(nominatimUrl));

    if (response.statusCode == 200) {
      List<dynamic> nominatimResults = json.decode(response.body);
      setState(() {
        _searchResults = [
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'Testing Search',
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
          ),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              textInputAction: TextInputAction.search,
              onChanged: _searchLocations,
              decoration: InputDecoration(
                labelText: 'Search Location',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.clear),
                  onPressed: () {
                    _searchController.clear();
                    _searchLocations('');
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: _isSearching
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    itemCount: _searchResults.length,
                    itemBuilder: (context, index) {
                      var location = _searchResults[index];
                      if (location is DocumentSnapshot) {
                        return ListTile(
                          title: Text(location['locationName']),
                          onTap: () => print('1'),
                        );
                      } else if (location is Map<String, dynamic>) {
                        return ListTile(
                          title: Text(location['display_name']),
                          onTap: () => print('2'),
                        );
                      } else {
                        return const ListTile(
                          title: Text('Unknown location type'),
                        );
                      }
                    },
                  ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
