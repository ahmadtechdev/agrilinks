import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../../utils/colors.dart';
import '../inventory/inventory_screen.dart';
import 'market_product_info.dart';
import 'my_market_adds.dart';
import '../../widgets/navbar.dart';
import '../newsfeed_screen.dart';

class MarketScreen extends StatefulWidget {
  @override
  State<MarketScreen> createState() => _MarketScreenState();
}

class _MarketScreenState extends State<MarketScreen> {
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
        title: const Text(
          "Market Place",
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
        toolbarHeight: MediaQuery.of(context).size.height /
            9, // Set your desired height here
      ),

      backgroundColor: wColor,
      // color: wColor,
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
                hintText: 'Search by product...',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder(
              stream:
              FirebaseFirestore.instance.collection("marketPlace").snapshots(),
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
                    var productName = doc['product'].toString().toLowerCase();
                    return productName.contains(searchQuery.toLowerCase());
                  }).toList();

                  return ListView.builder(
                    itemCount: filteredDocs.length,
                    itemBuilder: (context, index) {
                      var product = filteredDocs[index]['product'];
                      var qty = filteredDocs[index]['qty'];
                      var price = filteredDocs[index]['price'];
                      var location = filteredDocs[index]['location'];
                      var contact = filteredDocs[index]['contact'];
                      var description = filteredDocs[index]['description'];
                      var image = filteredDocs[index]['image'];

                      var docId = filteredDocs[index].id;

                      return GestureDetector(
                        onTap: (){
                          Get.to(() => MarketProduct(), arguments: {
                            'product': product,
                            'price': price,
                            'qty': qty,
                            'location': location,
                            'description': description,
                            'image': image,
                            'contact': contact,
                            'docId': docId,
                          });
                        },
                        child: Card(
                          color: wColor.withOpacity(0.9),
                          margin: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
                          child: ListTile(
                            leading: Container(
                              width: 120,
                              height: 150,
                              child: Image.network(
                                image,
                                fit: BoxFit.fill,
                              ), // Assuming the first two letters of the title are used for the initials
                            ),
                            title: Text(
                              product,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 24),
                            ),
                            subtitle: Text(
                              contact.toString(),
                            ),
                            trailing: Text(
                              "Qty: " + qty.toString(),
                              style: TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 15),
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
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: primaryColor,
        foregroundColor: wColor,
        onPressed: () {
          Get.to(() => MyMarketAdds());
        },
        label: Text("My Add"),
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
        currentIndex: 2,
        selectedItemColor: primaryColor,
        onTap: onTabTapped,
      ),
    );
  }
}
