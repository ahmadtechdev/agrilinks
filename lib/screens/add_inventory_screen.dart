// ignore_for_file: prefer_const_constructors

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

import '../colors.dart';
import '../widgets/btn.dart';
import 'add_product_screen.dart';
import 'inventory_screen.dart';
import 'market_screen.dart';
import 'newsfeed_screen.dart';

class AddInventoryScreen extends StatefulWidget {
  @override
  State<AddInventoryScreen> createState() => _AddInventoryScreenState();
}

class _AddInventoryScreenState extends State<AddInventoryScreen> {
  final qtyController = TextEditingController();

  final dateController = TextEditingController();
  String _selectedType ="Received";
  String? _selectedProduct;
  List<String> _products = [];
  final _formKey = GlobalKey<FormState>();
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

  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  void initState() {
    super.initState();
    _fetchProducts();
  }

  Future<void> _fetchProducts() async {
    QuerySnapshot snapshot =
        await FirebaseFirestore.instance.collection('inventoryProducts').get();
    setState(() {
      _products = snapshot.docs
          .map((doc) =>
              (doc.data() as Map<String, dynamic>)['productTitle'] as String? ??
              '')
          .toList();

      print(_products);
      _selectedProduct = _products.isNotEmpty ? _products[0] : null;
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
            "Add Inventory",
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
        child: Stack(
          children: [

            Padding(
              padding: EdgeInsets.only(top: 40),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [

                        Container(
                          alignment: Alignment.center,
                          height: 200.0,
                          child:
                              Lottie.asset("assets/Animation - inventory.json"),
                        ),
                        Form(
                            key: _formKey,
                            child: Column(
                              children: [

                                DropdownButtonFormField(
                                  style: const TextStyle(
                                      color: pColor, fontSize: 17.0),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.pages,
                                          color: pColor.withOpacity(0.6)),
                                      // suffixIcon: Icon(Icons.email),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                          color: pColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius:
                                            BorderRadius.circular(25.0),
                                        borderSide: BorderSide(
                                          color: pColor.withOpacity(0.6),
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Product',
                                      labelStyle: TextStyle(
                                          color: pColor.withOpacity(0.8))),
                                  value: _selectedProduct,
                                  hint: Text(
                                    'Select Product',
                                    style: TextStyle(
                                        color: pColor.withOpacity(0.8)),
                                  ),
                                  items: _products.map((product) {
                                    return DropdownMenuItem<String>(
                                      value: product,
                                      child: Text(product),
                                    );
                                  }).toList(),
                                  onChanged: (newValue) {
                                    setState(() {
                                      _selectedProduct = newValue!;
                                    });
                                  },
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: qtyController,
                                  style: const TextStyle(
                                      color: pColor, fontSize: 17.0),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.production_quantity_limits,
                                          color: pColor.withOpacity(0.6)),
                                      // suffixIcon: Icon(Icons.email),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                          color: pColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide(
                                          color: pColor.withOpacity(0.6),
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Quantity',
                                      labelStyle: TextStyle(
                                          color: pColor.withOpacity(0.8))),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter a quantity ";
                                    } else if (1 > int.parse(value)) {}
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15),
                                DropdownButtonFormField(
                                  style: const TextStyle(
                                      color: pColor, fontSize: 17.0),
                                  decoration: InputDecoration(
                                      prefixIcon: Icon(Icons.merge_type,
                                          color: pColor.withOpacity(0.6)),
                                      // suffixIcon: Icon(Icons.email),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: const BorderSide(
                                          color: pColor,
                                          width: 2.0,
                                        ),
                                      ),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(25.0),
                                        borderSide: BorderSide(
                                          color: pColor.withOpacity(0.6),
                                          width: 2.0,
                                        ),
                                      ),
                                      labelText: 'Transaction Type',
                                      labelStyle: TextStyle(
                                          color: pColor.withOpacity(0.8))),
                                  items: [
                                    DropdownMenuItem(
                                      value: "Received",
                                      child: Text("Received"),
                                    ),
                                    DropdownMenuItem(
                                      value: "Send",
                                      child: Text("Send"),
                                    ),
                                  ],
                                  onChanged: (String? newValue) {
                                    setState(() {
                                      _selectedType =
                                      newValue!; // Update the selected value
                                    });
                                  },
                                ),
                              ],
                            )),
                        SizedBox(height: 25),
                        RoundedButton(
                            title: "Save",
                            icon: Icons.save,
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                var qty = qtyController.text.trim();

                                var title = _selectedProduct;
                                var type = _selectedType;
                                var documentSnapshot = await FirebaseFirestore
                                    .instance
                                    .collection("inventoryProducts")
                                    .doc(title)
                                    .get();
                                var currentQty =
                                    documentSnapshot.data()?['qty'];
                                currentQty ??= 0;
                                var newQty;

                                if(type=="Send"){
                                   newQty =currentQty - int.parse(qty);
                                }else{
                                  newQty = currentQty + int.parse(qty);
                                }
                                // var newQty = type=='send' ? int.parse(currentQty) - int.parse(qty) : currentQty + int.parse(qty);
                                if(newQty <0 && type=="Send"){
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text("Not enough quanity, available is " + currentQty.toString()),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 8, right: 20, left: 20),
                                    ),
                                  );
                                }else{

                                  try {
                                    await FirebaseFirestore.instance
                                        .collection("productTransaction")
                                        .doc()
                                        .set({
                                      "createdAT": DateTime.now(),
                                      "userId": userId?.uid,
                                      "title": title,
                                      "qty": qty,
                                      "type": type,
                                    }).then((value) async => {
                                      await FirebaseFirestore.instance
                                          .collection("inventoryProducts")
                                          .doc(title)
                                          .update({
                                        'qty': newQty,
                                      }).then((value) => {
                                        Get.off(
                                            InventoryScreen()),
                                      })
                                    });
                                  } catch (e) {

                                    print("Error $e");
                                  }
                                }

                              }
                            })
                      ],
                    ),
                  ),
                ],
              ),
            )
          ],
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
        currentIndex: 0,
        selectedItemColor: pColor,
        onTap: onTabTapped,
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: yColor,
        foregroundColor: pColor,
        onPressed: () {
          Get.to(() => AddProductScreen());
        },
        child: Icon(Icons.add),
      ),
    );
  }
}
