import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../utils/colors.dart';
import 'broker_info.dart';
import 'inventory/inventory_screen.dart';
import 'market/market_screen.dart';
import '../widgets/navbar.dart';
import 'newsfeed_screen.dart';

class HireBroker extends StatefulWidget {
  const HireBroker({super.key});

  @override
  State<HireBroker> createState() => _HireBrokerState();
}

class _HireBrokerState extends State<HireBroker> {
  User? userId = FirebaseAuth.instance.currentUser;
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  void onTabTapped(int index) {
    if (index == 0) {
      Get.to(() => InventoryScreen());
    } else if (index == 1) {
      Get.to(() => NewsFeedScreen());
    } else if (index == 2) {
      Get.to(() => MarketScreen());
    }
  }

  Future<void> _launchURL(Uri url) async {
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication,);
    } else {
      throw 'Could not launch ${url.toString()}'; // Use Uri.toString()
    }
  }

  Future<void> _openWhatsApp(String phoneNumber) async {
    final whatsappUrl = Uri.parse("https://wa.me/92$phoneNumber");
    await _launchURL(whatsappUrl);
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final phoneUrl = Uri.parse("tel:92$phoneNumber");
    await _launchURL(phoneUrl);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          "Hire Broker",
          style: TextStyle(
              color: wColor, fontSize: 25, fontWeight: FontWeight.w900),
        ),
        foregroundColor: wColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 9,
      ),
      backgroundColor: wColor,
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              decoration: InputDecoration(
                hintText: 'Search by city...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance.collection("users").snapshots(),
              builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return const Text("Something went wrong!");
                }
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CupertinoActivityIndicator(),
                  );
                }
                if (snapshot.data!.docs.isEmpty) {
                  return const Center(
                    child: Text(
                      "No data Found!",
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 18),
                    ),
                  );
                }

                if (snapshot.data != null) {
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var cityName = doc['cityName'].toString().toLowerCase();
                    return cityName.contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var userEmail = filteredDocs[index]['userEmail'];
                      var userName = filteredDocs[index]['userName'];
                      var cityName = filteredDocs[index]['cityName'];
                      var UserPhone = filteredDocs[index]['userPhone'];
                      var docId = filteredDocs[index].id;

                      return GestureDetector(
                        onTap: (){
                          Get.to(() => BrokerInfo(), arguments: {
                          'userEmail': userEmail,
                          'UserName': userName,
                          'cityName': cityName,
                          'UserPhone': UserPhone,
                          'image': 'assets/images/broker.png',
                          'docId': docId,
                          });
                        },
                        child: Card(
                          color: wColor.withOpacity(0.9),
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: ListTile(
                            leading: Container(
                              width: 80,
                              height: 80,
                              child: Image.asset(
                                'assets/images/broker.png',
                                fit: BoxFit.fill,
                              ),
                            ),
                            title: Text(
                              userName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 20),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(UserPhone.toString()),
                                Text(userEmail.toString()),
                                Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(MdiIcons.whatsapp, color: Colors.green),
                                      onPressed: () => _openWhatsApp(UserPhone),
                                    ),
                                    IconButton(
                                      icon: Icon(Icons.phone, color: Colors.blue),
                                      onPressed: () => _makePhoneCall(UserPhone),
                                    ),

                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                }
                return Container();
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.newspaper),
            label: 'NewsFeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Market',
          ),
        ],
        currentIndex: 2,
        selectedItemColor: primaryColor,
        onTap: onTabTapped,
      ),
    );
  }
}
