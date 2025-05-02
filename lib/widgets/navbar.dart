
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/colors.dart';
import '../screens/inventory/add_product_screen.dart';
import '../screens/chatbot.dart';
import '../screens/hire_broker.dart';
import '../screens/inventory/inventory_screen.dart';
import '../screens/market/my_market_adds.dart';
import '../screens/signin_screen.dart';
import '../screens/weather_page.dart';

class NavBar extends StatelessWidget {
  const NavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final User? user = _auth.currentUser;

    String displayName = "";
    String userEmail = "";

    if (user != null) {
      // displayName = user.displayName ?? ""; // Use nullish coalescing operator (??)
      userEmail = user.email ?? "";
    }

    return Drawer(
      backgroundColor: wColor,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          UserAccountsDrawerHeader(
            accountName: Text(
              "Welcome to Agrilinks",
              style: TextStyle(
                  fontSize: 18, color: wColor, fontWeight: FontWeight.bold),
            ),
            accountEmail: Text(
              userEmail,
              style: TextStyle(
                  fontSize: 16, color: wColor, fontWeight: FontWeight.bold),
            ),
            currentAccountPicture: CircleAvatar(
              child: ClipOval(
                child: Image.asset('assets/logo.png'),
              ),
            ),
            decoration: BoxDecoration(
              color: primaryColor,
            ),
          ),
          ListTile(
            leading: Icon(MdiIcons.storeEdit),
            title: Text(
              'Inventory',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => InventoryScreen());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.cardPlus),
            title: Text(
              'Add New Product',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => AddProductScreen());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.shopping),
            title: Text(
              'My Market Adds',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => MyMarketAdds());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.faceManProfile),
            title: Text(
              'Hire a Broker',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => HireBroker());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.weatherCloudy),
            title: Text(
              'Weather',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => WeatherPage());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.chat),
            title: Text(
              'AgriBot',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              Get.to(() => ChatScreen());
            },
          ),
          ListTile(
            leading: Icon(MdiIcons.logout),
            title: Text(
              'Sign out',
              style: TextStyle(
                  fontSize: 17, color: primaryColor, fontWeight: FontWeight.bold),
            ),
            onTap: () {
              FirebaseAuth.instance.signOut();
              Get.off(() => SignInScreen());
            },
          )
        ],
      ),
    );
  }
}
