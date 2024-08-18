import 'package:flutter/material.dart';

class MenuItem extends StatelessWidget {
  const MenuItem({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 50,
          child: Row(
            children: [
              IconButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => SimpleDialog(
                        title: const Text('Hapus Berita'),
                        contentPadding: const EdgeInsets.all(20),
                        children: [
                          const Text(
                              'Apakah anda yakin ingin menghapus berita ini?'),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              TextButton(
                                onPressed: () {
                                  
                                },
                                child: const Text('iya'),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pop(context);
                                },
                                child: const Text('tidak'),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                  icon: const Icon(Icons.delete)),
              GestureDetector(
                onTap: () {},
                child: const Text('Hapus Berita'),
              )
            ],
          ),
        )
      ],
    );
  }
}
