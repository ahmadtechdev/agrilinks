// ignore_for_file: prefer_const_constructors

import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:permission_handler/permission_handler.dart';

import '../colors.dart';
import '../widgets/btn.dart';
import 'inventory_screen.dart';
import 'market_screen.dart';
import 'my_market_adds.dart';
import 'newsfeed_screen.dart';

class AddMarketScreen extends StatefulWidget {
  @override
  State<AddMarketScreen> createState() => _AddMarketScreenState();
}

class _AddMarketScreenState extends State<AddMarketScreen> {

  final _formKey = GlobalKey<FormState>();

  final contactController = TextEditingController();
  final qtyController = TextEditingController();
  final locationController = TextEditingController();
  final descController = TextEditingController();
  User? userId = FirebaseAuth.instance.currentUser;
  String? _selectedProduct;
  List<String> _products = [];

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


  String imageUrl='';

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
          "Add Product",
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [

                      IconButton(onPressed: () async {
                        ImagePicker imagepicker = ImagePicker();
                        XFile? file = await imagepicker.pickImage(source: ImageSource.gallery);
                        print('${file?.path}');

                        if(file==null) return;
                        String uniqueFilename = DateTime.now().microsecondsSinceEpoch.toString();
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference refrenceDirImages=referenceRoot.child('images');

                        Reference refrenceImageToUpload = refrenceDirImages.child(uniqueFilename);

                        try{
                          await refrenceImageToUpload.putFile(File(file!.path));
                          imageUrl=await refrenceImageToUpload.getDownloadURL();
                          print(imageUrl);
                        }catch(error){
                          print(error);
                        }


                      }, icon: Icon(Icons.camera_alt)),
                      SizedBox(height: 15),
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
                            return "Please enter a Quantity ";
                          } else if (1 > int.parse(value)) {}
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      TextFormField(
                        controller: locationController,
                        style: const TextStyle(
                            color: pColor, fontSize: 17.0),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.location_on,
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
                            labelText: 'Location',
                            labelStyle: TextStyle(
                                color: pColor.withOpacity(0.8))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a Location ";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),
                      TextFormField(
                        controller: contactController,
                        style: const TextStyle(
                            color: pColor, fontSize: 17.0),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.contact_emergency,
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
                            labelText: 'Contact',
                            labelStyle: TextStyle(
                                color: pColor.withOpacity(0.8))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a number ";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 15),

                      TextFormField(
                        maxLines: 4,
                        controller: descController,
                        style: const TextStyle(
                            color: pColor, fontSize: 17.0),
                        decoration: InputDecoration(
                            prefixIcon: Icon(Icons.description,
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
                            labelText: 'Description',
                            labelStyle: TextStyle(
                                color: pColor.withOpacity(0.8))),
                        validator: (value) {
                          if (value!.isEmpty) {
                            return "Please enter a Description ";
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 25),
                      Center(
                          child: RoundedButton(
                              title: "Post",
                              icon: Icons.post_add,
                              onTap: () async {
                                if (_formKey.currentState!.validate()) {
                                  var product = _selectedProduct;
                                  int qty = int.parse(qtyController.text.trim());
                                  var location = locationController.text.trim();
                                  var contact = contactController.text.trim();
                                  var description = descController.text.trim();
                                  var documentSnapshot = await FirebaseFirestore
                                      .instance
                                      .collection("inventoryProducts")
                                      .doc(product)
                                      .get();
                                  int currentQty =
                                  documentSnapshot.data()?['qty'];
                                  currentQty ??= 0;
                                  var price = documentSnapshot.data()?['productPrice'];
                                  currentQty ??= 0;

                                  print(currentQty);

                                  if(qty>currentQty){
                                    SnackBar(
                                      content: Text("Not enough quanity, available is " + currentQty.toString()),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(22),
                                      ),
                                      margin: EdgeInsets.only(
                                          bottom: 8, right: 20, left: 20),
                                    );
                                  }else{
                                    var newqty = currentQty-qty;
                                    print(newqty);
                                    try {
                                      await FirebaseFirestore.instance
                                          .collection(
                                          "inventoryProducts")
                                          .doc(product)
                                          .update({
                                        'qty': newqty,

                                      }).then((value) async => {
                                      await FirebaseFirestore.instance
                                          .collection("marketPlace")
                                          .doc()
                                          .set({
                                      "createdAT": DateTime.now(),
                                      "userId": userId?.uid,
                                      "product": product,
                                      "qty": qty,
                                      "price": price,
                                      "location": location,
                                      "contact": contact,
                                      "image": imageUrl,
                                      "description": description,

                                      }).then((value) => {
                                      Get.off(MyMarketAdds()),
                                      })
                                      });

                                  } catch (e) {
                                    print("Error $e");
                                  }
                                  }

                                }
                              }),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

    );
  }
  uploadImage() async {
    final firebaseStorage = FirebaseStorage.instance;
    final imagePicker = ImagePicker();
    PickedFile image;
    //Check Permissions
    // Request permission for photos access
    await Permission.photos.request();

    var permissionStatus = await Permission.photos.status;

    if (permissionStatus.isGranted){
      //Select Image
      final image = await imagePicker.pickImage(source: ImageSource.gallery);


      if (image != null){
        var file = File(image.path);
        final imageName = image.name;
        //Upload to Firebase
        final uploadTask = firebaseStorage.ref().child('images/$imageName').putFile(file);
        final snapshot = await uploadTask.whenComplete(() => null);

        // Get the download URL after successful upload
        final downloadUrl = await snapshot.ref.getDownloadURL();
        setState(() {
          imageUrl = downloadUrl;
        });
      } else {
        print('No Image Path Received');
      }
    } else {
      print('Permission not granted. Try Again with permission access');
    }
  }
}
