import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import 'add_market.dart';
import 'inventory_screen.dart';
import 'market_screen.dart';
import 'my_market_product_info.dart';
import 'navbar.dart';
import 'newsfeed_screen.dart';

class MyMarketAdds extends StatefulWidget {
  const MyMarketAdds({super.key});

  @override
  State<MyMarketAdds> createState() => _MyMarketAddsState();
}

class _MyMarketAddsState extends State<MyMarketAdds> {
  User? userId = FirebaseAuth.instance.currentUser;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // drawer: NavBar(),
      appBar: AppBar(
        automaticallyImplyLeading: true,
        centerTitle: true,
        backgroundColor: pColor,
        title: const Text(
          "My Market Adds",
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
      body: StreamBuilder(
        stream: FirebaseFirestore.instance
            .collection("marketPlace")
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
            return ListView.builder(
                itemCount: snapshot.data!.docs.length,
                itemBuilder: (context, index) {
                  var product = snapshot.data!.docs[index]['product'];
                  var qty = snapshot.data!.docs[index]['qty'];
                  var price = snapshot.data!.docs[index]['price'];
                  var location = snapshot.data!.docs[index]['location'];
                  var contact = snapshot.data!.docs[index]['contact'];
                  var description = snapshot.data!.docs[index]['description'];
                  var image = snapshot.data!.docs[index]['image'];

                  var docId = snapshot.data!.docs[index].id;

                  return GestureDetector(
                    onTap: () {
                      Get.to(() => MyProductInfo(), arguments: {
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
                });
          }
          return Container();
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: pColor,
        foregroundColor: wColor,
        onPressed: () {
          Get.to(() => AddMarketScreen());
        },
        label: Text("New Add"),
      ),

    );
  }
}
