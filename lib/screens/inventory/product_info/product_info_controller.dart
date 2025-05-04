import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProductInfoController extends GetxController {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Product details
  final RxString title = ''.obs;
  final RxString date = ''.obs;
  final RxInt quantity = 0.obs;
  final RxString price = ''.obs;
  final RxString detail = ''.obs;
  final RxString docId = ''.obs;

  // Animation states
  final RxBool isLoading = true.obs;

  @override
  void onInit() {
    super.onInit();
    loadProductData();
  }

  void loadProductData() {
    try {
      final args = Get.arguments;

      if (args != null) {
        title.value = args['title']?.toString() ?? 'No Title';
        date.value = args['date']?.toString() ?? 'No Date';
        quantity.value = int.tryParse(args['qty']?.toString() ?? '0') ?? 0;
        price.value = args['price']?.toString() ?? '0';
        detail.value = args['detail']?.toString() ?? 'No details available';
        docId.value = args['docId']?.toString() ?? '';
      }
    } catch (e) {
      print("Error loading product data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshProductData() async {
    if (docId.isEmpty) return;

    try {
      isLoading.value = true;

      final docSnapshot = await _firestore
          .collection("inventoryProducts")
          .doc(docId.value)
          .get();

      if (docSnapshot.exists) {
        final data = docSnapshot.data();
        if (data != null) {
          title.value = data['productTitle'] ?? 'No Title';

          if (data['createdAT'] != null) {
            Timestamp timestamp = data['createdAT'];
            DateTime dateTime = timestamp.toDate();
            date.value = formatDate(dateTime);
          } else {
            date.value = 'No Date';
          }

          quantity.value = int.tryParse(data['qty']?.toString() ?? '0') ?? 0;
          price.value = data['productPrice']?.toString() ?? '0';
          detail.value = data['detail']?.toString() ?? 'No details available';
        }
      }
    } catch (e) {
      print("Error refreshing product data: $e");
    } finally {
      isLoading.value = false;
    }
  }

  String formatDate(DateTime dateTime) {
    final weekday = getWeekday(dateTime);
    final month = getMonth(dateTime);
    final formattedHour = formatHour(dateTime);

    return '$weekday, ${dateTime.day} $month ${dateTime.year % 100} · $formattedHour';
  }

  String getWeekday(DateTime dateTime) {
    switch (dateTime.weekday) {
      case 1: return 'Mon';
      case 2: return 'Tue';
      case 3: return 'Wed';
      case 4: return 'Thu';
      case 5: return 'Fri';
      case 6: return 'Sat';
      case 7: return 'Sun';
      default: return '';
    }
  }

  String getMonth(DateTime dateTime) {
    switch (dateTime.month) {
      case 1: return 'Jan';
      case 2: return 'Feb';
      case 3: return 'Mar';
      case 4: return 'Apr';
      case 5: return 'May';
      case 6: return 'Jun';
      case 7: return 'Jul';
      case 8: return 'Aug';
      case 9: return 'Sep';
      case 10: return 'Oct';
      case 11: return 'Nov';
      case 12: return 'Dec';
      default: return '';
    }
  }

  String formatHour(DateTime dateTime) {
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
}