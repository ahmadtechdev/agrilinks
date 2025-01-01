import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../colors.dart';
import '../widgets/app_bar.dart';

class MarketProduct extends StatefulWidget {
  const MarketProduct({super.key});

  @override
  State<MarketProduct> createState() => _MarketProductState();
}

class _MarketProductState extends State<MarketProduct> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomAppBar(
              title: "Market Product",
              backButton: true,
              signOutIcon: false,
              backgroundColor: pColor,
              foregroundColor:
              wColor, // Example of using a different background color
            ),
            Container(
              decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      pColor.withOpacity(0.9),
                      pColor.withOpacity(0.6),
                      pColor.withOpacity(0.4),
                    ],
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                  )),
              alignment: Alignment.center,
              height: 170.0,
              child: Image.network(
                Get.arguments['image'].toString(),
                width: 350,
                height: 400,
                fit: BoxFit.contain, // Adjust the fit property as needed
              ),
            ),
            SizedBox(height: 10),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    child: Text(
                      Get.arguments['product'].toString(),
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: pColor,
                      ),
                    ),
                  ),
                  SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    child: Row(
                      children: [
                        Icon(Icons.location_on, color: yColor, size: 30),
                        SizedBox(width: 5),
                        Text(
                          "${Get.arguments['location'].toString()} ",
                          style: TextStyle(
                            fontSize: 18,
                            color: bColor.withOpacity(0.8),
                            fontWeight: FontWeight.bold,
                          ),
                        )
                      ],
                    ),
                  ),
                  SizedBox(height: 10),

                ],
              ),
            ),

            Text("Product Quantity",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [pColor.withOpacity(0.7), pColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.countertops,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${Get.arguments['qty'].toString()}",
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            Text("Product Price",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [pColor.withOpacity(0.7), pColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(
                      Icons.price_change_rounded,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${Get.arguments['price'].toString()}",
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text("Contact",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            Container(
              width: MediaQuery.of(context).size.width,
              margin: EdgeInsets.all(10),
              padding: EdgeInsets.all(15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                gradient: LinearGradient(
                  colors: [pColor.withOpacity(0.7), pColor],
                  begin: Alignment.topRight,
                  end: Alignment.bottomLeft,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 3,
                    blurRadius: 7,
                    offset: Offset(0, 3),
                  ),
                ],
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    Icon(
                      Icons.contact_page,
                      color: Colors.white,
                    ),
                    SizedBox(width: 10),
                    Text(
                      "${Get.arguments['contact'].toString()}",
                      overflow: TextOverflow.fade,
                      softWrap: false,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Text("Product Details",
                style: TextStyle(
                  fontSize: 20,
                  color: bColor.withOpacity(0.8),
                  fontWeight: FontWeight.bold,
                )),
            SingleChildScrollView(
              child: Container(
                height: MediaQuery.of(context).size.height/4.5,
                width: MediaQuery.of(context).size.width,
                margin: EdgeInsets.all(10),
                padding: EdgeInsets.all(15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  gradient: LinearGradient(
                    colors: [pColor.withOpacity(0.7), pColor],
                    begin: Alignment.topRight,
                    end: Alignment.bottomLeft,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      spreadRadius: 3,
                      blurRadius: 7,
                      offset: Offset(0, 3),
                    ),
                  ],
                ),
                child: Text(
                  "${Get.arguments['description'].toString()}",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,

                  ),
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }
}