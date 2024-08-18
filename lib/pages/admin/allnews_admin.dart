import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/admin/admin_home.dart';
import 'package:disacare/pages/admin/seenewsadmin.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class AllNewsAdminPage extends StatefulWidget {
  const AllNewsAdminPage({super.key});

  @override
  State<AllNewsAdminPage> createState() => _AllNewsAdminPageState();
}

class _AllNewsAdminPageState extends State<AllNewsAdminPage> {
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
                builder: (context) => const AdminHomePage(),
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
                              final judul =
                                  item['judul']?.toString().toLowerCase() ?? '';
                              final isi =
                                  item['isi']?.toString().toLowerCase() ?? '';
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
                  final newsItemsToShow = _filteredNewsItems.isNotEmpty
                      ? _filteredNewsItems
                      : _allNewsItems;
                  return ListView.builder(
                    itemBuilder: (context, index) {
                      var item = newsItemsToShow[index].data()!;
                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 6.0),
                        child: Card(
                          color: Colors.blue,
                          child: ListTile(
                            title: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  item['judul'] ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 19,
                                  ),
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
                                  height: 8,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                AdminSeeNewsContentPage(
                                                    berita: item),
                                          ),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.white,
                                        foregroundColor: Colors.blue,
                                      ),
                                      child: const Text(
                                        'Lihat',
                                        style: TextStyle(color: Colors.blue),
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () async {
                                        showDialog(
                                          context: context,
                                          builder: (BuildContext context) {
                                            return AlertDialog(
                                              title: const Text("Hapus Berita"),
                                              content: const Text(
                                                  "Apakah anda yakin ingin menghapus berita ini?"),
                                              actions: [
                                                TextButton(
                                                  onPressed: () async {
                                                    Navigator.of(context).pop();
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection("berita")
                                                        .doc(
                                                            _allNewsItems[index]
                                                                .id)
                                                        .delete();
                                                    Fluttertoast.showToast(msg: 'Berhasil Menghapus Berita');
                                                  },
                                                  child: const Text("Hapus"),
                                                ),
                                                TextButton(
                                                  onPressed: () {
                                                    Navigator.of(context).pop();
                                                  },
                                                  child: const Text("Tidak"),
                                                ),
                                              ],
                                            );
                                          },
                                        );
                                      },
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            isThreeLine: true,
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
