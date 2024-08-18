// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_disacare_app/pages/admin/admin_home.dart';
// import 'package:flutter_disacare_app/pages/login_page.dart';
// import 'package:flutter_disacare_app/pages/user/main_home_page.dart';

// class FirebasePage extends StatefulWidget {
//   const FirebasePage({super.key});

//   @override
//   State<FirebasePage> createState() => _FirebasePageState();
// }

// class _FirebasePageState extends State<FirebasePage> {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: StreamBuilder<User?>(
//         stream: FirebaseAuth.instance.authStateChanges(),
//         builder: (context, snapshot) {
//           User? user = FirebaseAuth.instance.currentUser;
//           FirebaseFirestore.instance
//               .collection('users')
//               .doc(user?.uid)
//               .get()
//               .then((DocumentSnapshot documentSnapshot) {
//             if (documentSnapshot.exists) {
//               if (documentSnapshot.get('role') == "User" && snapshot.data?.emailVerified == true) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const UserHomePage(),
//                   ),
//                 );
//               } else if (documentSnapshot.get('role') == "admin" && snapshot.data?.emailVerified == true) {
//                 Navigator.pushReplacement(
//                   context,
//                   MaterialPageRoute(
//                     builder: (context) => const AdminHomePage(),
//                   ),
//                 );
//               }
//             }
//           });
//           return const LoginPage();
//         },
//       ),
//     );
//   }
// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:disacare/pages/admin/admin_home.dart';
import 'package:disacare/pages/login_page.dart';
import 'package:disacare/pages/user/main_home_page.dart';
import 'package:disacare/pages/verification_page.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class FirebasePage extends StatefulWidget {
  const FirebasePage({super.key});

  @override
  State<FirebasePage> createState() => _FirebasePageState();
}

class _FirebasePageState extends State<FirebasePage> {
  Future<void> _navigateBasedOnRole(User user) async {
    final documentSnapshot = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    
    if (!mounted) return;  // Check if the widget is still mounted

    if (documentSnapshot.exists) {
      final role = documentSnapshot.get('role');
      if (user.emailVerified == true) {
        if (role == 'User') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserHomePage()),
          );
        } else if (role == 'admin') {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const AdminHomePage()),
          );
        }
      } else {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const VerificationPage()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Terjadi kesalahan'));
          } else if (snapshot.hasData) {
            final user = snapshot.data!;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              // Use addPostFrameCallback to ensure the navigation happens after the frame is drawn
              if (mounted) {
                _navigateBasedOnRole(user);
              }
            });
            return const Center(child: CircularProgressIndicator());
          } else {
            return const LoginPage();
          }
        },
      ),
    );
  }
}