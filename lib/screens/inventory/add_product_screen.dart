import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../utils/colors.dart';
import '../../widgets/button.dart';
import '../product_screen.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({super.key});

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final _formKey = GlobalKey<FormState>();
  User? userId = FirebaseAuth.instance.currentUser;
  final titleController = TextEditingController();
  final priceController = TextEditingController();
  final qtyController = TextEditingController();
  final detailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: true,
          centerTitle: true,
          backgroundColor: primaryColor,
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

                        Form(
                            key: _formKey,
                            child: Column(
                              children: [
                                SizedBox(height: 30),
                                TextFormField(
                                  controller: titleController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    labelText: 'Product Title',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter a ProductTitle";
                                    } else if (value.length < 3) {
                                      return 'Name must be more than 2 character';
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: priceController,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    labelText: 'Rs',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please enter a Amount ";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15),
                                TextFormField(
                                  controller: detailController,
                                  maxLines: 10,
                                  decoration: InputDecoration(
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(20.0),
                                    ),
                                    labelText: 'Add Product Detail',
                                  ),
                                  validator: (value) {
                                    if (value!.isEmpty) {
                                      return "Please Add Detail ";
                                    }
                                    return null;
                                  },
                                ),
                                SizedBox(height: 15),

                              ],
                            )),
                        SizedBox(height: 25),
                        RoundedButton(
                            title: "Save",
                            icon: Icons.save,
                            onTap: () async {
                              if (_formKey.currentState!.validate()) {
                                var title = titleController.text.trim();
                                var price = priceController.text.trim();
                                var qty = 0;
                                var detail = detailController.text.trim();

                                try {
                                  await FirebaseFirestore.instance
                                      .collection("inventoryProducts")
                                      .doc(title)
                                      .set({
                                    "createdAT": DateTime.now(),
                                    "userId": userId?.uid,
                                    "productTitle": title,
                                    "productPrice": price,
                                    "qty": qty,
                                    "detail": detail,
                                  }).then((value) => {
                                            Get.off(ProductScreen()),
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
            )
          ],
        ),
      ),
    );
  }
}
