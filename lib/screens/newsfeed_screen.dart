// ignore_for_file: prefer_const_constructors


import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../utils/colors.dart';
import 'inventory/add_inventory/add_inventory_screen.dart';
import 'newsfeed/add_newsfeed.dart';
import 'inventory/inventory_screen.dart';
import 'market/market_screen.dart';
import '../widgets/navbar.dart';

class NewsFeedScreen extends StatefulWidget {
  @override
  State<NewsFeedScreen> createState() => _NewsFeedScreenState();
}

class _NewsFeedScreenState extends State<NewsFeedScreen> {
  String imageURl="";
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

  User? userId = FirebaseAuth.instance.currentUser;
  void onTabTapped(int index) {
    if (index == 0) {
      Get.to(() => InventoryScreen());
    } else if (index == 1) {
      Get.to(() => NewsFeedScreen());
    } else if (index == 2) {
      Get.to(() => MarketScreen());
    }
  }

  int _selectedIndex = 1;

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
        // automaticallyImplyLeading: false,
        centerTitle: true,
        backgroundColor: primaryColor,
        title: Text(
          "NewsFeed",
          style: TextStyle(
              color: wColor,
              fontSize: 25,
              fontWeight: FontWeight.w900),
        ),
        foregroundColor: wColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height / 9, // Set your desired height here
      ),

      backgroundColor: wColor,
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("newsFeed")
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
                      color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18),
                ));
          }

          if (snapshot.data != null) {
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {

                  var post = snapshot.data!.docs[index]['post'];
                  var title = snapshot.data!.docs[index]['postTitle'].toString();
                  var likes = snapshot.data!.docs[index]['likes'];

                  var docId = snapshot.data!.docs[index].id;
                  imageURl = "assets/images/publication.png";

                  return Card(
                    color: wColor.withOpacity(0.9),
                    margin: EdgeInsets.symmetric(horizontal: 15,vertical: 5),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Image.asset(
                          imageURl,
                          fit: BoxFit.fill,

                        ), // Assuming the first two letters of the title are used for the initials
                      ),
                      title: Text(title),
                      subtitle: Text(
                        post,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min, // Row doesn't expand
                        children: [
                          IconButton(
                            icon: Icon(
                             Icons.favorite,
                              color: Colors.red,
                            ),
                            onPressed: () async{
                              await FirebaseFirestore.instance
                                  .collection("newsFeed")
                                  .doc(docId.toString())
                                  .update({
                                'likes': likes++,
                              }).then((value) => {
                                Get.off(NewsFeedScreen()),
                              });
                              },
                          ),
                          Text(likes.toString()), // Display likes count
                        ],
                      ),
                    )
                    ,
                  );
                });
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: primaryColor,
        foregroundColor: secondaryColor,
        onPressed: () {
          Get.to(() => AddNewsFeedScreen());
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
        currentIndex: 1,
        selectedItemColor: primaryColor,
        onTap: onTabTapped,
      ),
    );
  }
}
