// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentPage extends StatefulWidget {
//   final int amount;
//   final String userId;
//   final String courtName;

//   const PaymentPage({
//     Key? key,
//     required this.amount,
//     required this.userId,
//     required this.courtName,
//   }) : super(key: key);

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   Map<String, dynamic>? paymentIntentData;

//   @override
//   void initState() {
//     super.initState();
//     // Optionally call makePayment() on load
//     // makePayment();
//   }

//   Future<void> makePayment() async {
//     try {
//       paymentIntentData = await createPaymentIntent(
//         widget.amount.toString(),
//         'USD',
//       );

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData!['clientSecret'],
//           merchantDisplayName: 'ShuttleZone',
//           style: ThemeMode.light,
//         ),
//       );

//       await displayPaymentSheet();
//     } catch (e) {
//       debugPrint('Payment error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment Failed: $e')),
//       );
//     }
//   }

//   Future<void> displayPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Payment Successful")),
//       );

//       setState(() => paymentIntentData = null);
//     } on StripeException catch (e) {
//       debugPrint('Stripe Exception: ${e.error.localizedMessage}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Payment Cancelled: ${e.error.localizedMessage}")),
//       );
//     } catch (e) {
//       debugPrint('Display Sheet Error: $e');
//     }
//   }

//   Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       final response = await http.post(
//         Uri.parse('http://localhost:3000/create-payment-intent'), // Replace with your backend endpoint
//         body: jsonEncode({
//           'totalCost': (int.parse(amount) * 100).toString(), // Stripe expects the amount in cents
//           'currency': currency,
//         }),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to create payment intent');
//       }

//       return jsonDecode(response.body);
//     } catch (e) {
//       throw Exception('createPaymentIntent error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment Page')),
//       body: Center(
//         child: ElevatedButton(
//           onPressed: makePayment,
//           child: const Text('Pay Now'),
//         ),
//       ),
//     );
//   }
// }



// import 'package:flutter/material.dart';
// import 'package:flutter_stripe/flutter_stripe.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:http/http.dart' as http;
// import 'dart:convert';

// class PaymentPage extends StatefulWidget {
//   final String userId;
//   final String courtName;
//   final int totalCost; // Added to accept initial totalCost if available
// final String bookingId;

//   const PaymentPage({
//     super.key,
//     required this.userId,
//     required this.courtName,
//     required this.totalCost,
//     required this.bookingId,
//   });

//   @override
//   State<PaymentPage> createState() => _PaymentPageState();
// }

// class _PaymentPageState extends State<PaymentPage> {
//   Map<String, dynamic>? paymentIntentData;
//   late int totalCost;
//   bool isLoading = true;

//   @override
//   void initState() {
//     super.initState();
//     totalCost = widget.totalCost;
//     fetchTotalCost(); // Even if totalCost is passed, re-fetch from Firestore
//   }

// Future<void> fetchTotalCost() async {
//   try {
//     DocumentSnapshot snapshot = await FirebaseFirestore.instance
//         .collection('Court Booker')
//         .doc(widget.userId)
//         .collection('bookings')
//         .doc(widget.bookingId)
//         .get();

//     if (snapshot.exists) {
//       var cost = snapshot['totalCost'];
//       setState(() {
//         totalCost = cost;
//         isLoading = false;
//       });
//       print('Total cost: $totalCost');
//     } else {
//       print('Booking not found');
//       setState(() {
//         isLoading = false;
//       });
//     }
//   } catch (e) {
//     print('Error fetching total cost: $e');
//     setState(() {
//       isLoading = false;
//     });
//   }
// }



//   Future<void> makePayment() async {
//     try {
//       if (totalCost == 0) throw Exception('Invalid total cost');

//       paymentIntentData = await createPaymentIntent(
//         totalCost.toString(),
//         'USD',
//       );

//       await Stripe.instance.initPaymentSheet(
//         paymentSheetParameters: SetupPaymentSheetParameters(
//           paymentIntentClientSecret: paymentIntentData!['clientSecret'],
//           merchantDisplayName: 'ShuttleZone',
//           style: ThemeMode.light,
//         ),
//       );

