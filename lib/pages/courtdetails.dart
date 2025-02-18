// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:flutter/material.dart';

// class Courtdetails extends StatefulWidget {
//   final String userId;  // Add userId here
//   final String courtDistrict;
//   final String name;
//   final String district; // Changed to follow lowerCamelCase
//   final String image;
//   final String courtName;

//   const Courtdetails({
//     Key? key,
//     required this.userId,  // Pass userId in the constructor
//     required this.courtDistrict,
//     required this.name,
//     required this.district, // Changed to follow lowerCamelCase
//     required this.image,
//     required this.courtName, required String courtId,
//   }) : super(key: key);

//   @override
//   _CourtdetailsState createState() => _CourtdetailsState();
// }

// class _CourtdetailsState extends State<Courtdetails> {
//   late Future<DocumentSnapshot> _courtDetails;

//   @override
//   void initState() {
//     super.initState();
//     _courtDetails = FirebaseFirestore.instance
//         .collection('Courtowners')
//         .doc(widget.userId) // Access userId from widget
//         .collection('courts')
//         .doc('someCourtId') // Replace with dynamic courtId if necessary
//         .get();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Court Details'),
//         backgroundColor: const Color(0xFF1B7340),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _courtDetails,
//         builder: (context, snapshot) {
//           if (snapshot.connectionState == ConnectionState.waiting) {
//             return const Center(child: CircularProgressIndicator());
//           } else if (snapshot.hasError) {
//             return Center(child: Text('Error: ${snapshot.error}'));
//           } else if (!snapshot.hasData || !snapshot.data!.exists) {
//             return const Center(child: Text('Court not found'));
//           } else {
//             var courtData = snapshot.data!.data() as Map<String, dynamic>;

//             String courtName = courtData['name'] ?? 'No Name';
//             String image = courtData['image'] ?? '';
//             String description = courtData['description'] ?? 'No Description';
//             String district = courtData['district'] ?? 'District Not Available'; // Changed to match field name
//             String cost = courtData['cost'] ?? 'Not Available';

//             var availableDaysAndSlots = courtData['availableDaysAndSlots'];
//             if (availableDaysAndSlots == null || availableDaysAndSlots is! List) {
//               availableDaysAndSlots = [];
//             }

//             return SingleChildScrollView(
//               child: Padding(
//                 padding: const EdgeInsets.all(16.0),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Center(
//                       child: Text(
//                         courtName,
//                         style: const TextStyle(
//                           fontSize: 24,
//                           fontWeight: FontWeight.bold,
//                         ),
//                       ),
//                     ),
//                     const SizedBox(height: 16),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(8.0),
//                       child: image.isEmpty
//                           ? Image.asset('assets/default_image.png')
//                           : Image.network(
//                               image,
//                               height: 200,
//                               width: double.infinity,
//                               fit: BoxFit.cover,
//                             ),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on, color: Colors.red),
//                         const SizedBox(width: 8),
//                         Expanded(
//                           child: Text(
//                             district,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),
//                     Text(
//                       description,
//                       style: const TextStyle(fontSize: 16),
//                     ),
//                     const SizedBox(height: 16),
//                     Row(
//                       children: [
//                         const Icon(Icons.attach_money, color: Colors.green),
//                         const SizedBox(width: 8),
//                         Text(
//                           'Cost: $cost',
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 16),

//                     // Display Available Time Slots
//                     const Text(
//                       'Available Time Slots:',
//                       style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//                     ),
//                     const SizedBox(height: 8),
//                     if (availableDaysAndSlots.isEmpty)
//                       const Text('No available time slots for this court.')
//                     else
//                       ListView.builder(
//                         shrinkWrap: true,
//                         physics: const NeverScrollableScrollPhysics(),
//                         itemCount: availableDaysAndSlots.length,
//                         itemBuilder: (context, index) {
//                           var dayData = availableDaysAndSlots[index];
//                           String day = dayData['day'];
//                           String timeSlotsString = dayData['time'];
                          
//                           List<String> timeSlots = timeSlotsString.split(',').map((e) => e.trim()).toList();

