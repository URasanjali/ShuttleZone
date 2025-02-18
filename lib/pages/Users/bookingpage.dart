// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';

// class BookingPage extends StatefulWidget {
//   const BookingPage({super.key, required this.courtName, required this.courtId, required this.userId});

//   final String courtName;
//   final String courtId;
//   final String userId;

//   @override
//   _BookingPageState createState() => _BookingPageState();
// }

// class _BookingPageState extends State<BookingPage> {
//   final int courtCostPer30Min = 500;
//   List<String> availableSlots = [];
//   List<String> selectedSlots = [];
//   int totalCost = 0;
//   String? selectedSlot;
//   String? courtOwnerId;

//   @override
//   void initState() {
//     super.initState();
//     fetchCourtOwner();
//   }

//   // Step 1: Fetch Court Owner ID based on courtId
//   Future<void> fetchCourtOwner() async {
//     try {
//       print("Fetching court owner ID for courtId: ${widget.courtId}");

//       QuerySnapshot query = await FirebaseFirestore.instance
//           .collection('Courtowners')
//           .get();

//       for (var doc in query.docs) {
//         var ownerData = doc.data() as Map<String, dynamic>;
//         var courts = ownerData['courts'] as List<dynamic>?;

//         if (courts != null) {
//           for (var court in courts) {
//             if (court['courtId'] == widget.courtId) {
//               setState(() {
//                 courtOwnerId = doc.id;
//               });
//               print("Court owner found: $courtOwnerId");
//               fetchSlots();
//               return;
//             }
//           }
//         }
//       }

//       print("Error: No court owner found for this court");

//     } catch (error) {
//       print("Error fetching court owner: $error");
//     }
//   }

//   // Step 2: Fetch available slots from Firestore
//   Future<void> fetchSlots() async {
//     if (courtOwnerId == null) {
//       print("Error: courtOwnerId is null");
//       return;
//     }

//     try {
//       print("Fetching slots for courtOwnerId: $courtOwnerId, courtId: ${widget.courtId}");

//       DocumentSnapshot courtDoc = await FirebaseFirestore.instance
//           .collection('Courtowners')
//           .doc(courtOwnerId)
//           .collection('courts')
//           .doc(widget.courtId)
//           .get();

//       if (!courtDoc.exists) {
//         print("Error: Court document not found in Firestore");
//         return;
//       }

//       var data = courtDoc.data() as Map<String, dynamic>;

//       if (!data.containsKey('availableDaysAndSlots')) {
//         print("Error: availableDaysAndSlots field not found");
//         return;
//       }

//       List<dynamic> availableDaysAndSlots = data['availableDaysAndSlots'];
//       List<String> slots = availableDaysAndSlots
//           .whereType<Map<String, dynamic>>()
//           .map((slot) => slot['time'] as String)
//           .toList();

//       print("Available Slots: $slots");

//       setState(() {
//         availableSlots = slots;
//       });

//     } catch (error) {
//       print("Error fetching slots: $error");
//     }
//   }

//   // Select a time slot and add it to selected slots
//   void handleAddSlot() {
//     if (selectedSlot != null && !selectedSlots.contains(selectedSlot)) {
//       setState(() {
//         selectedSlots.add(selectedSlot!);
//         totalCost += courtCostPer30Min;
//         selectedSlot = null;
//       });
//     }
//   }

//   // Confirm booking and remove selected slots from Firestore
//   Future<void> handleConfirmBooking() async {
//     if (courtOwnerId == null) {
//       print("Error: courtOwnerId is null, cannot book slots");
//       return;
//     }

//     try {
//       await FirebaseFirestore.instance
//           .collection('Courtowners')
//           .doc(courtOwnerId)
//           .collection('courts')
//           .doc(widget.courtId)
//           .update({
//         'availableDaysAndSlots': FieldValue.arrayRemove(selectedSlots),
//         'bookedSlots': FieldValue.arrayUnion(selectedSlots),
//       });

//       setState(() {
//         availableSlots.removeWhere((slot) => selectedSlots.contains(slot));
//         selectedSlots.clear();
//         totalCost = 0;
//       });

//       ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(content: Text('Booking confirmed!')));
//       fetchSlots();
//     } catch (error) {
//       print("Error booking slots: $error");
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Book a Court for ${widget.courtName}"),
//         backgroundColor: const Color(0xFF1B7340),
//       ),
//       body: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text("Select Time Slot:",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

//             DropdownButton<String>(
//               value: selectedSlot,
//               hint: const Text("Choose a time slot"),
//               isExpanded: true,
//               onChanged: (String? slot) {
//                 setState(() {
//                   selectedSlot = slot;
//                 });
//               },
//               items: availableSlots.map((slot) {
//                 return DropdownMenuItem(
//                   value: slot,
//                   child: Text(slot),
//                 );
//               }).toList(),
//             ),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: handleAddSlot,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF1B7340),
//               ),
//               child: const Text("Add Time Slot"),
//             ),

//             const SizedBox(height: 20),
//             const Text("Selected Slots:",
//                 style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

//             Wrap(
//               children: selectedSlots
//                   .map((slot) => Chip(
//                         label: Text(slot),
//                         onDeleted: () {
//                           setState(() {
//                             selectedSlots.remove(slot);
//                             totalCost -= courtCostPer30Min;
//                           });
//                         },
//                       ))
//                   .toList(),
//             ),
//             const SizedBox(height: 20),

//             Text("Total Cost: Rs. $totalCost",
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

