
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import 'add_inventory_screen.dart';
import 'market_screen.dart';
import 'navbar.dart';
import 'newsfeed_screen.dart';
import 'product_info.dart';

class InventoryScreen extends StatefulWidget {
  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  String imageUrl = "";
  String searchQuery = "";
  TextEditingController searchController = TextEditingController();

  static const TextStyle optionStyle =
  TextStyle(fontSize: 30, fontWeight: FontWeight.bold);
  static const List<Widget> _widgetOptions = <Widget>[
    Text(
      'Index 0: Inventory',
      style: optionStyle,
    ),
    Text(
      'Index 1: Newsfeed',
      style: optionStyle,
    ),
    Text(
      'Index 2: Market',
      style: optionStyle,
    ),
  ];

  void onTabTapped(int index) {
    if (index == 0) {
      Get.to(() => InventoryScreen());
    } else if (index == 1) {
      Get.to(() => NewsFeedScreen());
    } else if (index == 2) {
      Get.to(() => MarketScreen());
    }
  }

  User? userId = FirebaseAuth.instance.currentUser;
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: NavBar(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: pColor,
        title: Image.asset(
          'assets/logo1.png',
          scale: 3,
        ),
        foregroundColor: wColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 7,
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
                hintText: 'Search products...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream: FirebaseFirestore.instance
                  .collection("inventoryProducts")
                  .where("userId", isEqualTo: userId?.uid)
                  .snapshots(),
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
                      ));
                }

                if (snapshot.data != null) {
                  var filteredDocs = snapshot.data!.docs.where((doc) {
                    var title = doc['productTitle'].toString().toLowerCase();
                    return title.contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        var timestampString = filteredDocs[index]['createdAT'];
                        DateTime timestamp =
                        DateTime.parse(timestampString.toDate().toString());
                        var formattedDate =
                            '${_getWeekday(timestamp)}, ${timestamp.day} ${_getMonth(timestamp)} ${timestamp.year % 100} . ${_formatHour(timestamp)}';

                        var title = filteredDocs[index]['productTitle'];
                        var price = filteredDocs[index]['productPrice'];
                        var qty = filteredDocs[index]['qty'];
                        var detail = filteredDocs[index]['detail'];

                        var docId = filteredDocs[index].id;
                        var imageUrl = "assets/images/parcel.png";

                        return InkWell(
                          onTap: () {
                            Get.to(() => ProductInfo(), arguments: {
                              'date': formattedDate,
                              'title': title,
                              'price': price,
                              'qty': qty,
                              'detail': detail,
                              'docId': docId,
                            });
                          },
                          child: Dismissible(
                            key: Key(docId),
                            direction: DismissDirection.startToEnd,
                            background: Container(
                              alignment: Alignment.centerLeft,
                              color: Colors.red,
                              child: const Padding(
                                padding: EdgeInsets.only(left: 20.0),
                                child: Icon(
                                  Icons.delete,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            onDismissed: (direction) async {
                              await FirebaseFirestore.instance
                                  .collection("inventoryProducts")
                                  .doc(docId)
                                  .delete();
                            },
                            child: Card(
                              color: wColor.withOpacity(0.9),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 15, vertical: 5),
                              child: ListTile(
                                leading: Image.asset(
                                  imageUrl,
                                  fit: BoxFit.fill,
                                ),
                                title: Text(
                                  title,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: pColor,
                                      fontSize: 24),
                                ),
                                subtitle: Text(
                                  formattedDate,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
                                ),
                                trailing: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      "RS $price",
                                      style: TextStyle(
                                          fontWeight: FontWeight.w900),
                                    ),
                                    SizedBox(
                                      width: 10.0,
                                    ),
                                    Card(
                                      color: pColor,
                                      child: Padding(
                                        padding: EdgeInsets.symmetric(
                                            vertical: 2, horizontal: 8),
                                        child: Text(
                                          qty.toString(),
                                          style: TextStyle(color: wColor),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          ),
                        );
                      });
                }
                return Container();
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: pColor,
        foregroundColor: yColor,
        onPressed: () {
          Get.to(() => AddInventoryScreen());
        },
        child: Icon(Icons.add),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(
              Icons.inventory,
            ),
            label: 'Inventory',
          ),
          BottomNavigationBarItem(
            icon: Icon(
              Icons.newspaper,
            ),
            label: 'NewsFeed',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Market',
          ),
        ],
        currentIndex: 0,
        selectedItemColor: pColor,
        onTap: onTabTapped,
      ),
    );
  }
}


// Function to get the weekday abbreviation
String _getWeekday(DateTime dateTime) {
  switch (dateTime.weekday) {
    case 1:
      return 'Mon';
    case 2:
      return 'Tue';
    case 3:
      return 'Wed';
    case 4:
      return 'Thu';
    case 5:
      return 'Fri';
    case 6:
      return 'Sat';
    case 7:
      return 'Sun';
    default:
      return '';
  }
}


// Function to get the month abbreviation
String _getMonth(DateTime dateTime) {
  switch (dateTime.month) {
    case 1:
      return 'Jan';
    case 2:
      return 'Feb';
    case 3:
      return 'Mar';
    case 4:
      return 'Apr';
    case 5:
      return 'May';
    case 6:
      return 'Jun';
    case 7:
      return 'Jul';
    case 8:
      return 'Aug';
    case 9:
      return 'Sep';
    case 10:
      return 'Oct';
    case 11:
      return 'Nov';
    case 12:
      return 'Dec';
    default:
      return '';
  }
}

// Function to format hour
String _formatHour(DateTime dateTime) {
  String period = 'am';
  int hour = dateTime.hour;
  if (hour >= 12) {
    period = 'pm';
    if (hour > 12) {
      hour -= 12;
    }
  }
  if (hour == 0) {
    hour = 12;
  }
  String minute = dateTime.minute.toString().padLeft(2, '0');
  return '$hour:$minute $period';
}