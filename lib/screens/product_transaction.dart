
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../utils/colors.dart';
import '../widgets/button.dart';
import 'edit_product_transaction.dart';

class TransactionHistory extends StatefulWidget {
  const TransactionHistory({super.key});

  @override
  State<TransactionHistory> createState() => _TransactionHistoryState();
}

class _TransactionHistoryState extends State<TransactionHistory> {
  User? userId = FirebaseAuth.instance.currentUser;
  String title = Get.arguments['title'].toString();

  final qtyController = TextEditingController();

  final dateController = TextEditingController();
  String _selectedType = "Received";
  String? _selectedProduct;
  List<String> _products = [];


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: primaryColor,
        title: const Text(
          "Product Transaction",
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("productTransaction")
            .where("userId", isEqualTo: userId?.uid)
            .where("title", isEqualTo: title)
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
            return ListView.builder(
                shrinkWrap: true,
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var timestampString = snapshot.data!.docs[index]['createdAT'];
                  DateTime timestamp =
                      DateTime.parse(timestampString.toDate().toString());
                  var formattedDate =
                      '${_getWeekday(timestamp)}, ${timestamp.day} ${_getMonth(timestamp)} ${timestamp.year % 100} . ${_formatHour(timestamp)}';

                  var titleProduct = snapshot.data!.docs[index]['title'];
                  var type = snapshot.data!.docs[index]['type'];
                  var qty = snapshot.data!.docs[index]['qty'];
                  var docId = snapshot.data!.docs[index].id;
                  var imageUrl = "assets/images/parcel.png";

                  return Dismissible(
                    key: Key(docId), // Unique key for each item
                    direction:
                        DismissDirection.startToEnd, // Allow left swipe only
                    background: Container(
                      alignment: Alignment.centerLeft,
                      color: Colors.red, // Background color when swiping
                      child: const Padding(
                        padding: EdgeInsets.only(left: 20.0),
                        child: Icon(
                          Icons
                              .delete, // You can customize the icon for delete action
                          color: Colors.white,
                        ),
                      ),
                    ),
                    onDismissed: (direction) async {
                      // Handle swipe action, in this case, you can navigate to TransactionHistory screen
                      await FirebaseFirestore.instance
                          .collection("productTransaction")
                          .doc(docId)
                          .delete();
                      // Get.to(() => TransactionHistory(), arguments: {'docId': docId});
                    },
                    child: GestureDetector(
                      onTap: () {
                        _selectedType = type;
                        Get.to(() => EditTransaction(), arguments: {
                          'qty': qty,
                          'title': title,
                          'docId': docId,
                          'type': _selectedType,

                        });

                      },
                      child: Card(
                        color: wColor.withOpacity(0.9),
                        margin: const EdgeInsets.symmetric(
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
                                color: primaryColor,
                                fontSize: 24),
                          ),
                          subtitle: Text(
                            formattedDate,
                            style: const TextStyle(
                                fontWeight: FontWeight.bold, fontSize: 16),
                          ),
                          trailing: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Card(
                                color: type == "Send"
                                    ? rColor
                                    : type == "Received"
                                        ? primaryColor
                                        : primaryColor,
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 2, horizontal: 8),
                                  child: Column(
                                    children: [
                                      Text(
                                        "$qty qty",
                                        style: const TextStyle(
                                            color: wColor,
                                            fontWeight: FontWeight.w900),
                                      ),
                                      const SizedBox(
                                        width: 10.0,
                                      ),
                                      Text(
                                        type.toString(),
                                        style: const TextStyle(color: wColor),
                                      ),
                                    ],
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