//       await displayPaymentSheet();
//     } catch (e) {
//       debugPrint('Payment error: $e');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Payment Failed: $e')),
//       );
//     }
//   }

//   Future<void> displayPaymentSheet() async {
//     try {
//       await Stripe.instance.presentPaymentSheet();

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text("✅ Payment Successful")),
//       );

//       setState(() => paymentIntentData = null);
//     } on StripeException catch (e) {
//       debugPrint('Stripe Exception: ${e.error.localizedMessage}');
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text("❌ Payment Cancelled: ${e.error.localizedMessage}")),
//       );
//     } catch (e) {
//       debugPrint('Display Sheet Error: $e');
//     }
//   }

//   Future<Map<String, dynamic>> createPaymentIntent(String amount, String currency) async {
//     try {
//       final response = await http.post(
//        Uri.parse('https://47b6-45-121-91-137.ngrok-free.app/create-payment-intent'),

//         body: jsonEncode({
//           'totalCost': (int.parse(amount) * 100).toString(),
//           'currency': currency,
//         }),
//         headers: {
//           'Content-Type': 'application/json',
//         },
//       );

//       if (response.statusCode != 200) {
//         throw Exception('Failed to create payment intent');
//       }

//       return jsonDecode(response.body);
//     } catch (e) {
//       throw Exception('createPaymentIntent error: $e');
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Payment Page')),
//       body: Center(
//         child: isLoading
//             ? const CircularProgressIndicator()
//             : ElevatedButton(
//                 onPressed: makePayment,
//                 style: ElevatedButton.styleFrom(
//                   padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
//                   textStyle: const TextStyle(fontSize: 18),
//                 ),
//                 child: Text('Pay \$$totalCost'),
//               ),
//       ),
//     );
//   }
// }


// import 'package:flutter/material.dart';

// class PaymentPopup extends StatefulWidget {
//   const PaymentPopup({super.key, required int totalCost, required String userId, required String courtName, required String bookingId});

//   @override
//   State<PaymentPopup> createState() => _PaymentPopupState();
// }

// class _PaymentPopupState extends State<PaymentPopup> {
//   final emailController = TextEditingController();
//   final cardController = TextEditingController();
//   final expiryController = TextEditingController();
//   final cvcController = TextEditingController();
//   bool rememberMe = false;

//   @override
//   Widget build(BuildContext context) {
//     return AlertDialog(
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       contentPadding: const EdgeInsets.all(16),
//       content: SizedBox(
//         width: 320,
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               "Another test donation",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 4),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "This is a custom description",
//                 style: TextStyle(color: Colors.grey),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _textInput(emailController, "Email", Icons.email),
//             const SizedBox(height: 8),
//             _textInput(cardController, "Card number", Icons.credit_card),
//             const SizedBox(height: 8),
//             Row(
//               children: [
//                 Expanded(child: _textInput(expiryController, "MM / YY", Icons.calendar_today)),
//                 const SizedBox(width: 8),
//                 Expanded(child: _textInput(cvcController, "CVC", Icons.lock)),
//               ],
//             ),
//             const SizedBox(height: 12),
//             Row(
//               children: [
//                 Checkbox(
//                   value: rememberMe,
//                   onChanged: (val) => setState(() => rememberMe = val!),
//                 ),
//                 const Text("Remember me"),
//               ],
//             ),
//             const SizedBox(height: 12),
//             SizedBox(
//               width: double.infinity,
//               child: ElevatedButton(
//                 onPressed: () => Navigator.pop(context),
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: const Text("Pay \$50.00", style: TextStyle(fontSize: 16)),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _textInput(TextEditingController controller, String hint, IconData icon) {
//     return TextField(
//       controller: controller,
//       decoration: InputDecoration(
//         prefixIcon: Icon(icon, size: 20),
//         hintText: hint,
//         filled: true,
//         fillColor: Colors.grey[200],
//         contentPadding: const EdgeInsets.symmetric(vertical: 12),
//         border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
// }

