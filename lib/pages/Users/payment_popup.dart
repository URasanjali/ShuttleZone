// import 'package:flutter/material.dart';
// import 'qr_generation_and_storage.dart';  // Import the QR-related methods

// class PaymentPopup extends StatefulWidget {
//   const PaymentPopup({
//     super.key,
//     required this.totalCost,
//     required this.userId,
//     required this.courtName,
//     required this.bookingId,
//   });

//   final double totalCost;
//   final String userId;
//   final String courtName;
//   final String bookingId;

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
//               "Payment Details",
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//             const SizedBox(height: 4),
//             const Align(
//               alignment: Alignment.centerLeft,
//               child: Text(
//                 "Please enter your payment information",
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
//                 onPressed: () async {
//                   try {
//                     // 1. Generate a unique QR code data (e.g., using userId, bookingId, and cost)
//                     final qrData = 'payment|${widget.userId}|${widget.bookingId}|${widget.totalCost}|${widget.courtName}';

//                     // 2. Generate the QR code bytes from the data
//                     final qrCodeBytes = await generateQrCode(qrData);

//                     // 3. Upload the QR code to Cloudinary
//                     final qrCodeUrl = await uploadQrCodeToCloudinary(qrCodeBytes);

//                     // 4. Store payment details along with the QR code URL in Firestore
//                     await storePaymentDetails(
//                       widget.userId,
//                       widget.totalCost,
//                       qrCodeUrl,
//                       widget.courtName,
//                       widget.bookingId,
//                     );

//                     // Close the popup on successful payment
//                     Navigator.pop(context);
//                   } catch (e) {
//                     print("Error: $e");
//                     // Optionally, show an error message
//                     ScaffoldMessenger.of(context).showSnackBar(
//                       const SnackBar(content: Text('Failed to process payment. Please try again.')),
//                     );
//                   }
//                 },
//                 style: ElevatedButton.styleFrom(
//                   backgroundColor: Colors.blue,
//                   padding: const EdgeInsets.symmetric(vertical: 14),
//                   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//                 ),
//                 child: Text("Pay \$${widget.totalCost}", style: const TextStyle(fontSize: 16)),
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
import 'package:flutter/material.dart';
import 'qr_display_screen.dart';

class PaymentPopup extends StatefulWidget {
  const PaymentPopup({
    super.key,
    required this.totalCost,
    required this.userId,
    required this.courtName,
    required this.bookingId,
  });

  final int totalCost;
  final String userId;
  final String courtName;
  final String bookingId;

  @override
  State<PaymentPopup> createState() => _PaymentPopupState();
}

class _PaymentPopupState extends State<PaymentPopup> {
  final emailController = TextEditingController();
  final cardController = TextEditingController();
  final expiryController = TextEditingController();
  final cvcController = TextEditingController();
  bool rememberMe = false;
  bool isLoading = false;

  @override
  @override
Widget build(BuildContext context) {
  return AlertDialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    contentPadding: const EdgeInsets.all(20),
    content: SizedBox(
      width: 320,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 20),

          _textInput(emailController, "Email", Icons.email),
          const SizedBox(height: 12),

          _textInput(cardController, "Card number", Icons.credit_card),
          const SizedBox(height: 12),

          Row(
            children: [
              Expanded(child: _textInput(expiryController, "MM / YY", Icons.calendar_today)),
              const SizedBox(width: 12),
              Expanded(child: _textInput(cvcController, "CVC", Icons.lock)),
            ],
          ),

          const SizedBox(height: 16),

          Row(
            children: [
              Checkbox(
                value: rememberMe,
                onChanged: (val) => setState(() => rememberMe = val!),
              ),
              const Text("Remember me"),
            ],
          ),

          const SizedBox(height: 16),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: isLoading ? null : _handlePayment,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7340), // green color
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              ),
              child: isLoading
                  ? const CircularProgressIndicator(color: Colors.white)
                  : Text("Pay Rs. ${widget.totalCost}", style: const TextStyle(fontSize: 16, color: Colors.white)),
            ),
          ),
        ],
      ),
    ),
  );
}

Widget _textInput(TextEditingController controller, String hint, IconData icon) {
  return TextField(
    controller: controller,
    decoration: InputDecoration(
      prefixIcon: Icon(icon, size: 20, color: Colors.grey[700]),
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.grey[200],
      contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Colors.transparent),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: Color(0xFF1B7340)),
      ),
    ),
    style: const TextStyle(fontSize: 14),
  );
}

  Future<void> _handlePayment() async {
    setState(() => isLoading = true);
    try {
      // Generate the QR data string based on the payment details
      final qrData =
          'payment|${widget.userId}|${widget.bookingId}|${widget.totalCost}|${widget.courtName}';

      // Navigate to QrDisplayScreen to show the QR code
      if (context.mounted) {
        print("Payment Data: $qrData");

        Navigator.pop(context); // Close the payment popup
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => QrDisplayScreen(
              qrData: qrData, // Pass the unique QR data to the next screen
            ),
          ),
        );
      }
    } catch (e) {
      print("Payment Error: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Payment failed. Please try again.')),
      );
    } finally {
      setState(() => isLoading = false);
    }
  }
}