//                           return Column(
//                             crossAxisAlignment: CrossAxisAlignment.start,
//                             children: [
//                               Text(
//                                 day,
//                                 style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//                               ),
//                               const SizedBox(height: 8),
//                               Column(
//                                 children: timeSlots.map<Widget>((slot) {
//                                   return Row(
//                                     children: [
//                                       const Icon(
//                                         Icons.check_circle,
//                                         color: Colors.green,
//                                       ),
//                                       const SizedBox(width: 8),
//                                       Text(slot),
//                                     ],
//                                   );
//                                 }).toList(),
//                               ),
//                               const SizedBox(height: 16),
//                             ],
//                           );
//                         },
//                       ),
//                     const SizedBox(height: 16),
//                     Center(
//                       child: ElevatedButton(
//                         onPressed: () {
//                           // Implement booking functionality here
//                         },
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: const Color(0xFF1B7340),
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 120,
//                             vertical: 15,
//                           ),
//                           shape: RoundedRectangleBorder(
//                             borderRadius: BorderRadius.circular(10),
//                           ),
//                         ),
//                         child: const Text(
//                           'Book Now',
//                           style: TextStyle(fontSize: 18, color: Colors.white),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             );
//           }
//         },
//       ),
//     );
//   }

// }

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:shuttlezone/pages/Users/bookingpage.dart';

class Courtdetails extends StatefulWidget {
  final String userId; 
  final String courtDistrict;
  final String name;
  final String district;
  final String image;
  final String courtName;
  final String courtId; // Add courtId to the constructor

  const Courtdetails({
    Key? key,
    required this.userId,  
    required this.courtDistrict,
    required this.name,
    required this.district, 
    required this.image,
    required this.courtName,
    required this.courtId, // Pass courtId to the constructor
  }) : super(key: key);

  @override
  _CourtdetailsState createState() => _CourtdetailsState();
}

class _CourtdetailsState extends State<Courtdetails> {
  late Future<DocumentSnapshot> _courtDetails;

  @override
  void initState() {
    super.initState();
    _courtDetails = FirebaseFirestore.instance
        .collection('Courtowners')
        .doc(widget.userId) 
        .collection('courts')
        .doc(widget.courtId) // Use courtId from the widget
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Court Details'),
        backgroundColor: const Color(0xFF1B7340),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _courtDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Court not found'));
          } else {
            var courtData = snapshot.data!.data() as Map<String, dynamic>;

            // Fetching data with checks for null or missing fields
            String courtName = courtData['name'] ?? widget.courtName; // Use widget's courtName as a fallback
            String image = courtData['image'] ?? ''; // Default to empty string if no image is provided
            String description = courtData['description'] ?? 'No Description';
            String District = courtData['District'] ?? 'NO District'; // Use widget's district as fallback
            String Cost = courtData['Cost'] ?? 'Not Available';

            var availableDaysAndSlots = courtData['availableDaysAndSlots'];
            if (availableDaysAndSlots == null || availableDaysAndSlots is! List) {
              availableDaysAndSlots = [];
            }

            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Text(
                        courtName,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8.0),
                      child: image.isEmpty
                          ? Image.asset('assets/default_image.png')
                          : Image.network(
                              image,
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.red),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            District,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Text(
                      description,
                      style: const TextStyle(fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.green),
                        const SizedBox(width: 8),
                        Text(
                          'Cost: $Cost',
                          style: const TextStyle(fontSize: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Display Available Time Slots
                    const Text(
                      'Available Time Slots:',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    if (availableDaysAndSlots.isEmpty)
                      const Text('No available time slots for this court.')
                    else
                      ListView.builder(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: availableDaysAndSlots.length,
                        itemBuilder: (context, index) {
                          var dayData = availableDaysAndSlots[index];
                          String day = dayData['day'];
                          String timeSlotsString = dayData['time'];
                          
                          List<String> timeSlots = timeSlotsString.split(',').map((e) => e.trim()).toList();

                          return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                day,
                                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 8),
                              Column(
                                children: timeSlots.map<Widget>((slot) {
                                  return Row(
                                    children: [
                                      const Icon(
                                        Icons.check_circle,
                                        color: Colors.green,
                                      ),
                                      const SizedBox(width: 8),
                                      Text(slot),
                                    ],
                                  );
                                }).toList(),
                              ),
                              const SizedBox(height: 16),
                            ],
                          );
                        },
                      ),
                    const SizedBox(height: 16),
                    Center(
                      child: ElevatedButton(
  onPressed: () {
    // Navigate to the BookingPage
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingPage(
          courtName: widget.courtName, // Pass the court name
          courtId: widget.courtId, userId: '',     // Pass the court ID
        ),
      ),
    );
  },
  style: ElevatedButton.styleFrom(
    backgroundColor: const Color(0xFF1B7340),
    padding: const EdgeInsets.symmetric(
      horizontal: 120,
      vertical: 15,
    ),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  ),
  child: const Text(
    'Book Now',
    style: TextStyle(fontSize: 18, color: Colors.white),
  ),
)

                    ),
                  ],
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
