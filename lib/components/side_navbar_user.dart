import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/model/user_model.dart';
import 'package:disacare/pages/login_page.dart';
import 'package:disacare/pages/user/panduan_user.dart';
import 'package:disacare/pages/user/profile_page_user.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UserSideNavbar extends StatefulWidget {
  const UserSideNavbar({super.key});

  @override
  State<UserSideNavbar> createState() => _SideNavbarState();
}

class _SideNavbarState extends State<UserSideNavbar> {
  //Firebase
  final FirebaseAuth auth = FirebaseAuth.instance;
  User? user = FirebaseAuth.instance.currentUser;
  UserModel loggedInUser = UserModel();

  //Retrieve Collection of User
  @override
  void initState() {
    super.initState();
    FirebaseFirestore.instance
        .collection("users")
        .doc(user!.uid)
        .get()
        .then((value) {
      loggedInUser = UserModel.fromMap(value.data());

      setState(() {});
    });
  }

  //Logout
  signOut() async {
    await auth.signOut();
    Navigator.pushReplacement(
        // ignore: use_build_context_synchronously
        context, MaterialPageRoute(builder: (context) => const LoginPage()));
    Fluttertoast.showToast(msg: "Logout Successfully");
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              '${loggedInUser.username}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
            accountEmail: Text(
              '${loggedInUser.email}',
            ),
            currentAccountPicture: CircleAvatar(
                child: loggedInUser.gambar != null
                    ? ClipOval(
                        child: Image.network(
                          '${loggedInUser.gambar}',
                          fit: BoxFit.cover,
                          height: 100,
                          width: 100,
                        ),
                      )
                    : const CircleAvatar(
                        child: Icon(
                          Icons.person,
                        ),
                      )),
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
          ),
          ListTile(
            leading: const Icon(
              Icons.person,
              size: 28,
            ),
            title: const Text(
              'Profile',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserProfilePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.book,
              size: 28,
            ),
            title: const Text(
              'Panduan',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const UserGuidePage(),
                ),
              );
            },
          ),
          ListTile(
            leading: const Icon(
              Icons.logout,
              size: 28,
            ),
            title: const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            onTap: () {
              signOut();
            },
          ),
        ],
      ),
    );
  }
}
