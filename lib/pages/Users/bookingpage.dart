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
import 'package:intl/intl.dart'; // For date formatting

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
  DateTime? selectedDate; // Store selected date

  @override
  void initState() {
    super.initState();
    fetchCourtOwner();
  }

  Future<void> fetchCourtOwner() async {
    try {
      QuerySnapshot courtOwnersQuery = await FirebaseFirestore.instance.collection('Courtowners').get();

      for (var ownerDoc in courtOwnersQuery.docs) {
        String ownerId = ownerDoc.id;

        DocumentSnapshot courtDoc = await FirebaseFirestore.instance
            .collection('Courtowners')
            .doc(ownerId)
            .collection('courts')
            .doc(widget.courtId)
            .get();

        if (courtDoc.exists) {
          setState(() {
            courtOwnerId = ownerId;
          });
          return;
        }
      }
    } catch (error) {
      print("🔥 Error fetching court owner: $error");
    }
  }

  Future<void> fetchSlots() async {
    if (courtOwnerId == null || selectedDate == null) {
      return;
    }

    try {
      DocumentSnapshot courtDoc = await FirebaseFirestore.instance
          .collection('Courtowners')
          .doc(courtOwnerId)
          .collection('courts')
          .doc(widget.courtId)
          .get();

      if (!courtDoc.exists) {
        return;
      }

      var data = courtDoc.data() as Map<String, dynamic>;

      if (!data.containsKey('availableDaysAndSlots')) {
        return;
      }

      List<dynamic> availableDaysAndSlots = data['availableDaysAndSlots'];
      List<String> formattedSlots = [];
      String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate!);

      for (var slot in availableDaysAndSlots) {
        if (slot is Map<String, dynamic> && slot.containsKey('date') && slot['date'] == selectedDateString) {
          String rawTime = slot['time'];
          formattedSlots.addAll(generate30MinSlots(rawTime));
        }
      }

      setState(() {
        availableSlots = formattedSlots;
      });

    } catch (error) {
      print("🔥 Error fetching slots: $error");
    }
  }

  List<String> generate30MinSlots(String timeRange) {
    List<String> slots = [];
    List<String> times = timeRange.split("-");

    if (times.length == 2) {
      TimeOfDay start = parseTime(times[0].trim());
      TimeOfDay end = parseTime(times[1].trim());

      while (isBefore(start, end)) {
        TimeOfDay nextSlot = addMinutes(start, 30);
        slots.add("${formatTime(start)} - ${formatTime(nextSlot)}");
        start = nextSlot;
      }
    }
    return slots;
  }

  TimeOfDay parseTime(String time) {
    List<String> parts = time.split(":");
    return TimeOfDay(hour: int.parse(parts[0]), minute: int.parse(parts[1]));
  }

  bool isBefore(TimeOfDay time1, TimeOfDay time2) {
    return time1.hour < time2.hour || (time1.hour == time2.hour && time1.minute < time2.minute);
  }

  TimeOfDay addMinutes(TimeOfDay time, int minutes) {
    int newMinutes = time.minute + minutes;
    int newHour = time.hour + (newMinutes ~/ 60);
    return TimeOfDay(hour: newHour, minute: newMinutes % 60);
  }

  String formatTime(TimeOfDay time) {
    String hour = time.hour.toString().padLeft(2, '0');
    String minute = time.minute.toString().padLeft(2, '0');
    return "$hour:$minute";
  }

  void handleAddSlot() {
  if (selectedSlot != null && !selectedSlots.contains(selectedSlot)) {
    setState(() {
      selectedSlots.add(selectedSlot!);
      availableSlots.remove(selectedSlot); // Remove slot from dropdown
      totalCost += courtCostPer30Min;
      selectedSlot = null;
    });
  }
}

Future<void> handleConfirmBooking() async {
  if (courtOwnerId == null || selectedDate == null || selectedSlots.isEmpty) {
    return;
  }

  try {
    String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate!);

    await FirebaseFirestore.instance
        .collection('Courtowners')
        .doc(courtOwnerId)
        .collection('courts')
        .doc(widget.courtId)
        .update({
      'availableDaysAndSlots': FieldValue.arrayRemove(selectedSlots.map((slot) => {'date': selectedDateString, 'time': slot}).toList()),
      'bookedSlots': FieldValue.arrayUnion(selectedSlots.map((slot) => {'date': selectedDateString, 'time': slot}).toList()),
    });

    setState(() {
      selectedSlots.clear();
      totalCost = 0;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Booking confirmed!')),
    );
  } catch (error) {
    print("Error booking slots: $error");
  }
}


  // Future<void> handleConfirmBooking() async {
  //   if (courtOwnerId == null || selectedDate == null) {
  //     return;
  //   }

  //   try {
  //     String selectedDateString = DateFormat('yyyy-MM-dd').format(selectedDate!);

  //     await FirebaseFirestore.instance
  //         .collection('Courtowners')
  //         .doc(courtOwnerId)
  //         .collection('courts')
  //         .doc(widget.courtId)
  //         .update({
  //       'availableDaysAndSlots': FieldValue.arrayRemove(selectedSlots.map((slot) => {'date': selectedDateString, 'time': slot}).toList()),
  //       'bookedSlots': FieldValue.arrayUnion(selectedSlots.map((slot) => {'date': selectedDateString, 'time': slot}).toList()),
  //     });

  //     setState(() {
  //       availableSlots.removeWhere((slot) => selectedSlots.contains(slot));
  //       selectedSlots.clear();
  //       totalCost = 0;
  //     });

  //     ScaffoldMessenger.of(context).showSnackBar(
  //         const SnackBar(content: Text('Booking confirmed!')));
  //   } catch (error) {
  //     print("Error booking slots: $error");
  //   }
  // }

  Future<void> selectDate(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );

    if (pickedDate != null && pickedDate != selectedDate) {
      setState(() {
        selectedDate = pickedDate;
      });
      fetchSlots();
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
            ElevatedButton(
              onPressed: () => selectDate(context),
              child: Text(selectedDate == null ? "Select Date" : DateFormat('yyyy-MM-dd').format(selectedDate!)),
            ),

            const SizedBox(height: 20),

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
              child: const Text("Add Time Slot"),
            ),
const SizedBox(height: 20),
Text("Selected Time Slots:", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

Wrap(
  spacing: 8.0,
  children: selectedSlots.map((slot) {
    return Chip(
      label: Text(slot),
      deleteIcon: Icon(Icons.cancel, color: Colors.red),
      onDeleted: () {
        setState(() {
          availableSlots.add(slot); // Restore slot back to dropdown
          selectedSlots.remove(slot);
          totalCost -= courtCostPer30Min;
        });
      },
    );
  }).toList(),
),

            const SizedBox(height: 20),

            Text("Total Cost: Rs. $totalCost", style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),

            ElevatedButton(
              onPressed: selectedSlots.isNotEmpty ? handleConfirmBooking : null,
              child: const Text("Confirm Booking"),
            ),
          ],
        ),
      ),
    );
  }
}