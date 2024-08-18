// import 'package:flutter/material.dart';
// import 'package:flutter_disacare_app/pages/alert_page.dart';
// import 'package:flutter_disacare_app/pages/main_home_page.dart';
// import 'package:flutter_disacare_app/pages/admin/map_page_admin.dart';
// import 'package:flutter_disacare_app/pages/admin/notification_page_admin.dart';
// import 'package:flutter_disacare_app/pages/admin/profile_page.dart';

// class navigationPage extends StatefulWidget {
//   const navigationPage({super.key});

//   @override
//   State<navigationPage> createState() => _HomePageState();
// }

// class _HomePageState extends State<navigationPage> {
//   //Bottom Navbar
//   int currentPageIndex = 0;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       bottomNavigationBar: NavigationBar(
//         backgroundColor: Colors.blue,
//         onDestinationSelected: (int index) {
//           setState(() {
//             currentPageIndex = index;
//           });
//         },
//         indicatorColor: Colors.white,
//         selectedIndex: currentPageIndex,
//         destinations: const <Widget>[
//           NavigationDestination(
//             selectedIcon: Icon(Icons.home),
//             icon: Icon(Icons.home_outlined),
//             label: 'Home',
//           ),
//           NavigationDestination(
//             selectedIcon: Icon(Icons.map),
//             icon: Icon(Icons.map_outlined),
//             label: 'Map',
//           ),
//           NavigationDestination(
//             selectedIcon: Icon(Icons.notifications),
//             icon: Icon(Icons.notifications_none_outlined),
//             label: 'Notification',
//           ),
//           NavigationDestination(
//             selectedIcon: Icon(Icons.person_2),
//             icon: Icon(Icons.person_2_outlined),
//             label: 'Profile',
//           ),
//         ],
//       ),
//       body: <Widget>[
//         // Home page
//         const HomePage(),

//         // Map page
//         const MapPage(),

//         // Alert page
//         const AlertPage(),

//         //Notification Page
//         const NotificationPage(),

//         //Profile Page
//         const ProfilePage(),
//       ][currentPageIndex],
//     );
//   }
// }
