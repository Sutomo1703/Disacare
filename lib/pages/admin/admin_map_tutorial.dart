import 'package:disacare/pages/admin/map_page_admin.dart';
import 'package:disacare/style/color.dart';
import 'package:flutter/material.dart';

class AdminMapTutorialPageState extends StatefulWidget {
  const AdminMapTutorialPageState({super.key});

  @override
  State<AdminMapTutorialPageState> createState() => _AdminMapTutorialPageStateState();
}

class _AdminMapTutorialPageStateState extends State<AdminMapTutorialPageState> {
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
          'Map Tutorial',
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
              '1. Setelah anda membuka map, tampilan akan muncul seperti gambar di bawah ini. Icon marker warna merah merupakan posisi anda saat ini.',
              'assets/img/map_main.png',
            ),
            _buildStepPage(
              context,
              '2. Pada fitur map anda dapat melakukan banyak hal. Apabila anda menekan sebuah lokasi di map, maka anda akan diminta untuk menambah lokasi, kemudian anda harus mengisi keterangan lokasi.',
              'assets/img/nama_lokasi.png',
            ),
            _buildStepPage(
              context,
              '3. Setelah mengisi keterangan lokasi, anda dapat memberikan sebuah ulasan atau review. Dimana anda akan memberikan nilai rating tingkat aksesibilitas, memberikan deskripsi mengenai lokasi tersebut, dan anda juga dapat menyertakan gambar. Apabila sudah sesuai, maka anda dapat menekan tombol post untuk mengirim ulasan anda.',
              'assets/img/review_page.png',
            ),
            _buildStepPage(
              context,
              '4. Setelah mengisi review, anda akan dikembalikan ke halaman map. Anda dapat melihat lokasi yang telah anda tambahkan pada map, dengan ikon marker warna biru. Anda juga dapat melihat detail dari lokasi dengan menekan ikon warna biru yang akan menampilkan nama lokasi, rating lokasi, jalan, dan anda dapat memberikan ulasan, melihat ulasan pengguna lain, dan menyimpan lokasi.',
              'assets/img/lihat_detail.png',
            ),
            _buildStepPage(
              context,
              '5. Anda dapat melakukan pencarian lokasi, untuk memudahkan mencari lokasi yang diinginkan.',
              'assets/img/pencarian_lokasi.png',
            ),
            _buildStepPage(
              context,
              '6. Sekian tutorial dari cara menggunakan map. Diharapkan agar semua pengguna dapat memberikan kontribusi dengan memberikan informasi yang dapat membantu pengguna lain.',
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
                      builder: (context) => const AdminMapPage(),
                    ),
                  );
                },
                child: const Text('Selesai', style: TextStyle(
                  fontSize: 22
                ),),
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

