import 'package:disacare/pages/user/main_home_page.dart';
import 'package:disacare/pages/user/seenewsuser.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AllNewsUserPage extends StatefulWidget {
  const AllNewsUserPage({super.key});

  @override
  State<AllNewsUserPage> createState() => _AllNewsUserPageState();
}

class _AllNewsUserPageState extends State<AllNewsUserPage> {
  late TextEditingController _searchController;
  late List<DocumentSnapshot<Map<String, dynamic>>> _allNewsItems;
  List<DocumentSnapshot<Map<String, dynamic>>> _filteredNewsItems = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
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
          'Semua Berita',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(
              height: 20,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10.0),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8.0),
                  border: Border.all(color: Colors.grey),
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 8.0),
                    const Icon(Icons.search, color: Colors.grey),
                    const SizedBox(width: 8.0),
                    Expanded(
                      child: TextField(
                        controller: _searchController,
                        decoration: const InputDecoration(
                          hintText: 'Cari berita...',
                          border: InputBorder.none,
                        ),
                        onChanged: (query) {
                          setState(() {
                            _filteredNewsItems = _allNewsItems.where((item) {
                              final judul = item['judul']?.toString().toLowerCase() ?? '';
                              final isi = item['isi']?.toString().toLowerCase() ?? '';
                              return judul.contains(query.toLowerCase()) ||
                                  isi.contains(query.toLowerCase());
                            }).toList();
                          });
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
                stream: FirebaseFirestore.instance
                    .collection("berita")
                    .orderBy('date', descending: true)
                    .snapshots(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: CircularProgressIndicator(),
                    );
                  }
                  _allNewsItems = snapshot.data!.docs;
                  final newsItemsToShow =
                      _filteredNewsItems.isNotEmpty ? _filteredNewsItems : _allNewsItems;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var item = newsItemsToShow[index].data()!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Card(
                          color: Colors.blue,
                          child: ListTile(
                            title: Text(
                              item['judul'] ?? '',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 19,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 5,
                                ),
                                Text(
                                  item['isi'] ?? '',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                  ),
                                ),
                                const SizedBox(
                                  height: 3,
                                ),
                                Text(
                                  item['date'] ?? '',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                            isThreeLine: true,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      UserSeeNewsContentPage(berita: item),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                    itemCount: newsItemsToShow.length,
                  );
                },
              ),
            ),
            const SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}