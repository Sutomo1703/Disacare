import 'package:disacare/pages/user/map_page_user.dart';
import 'package:disacare/style/color.dart';
import 'package:flutter/material.dart';

class UserMapTutorialPage extends StatefulWidget {
  const UserMapTutorialPage({super.key});

  @override
  State<UserMapTutorialPage> createState() => _UserMapTutorialPageState();
}

class _UserMapTutorialPageState extends State<UserMapTutorialPage> {
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
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: const Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
        title: const Text(
          'Panduan penggunaan map',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: PageView(
          controller: _pageController,
          children: [
            _buildStepPage(
              context,
              '1. Setelah Anda membuka peta, tampilan akan muncul seperti gambar di bawah ini. Ikon penanda berwarna merah menunjukkan posisi Anda saat ini.',
              'assets/img/map_main.png',
            ),
            _buildStepPage(
              context,
              '2. Pada fitur peta, Anda dapat melakukan banyak hal. Jika Anda menekan sebuah lokasi di peta, Anda akan diminta untuk menambahkan lokasi tersebut, lalu mengisi keterangan lokasi.',
              'assets/img/nama_lokasi.png',
            ),
            _buildStepPage(
              context,
              '3. Setelah mengisi keterangan lokasi, Anda dapat memberikan ulasan atau review. Anda dapat memberikan nilai rating tingkat aksesibilitas, deskripsi mengenai lokasi tersebut, dan menyertakan gambar. Jika sudah sesuai, tekan tombol "Post" untuk mengirim ulasan Anda.',
              'assets/img/review_page.png',
            ),
            _buildStepPage(
              context,
              '4. Setelah mengirim ulasan, Anda akan kembali ke halaman peta. Lokasi yang Anda tambahkan akan ditandai dengan ikon penanda berwarna biru. Anda dapat melihat detail lokasi dengan menekan ikon biru, yang akan menampilkan nama lokasi, rating, jalan, serta Anda dapat memberikan ulasan, melihat ulasan pengguna lain, dan menyimpan lokasi.',
              'assets/img/lihat_detail.png',
            ),
            _buildStepPage(
              context,
              '5. Anda dapat melakukan pencarian lokasi untuk memudahkan mencari lokasi yang diinginkan. Pencarian lokasi biasanya memakan waktu sekitar 3 - 5 detik untuk mengambil data.',
              'assets/img/pencarian_lokasi.png',
            ),
            _buildStepPage(
              context,
              '6. Sekian tutorial cara menggunakan peta. Diharapkan agar semua pengguna dapat berkontribusi dengan memberikan informasi yang dapat membantu pengguna lain.',
              null,
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
                      builder: (context) => const UserMapPage(),
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
              width: 200, // Adjust the width here
              height: 430, // Add height to maintain aspect ratio
              fit: BoxFit.contain,
            ),
          const Spacer(),
        ],
      ),
    );
  }
}