//             const SizedBox(height: 20),

//             ElevatedButton(
//               onPressed: selectedSlots.isNotEmpty ? handleConfirmBooking : null,
//               style: ElevatedButton.styleFrom(
//                 backgroundColor:
//                     selectedSlots.isNotEmpty ? const Color(0xFF1B7340) : Colors.grey,
//               ),
//               child: const Text("Confirm Booking"),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class BookingPage extends StatefulWidget {
  const BookingPage({super.key, required this.courtName, required this.courtId, required this.userId});

  final String courtName;
  final String courtId;
  final String userId;

  @override
  _BookingPageState createState() => _BookingPageState();
}

class _BookingPageState extends State<BookingPage> {
  final int courtCostPer30Min = 500;
  List<String> availableSlots = [];
  List<String> selectedSlots = [];
  int totalCost = 0;
  String? selectedSlot;
  String? courtOwnerId;

  @override
  void initState() {
    super.initState();
    fetchCourtOwner();
  }

  // Step 1: Fetch Court Owner ID based on courtId
  Future<void> fetchCourtOwner() async {
    try {
      print("Fetching court owner ID for courtId: ${widget.courtId}");

      QuerySnapshot query = await FirebaseFirestore.instance
          .collection('Courtowners')
          .get();

      for (var doc in query.docs) {
        var ownerData = doc.data() as Map<String, dynamic>;
        var courts = ownerData['courts'] as List<dynamic>?;

        if (courts != null) {
          for (var court in courts) {
            if (court['courtId'] == widget.courtId) {
              setState(() {
                courtOwnerId = doc.id;
              });
              print("Court owner found: $courtOwnerId");
              fetchSlots();
              return;
            }
          }
        }
      }

      print("Error: No court owner found for this court");

    } catch (error) {
      print("Error fetching court owner: $error");
    }
  }

  // Step 2: Fetch available slots from Firestore
  Future<void> fetchSlots() async {
    if (courtOwnerId == null) {
      print("Error: courtOwnerId is null");
      return;
    }

    try {
      print("Fetching slots for courtOwnerId: $courtOwnerId, courtId: ${widget.courtId}");

      DocumentSnapshot courtDoc = await FirebaseFirestore.instance
          .collection('Courtowners')
          .doc(courtOwnerId)
          .collection('courts')
          .doc(widget.courtId)
          .get();

      if (!courtDoc.exists) {
        print("Error: Court document not found in Firestore");
        return;
      }

      var data = courtDoc.data() as Map<String, dynamic>;

      if (!data.containsKey('availableDaysAndSlots')) {
        print("Error: availableDaysAndSlots field not found");
        return;
      }

      List<dynamic> availableDaysAndSlots = data['availableDaysAndSlots'];
      List<String> slots = availableDaysAndSlots
          .whereType<Map<String, dynamic>>()
          .map((slot) => slot['time'] as String)
          .toList();

      print("Available Slots: $slots");

      setState(() {
        availableSlots = slots;
      });

    } catch (error) {
      print("Error fetching slots: $error");
    }
  }

  // Select a time slot and add it to selected slots
  void handleAddSlot() {
    if (selectedSlot != null && !selectedSlots.contains(selectedSlot)) {
      setState(() {
        selectedSlots.add(selectedSlot!);
        totalCost += courtCostPer30Min;
        selectedSlot = null;
      });
    }
  }

  // Confirm booking and remove selected slots from Firestore
  Future<void> handleConfirmBooking() async {
    if (courtOwnerId == null) {
      print("Error: courtOwnerId is null, cannot book slots");
      return;
    }

    try {
      await FirebaseFirestore.instance
          .collection('Courtowners')
          .doc(courtOwnerId)
          .collection('courts')
          .doc(widget.courtId)
          .update({
        'availableDaysAndSlots': FieldValue.arrayRemove(selectedSlots),
        'bookedSlots': FieldValue.arrayUnion(selectedSlots),
      });

      setState(() {
        availableSlots.removeWhere((slot) => selectedSlots.contains(slot));
        selectedSlots.clear();
        totalCost = 0;
      });

      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Booking confirmed!')));
      fetchSlots();
    } catch (error) {
      print("Error booking slots: $error");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Book a Court for ${widget.courtName}"),
        backgroundColor: const Color(0xFF1B7340),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text("Select Time Slot:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            DropdownButton<String>(
              value: selectedSlot,
              hint: const Text("Choose a time slot"),
              isExpanded: true,
              onChanged: (String? slot) {
                setState(() {
                  selectedSlot = slot;
                });
              },
              items: availableSlots.map((slot) {
                return DropdownMenuItem(
                  value: slot,
                  child: Text(slot),
                );
              }).toList(),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: handleAddSlot,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF1B7340),
              ),
              child: const Text("Add Time Slot"),
            ),

            const SizedBox(height: 20),
            const Text("Selected Slots:",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

            Wrap(
              children: selectedSlots
                  .map((slot) => Chip(
                        label: Text(slot),
                        onDeleted: () {
                          setState(() {
                            selectedSlots.remove(slot);
                            totalCost -= courtCostPer30Min;
                          });
                        },
                      ))
                  .toList(),
            ),
            const SizedBox(height: 20),

            Text("Total Cost: Rs. $totalCost",
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: selectedSlots.isNotEmpty ? handleConfirmBooking : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    selectedSlots.isNotEmpty ? const Color(0xFF1B7340) : Colors.grey,
              ),
              child: const Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}
