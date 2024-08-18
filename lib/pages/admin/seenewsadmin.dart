import 'package:disacare/pages/admin/allnews_admin.dart';
import 'package:flutter/material.dart';

// ignore: must_be_immutable
class AdminSeeNewsContentPage extends StatefulWidget {
  final Map<String, dynamic> berita;
  const AdminSeeNewsContentPage({super.key, required this.berita});
  @override
  State<AdminSeeNewsContentPage> createState() =>
      _AdminSeeNewsContentPageState();
}

class _AdminSeeNewsContentPageState extends State<AdminSeeNewsContentPage> {
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
                builder: (context) => const AllNewsAdminPage(),
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
                  widget.berita["judul"],
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 30,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: widget.berita["file"] != null &&
                                widget.berita["file"].isNotEmpty
                            ? Image.network(
                                widget.berita["file"],
                              )
                            : Container(),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 15),
                Text(
                  widget.berita["isi"],
                  style: const TextStyle(color: Colors.black, fontSize: 15),
                  textAlign: TextAlign.justify,
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
