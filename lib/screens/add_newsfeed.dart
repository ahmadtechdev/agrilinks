// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import '../widgets/btn.dart';
import 'inventory_screen.dart';
import 'market_screen.dart';
import 'newsfeed_screen.dart';

class AddNewsFeedScreen extends StatefulWidget {
  @override
  State<AddNewsFeedScreen> createState() => _AddNewsFeedScreenState();
}

class _AddNewsFeedScreenState extends State<AddNewsFeedScreen> {
  final postController = TextEditingController();
  final titleController = TextEditingController();
  String UserName="";
  int likes=0;
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;


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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: pColor,
        title: Text(
          "Add NewsFeed",
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
      // color: wColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.only(top: 40),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 15),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [

                    Text("Post", style: TextStyle(fontSize: 32, fontWeight: FontWeight.w800),),
                    SizedBox(height: 15),
                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFormField(
                            controller: titleController,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Title',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please enter a title ";
                              }
                              return null;
                            },
                          ),
                          SizedBox(height: 15),
                          TextFormField(
                            controller: postController,
                            maxLines: 10,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(20.0),
                              ),
                              labelText: 'Add Post Detail',
                            ),
                            validator: (value) {
                              if (value!.isEmpty) {
                                return "Please Add Detail ";
                              }
                              return null;
                            },
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 40),

                    RoundedButton(
                        title: "Post",
                        icon: Icons.post_add,
                        onTap: () async {
                          if (_formKey.currentState!.validate()) {
                            var post = postController.text.trim();
                            var postTitle = titleController.text.trim();

                            try {
                              await FirebaseFirestore.instance
                                  .collection("newsFeed")
                                  .doc()
                                  .set({
                                "createdAT": DateTime.now(),
                                "userId": userId?.uid,
                                "postTitle": postTitle,
                                "post": post,
                                "likes": likes,

                              }).then((value) => {
                                Get.off(NewsFeedScreen()),
                              });
                            } catch (e) {
                              print("Error $e");
                            }
                          }
                        })
                  ],
                ),
              ),
            ],
          ),
        ),
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
        selectedItemColor: pColor,
        onTap: onTabTapped,
      ),
    );
  }
}
