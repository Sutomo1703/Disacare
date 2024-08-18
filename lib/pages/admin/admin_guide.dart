import 'package:disacare/pages/admin/admin_home.dart';
import 'package:disacare/pages/admin/admin_map_tutorial2.dart';
import 'package:disacare/pages/admin/admin_setting_tutorial.dart';
import 'package:flutter/material.dart';

class AdminGuidePage extends StatefulWidget {
  const AdminGuidePage({super.key});

  @override
  State<AdminGuidePage> createState() => _AdminGuidePageState();
}

class _AdminGuidePageState extends State<AdminGuidePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'Panduan App',
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
                builder: (context) => const AdminHomePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(8.0),
        children: [
          Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: const Text(
                'Panduan cara mengeset aplikasi disacare agar tampil di lock screen',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminSettingTutorialPage(),
                  ),
                );
              },
            ),
          ),
          Card(
            elevation: 4.0,
            margin: const EdgeInsets.symmetric(vertical: 8.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10.0),
            ),
            child: ListTile(
              title: const Text(
                'Panduan cara menggunakan map',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 17,
                ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const AdminMapTutorialPage2(),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}