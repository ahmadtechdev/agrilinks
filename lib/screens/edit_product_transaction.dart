import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../widgets/btn.dart';
import 'product_transaction.dart';

class EditTransaction extends StatefulWidget {
  const EditTransaction({super.key});

  @override
  State<EditTransaction> createState() => _EditTransactionState();
}

class _EditTransactionState extends State<EditTransaction> {
  String qty = Get.arguments['qty'].toString();
  String title = Get.arguments['title'].toString();
  String docId = Get.arguments['docId'].toString();
  String type = Get.arguments['type'].toString();
  final _formKey = GlobalKey<FormState>();

  User? userId = FirebaseAuth.instance.currentUser;

  final qtyController = TextEditingController();

  final dateController = TextEditingController();
  String _selectedType = Get.arguments['type'].toString();


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: pColor,
        title: const Text(
          "Edit Transaction",
          style: TextStyle(
              color: wColor, fontSize: 25, fontWeight: FontWeight.w900),
        ),
        foregroundColor: wColor,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          ),
        ),
        toolbarHeight: MediaQuery.of(context).size.height /
            9, // Set your desired height here
      ),

      backgroundColor: wColor,
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height *
              0.8, // Adjust the height as needed
      
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [

              Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment:
                  CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Center(
                      child: Text(
                          'Edit $title transaction' ,style: const TextStyle(
                      color: pColor, fontSize: 20, fontWeight: FontWeight.w900),),
                    ), // Title of the modal bottom sheet

                    const SizedBox(height: 15),
                    TextFormField(
                      controller: qtyController..text = qty.toString(),
                      style: const TextStyle(
                          color: pColor, fontSize: 17.0),
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                            Icons.production_quantity_limits,
                            color: pColor.withOpacity(0.6)),
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
                        labelText: 'Quantity',
                        labelStyle: TextStyle(
                            color: pColor.withOpacity(0.8)),
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return "Please enter a quantity";
                        } else if (1 > int.parse(value)) {
                          // Add your validation logic here
                          return "Please enter a valid quantity";
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 15),
                    DropdownButtonFormField(
                      style: const TextStyle(
                          color: pColor, fontSize: 17.0),
                      decoration: InputDecoration(
                        prefixIcon: Icon(Icons.merge_type,
                            color: pColor.withOpacity(0.6)),
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
                        labelText: 'Transaction Type',
                        labelStyle: TextStyle(
                            color: pColor.withOpacity(0.8)),
                      ),
                      value: _selectedType,
                      items: [
                        const DropdownMenuItem(
                          value: "Received",
                          child: Text("Received"),
                        ),
                        const DropdownMenuItem(
                          value: "Send",
                          child: Text("Send"),
                        ),
                      ],
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedType = newValue!;
                        });
                      },
                    ),
                    const SizedBox(height: 15),
                    RoundedButton(
                        title: "Update",
                        icon: Icons.update,
                        onTap: () async {
                          if (_formKey.currentState!
                              .validate()) {
                            var qty =
                            qtyController.text.trim();
                            var type = _selectedType;
                            var documentSnapshot1 =
                            await FirebaseFirestore
                                .instance
                                .collection(
                                "productTransaction")
                                .doc(docId)
                                .get();
                            var transQty = documentSnapshot1
                                .data()?['qty'];
                            var transType = documentSnapshot1
                                .data()?['type'];

                            String titleProduct = title;
                            var documentSnapshot =
                            await FirebaseFirestore
                                .instance
                                .collection(
                                "inventoryProducts")
                                .doc(titleProduct)
                                .get();
                            var currentQty = documentSnapshot
                                .data()?['qty'];
                            currentQty ??= 0;
                            int newQty;
                            print("currentQty: $currentQty");
                            if (transType == "Send") {
                              newQty = currentQty +
                                  int.parse(transQty.toString());
                            } else {
                              newQty = currentQty -
                                  int.parse(transQty.toString());
                            }
                            print("NewQty: " + newQty.toString());

                            int updateQty;
                            if (type == "Send") {
                              updateQty = newQty -
                                  int.parse(qty.toString());
                            } else {
                              updateQty = newQty +
                                  int.parse(qty.toString());
                            }
                            print("updateQty: " + updateQty.toString());
                            if (type == "Send" &&
                                updateQty < 0) {
                              ScaffoldMessenger.of(context)
                                  .showSnackBar(
                                SnackBar(
                                  content: Text(
                                      "Quantity in transaction is $currentQty"),
                                  backgroundColor: Colors.red,
                                  behavior: SnackBarBehavior
                                      .floating,
                                  shape:
                                  RoundedRectangleBorder(
                                    borderRadius:
                                    BorderRadius.circular(
                                        22),
                                  ),
                                  margin:
                                  EdgeInsets.only(
                                      bottom:8,
                                      right: 20,
                                      left: 20),
                                ),
                              );
                            } else {
                              await FirebaseFirestore.instance
                                  .collection(
                                  "productTransaction")
                                  .doc(docId)
                                  .update({
                                'qty': qty,
                                'type': _selectedType
                              }).then((value) async => {
                                await FirebaseFirestore
                                    .instance
                                    .collection(
                                    "inventoryProducts")
                                    .doc(title)
                                    .update({
                                  'qty': updateQty,
                                }).then((value) => {
                                  Get.off(
                                      const TransactionHistory(),arguments: {
                                        'title':titleProduct,
                                  }),
                                  print(
                                      "Product transaction update")
                                })
                              });
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
    );
  }
}
