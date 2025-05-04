// market_controller.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:get/get.dart';

class MarketController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Observable variables
  final searchQuery = ''.obs;
  final isLoading = false.obs;
  final marketProducts = <MarketProductModel>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchMarketProducts();
  }

  // Update search query and filter products
  void updateSearchQuery(String query) {
    searchQuery.value = query;
  }

  // Fetch market products from Firestore
  Future<void> fetchMarketProducts() async {
    try {
      isLoading.value = true;

      // Listen to changes in the marketPlace collection
      _firestore.collection("marketPlace").snapshots().listen((snapshot) {
        if (snapshot.docs.isNotEmpty) {
          final products = snapshot.docs.map((doc) =>
              MarketProductModel.fromFirestore(doc)).toList();
          marketProducts.value = products;
        } else {
          marketProducts.clear();
        }
        isLoading.value = false;
      }, onError: (error) {
        print("Error fetching market products: $error");
        isLoading.value = false;
      });
    } catch (e) {
      print("Exception in fetchMarketProducts: $e");
      isLoading.value = false;
    }
  }

  // Filter products based on search query
  List<MarketProductModel> get filteredProducts {
    if (searchQuery.isEmpty) return marketProducts;

    return marketProducts.where((product) {
      return product.product.toLowerCase().contains(searchQuery.value.toLowerCase());
    }).toList();
  }

  // Navigate to product details
  void navigateToProductDetails(MarketProductModel product) {
    Get.toNamed('/market-product', arguments: {
      'product': product.product,
      'price': product.price,
      'qty': product.qty,
      'location': product.location,
      'description': product.description,
      'image': product.image,
      'contact': product.contact,
      'docId': product.docId,
    });
  }
}

// Model class for market products
class MarketProductModel {
  final String docId;
  final String product;
  final String price;
  final int qty;
  final String location;
  final String contact;
  final String description;
  final String image;
  final String sold;
  final String userId;
  final DateTime createdAt;

  MarketProductModel({
    required this.docId,
    required this.product,
    required this.price,
    required this.qty,
    required this.location,
    required this.contact,
    required this.description,
    required this.image,
    required this.sold,
    required this.userId,
    required this.createdAt,
  });

  // Create a MarketProductModel from a Firestore document
  factory MarketProductModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    // Parse createdAt - handle different formats
    DateTime parsedDate;
    try {
      if (data['createdAT'] is Timestamp) {
        parsedDate = (data['createdAT'] as Timestamp).toDate();
      } else if (data['createdAT'] is String) {
        parsedDate = DateTime.parse(data['createdAT']);
      } else {
        parsedDate = DateTime.now();
      }
    } catch (e) {
      parsedDate = DateTime.now();
    }

    return MarketProductModel(
      docId: doc.id,
      product: data['product'] ?? '',
      price: data['price'] ?? '',
      qty: data['qty'] is int ? data['qty'] : int.tryParse(data['qty'] ?? '0') ?? 0,
      location: data['location'] ?? '',
      contact: data['contact'] ?? '',
      description: data['description'] ?? '',
      image: data['image'] ?? '',
      sold: data['sold'] ?? 'No',
      userId: data['userId'] ?? '',
      createdAt: parsedDate,
    );
  }
}