import 'package:disacare/pages/admin/admin_guide.dart';
import 'package:disacare/style/color.dart';
import 'package:flutter/material.dart';

class AdminSettingTutorialPage extends StatefulWidget {
  const AdminSettingTutorialPage({super.key});

  @override
  State<AdminSettingTutorialPage> createState() => _AdminSettingTutorialPageState();
}

class _AdminSettingTutorialPageState extends State<AdminSettingTutorialPage> {
  final PageController _pageController = PageController();
  int _currentPageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController.addListener(() {
      setState(() {
        _currentPageIndex = _pageController.page!.round();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Colors.blue,
        title: const Text(
          'Panduan mengeset aplikasi',
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
                builder: (context) => const AdminGuidePage(),
              ),
            );
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
            _buildStepPage(
              context,
              '1. Buka aplikasi Pengaturan (Settings), kemudian cari tab Layar Kunci (Lock Screen). Setelah menemukannya, tekan tab Layar Kunci.',
              'assets/img/setting_1.jpg',
            ),
            _buildStepPage(
              context,
              '2. Kemudian cari tab Pintasan (Shortcuts), dan tekan tab Pintasan.',
              'assets/img/setting_2.jpg',
            ),
            _buildStepPage(
              context,
              '3. Dalam tab pintasan akan ada pilihan pintasan untuk bagian kiri dan bagian kanan layar kunci. Anda dapat memilih salah satunya untuk menjadikan aplikasi Disacare muncul di layar kunci.',
              'assets/img/setting_3.jpg',
            ),
            _buildStepPage(
              context,
              '4. Selanjutnya, cari aplikasi Disacare dan tekan aplikasi Disacare agar dapat muncul di layar kunci.',
              'assets/img/setting_4.jpg',
            ),
            _buildStepPage(
              context,
              '5. "Setelah menekan aplikasi Disacare, nama aplikasi Disacare akan muncul di bagian pintasan yang Anda pilih.',
              'assets/img/setting_5.jpg',
            ),
            _buildStepPage(
              context,
              '6. Selamat, aplikasi Disacare telah muncul di layar kunci Anda dan dapat diakses dengan cepat.',
              'assets/img/setting_6.jpg',
            ),
          ],
        ),
      ),
      bottomNavigationBar: _currentPageIndex == 5
          ? Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: blue, foregroundColor: Colors.white),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const AdminGuidePage(),
                    ),
                  );
                },
                child: const Text(
                  'Selesai',
                  style: TextStyle(fontSize: 22),
                ),
              ),
            )
          : null,
    );
  }

  Widget _buildStepPage(BuildContext context, String text, String? imagePath) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 10),
          Text(
            text,
            style: const TextStyle(
              fontSize: 15,
            ),
            textAlign: TextAlign.justify,
          ),
          const SizedBox(height: 15),
          if (imagePath != null)
            Image.asset(
              imagePath,
              width: 200,
              height: 430,
              fit: BoxFit.contain,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}