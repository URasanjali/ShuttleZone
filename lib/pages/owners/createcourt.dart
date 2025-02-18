import 'dart:io';
import 'dart:typed_data';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class CreateCourtScreen extends StatefulWidget {
  const CreateCourtScreen({super.key});

  @override
  _CreateCourtScreenState createState() => _CreateCourtScreenState();
}

class _CreateCourtScreenState extends State<CreateCourtScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController DistrictController = TextEditingController();
  final TextEditingController CityController = TextEditingController();
  final TextEditingController CostController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  dynamic selectedImage;
  bool isUploading = false;

  final cloudinary = Cloudinary.signedConfig(
    apiKey: '981395536329286',
    apiSecret: 'w0N4OTJmvZGtTcBaV2J7Fhb0Y2g',
    cloudName: 'ds0ore7dk',
  );

  Future<void> pickImage() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.image,
      );

      if (result != null) {
        setState(() {
          selectedImage = kIsWeb ? result.files.single.bytes : File(result.files.single.path!);
        });
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting image: $e')),
      );
    }
  }

  Future<String?> uploadImageToCloudinary(dynamic image, String courtName) async {
    try {
      setState(() {
        isUploading = true;
      });

      CloudinaryResponse response;

      if (kIsWeb) {
        // For web: Upload using bytes
        response = await cloudinary.upload(
          fileBytes: image as Uint8List,
          folder: 'courts/$courtName',
          resourceType: CloudinaryResourceType.image,
        );
      } else {
        // For mobile: Upload using file path
        response = await cloudinary.upload(
          file: (image as File).path, // Changed to 'file' instead of 'filePath'
          folder: 'courts/$courtName',
          resourceType: CloudinaryResourceType.image,
        );
      }

      if (response.isSuccessful) {
        print('Upload successful: ${response.secureUrl}');
        return response.secureUrl; // Return the image URL
      } else {
        print('Error uploading image: ${response.error ?? 'Unknown error'}'); // Removed .message
        return null;
      }
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  List<Map<String, String>> freeDaysAndSlots = []; 
  String? selectedDay;
  String? From;
  String? To;
  List<Map<String, String>> selectedDatesTimes = [];
  String? selectedDistrict;


  List<String> generateTimeSlots() {
  List<String> timeSlots = [];
  for (int hour = 0; hour < 24; hour++) {
    String startHour = hour.toString().padLeft(2, '0');
    String endHour = ((hour + 1) % 24).toString().padLeft(2, '0');

    // Add 30-minute intervals
    timeSlots.add("$startHour:00");
    
  }
  return timeSlots;
}





Future<void> saveCourtToFirestore(BuildContext context) async {
  if (nameController.text.trim().isEmpty ||
      DistrictController.text.trim().isEmpty ||
      CityController.text.trim().isEmpty ||
      CostController.text.trim().isEmpty ||
      descriptionController.text.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('All fields are required')),
    );
    return;
  }

  try {
    String? imageUrl;

    // Upload the image if selected
    if (selectedImage != null) {
      imageUrl = await uploadImageToCloudinary(selectedImage, nameController.text.trim());
      if (imageUrl == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Image upload failed, court creation aborted')),
        );
        return;
      }
    }

    // Get the current user ID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    // Save court data to Firestore
    await FirebaseFirestore.instance
        .collection('Courtowners')
        .doc(userId)
        .collection('courts')
        .add({
      'name': nameController.text.trim(),
      'District': DistrictController.text.trim(),
      'City': CityController.text.trim(),
      'Cost': CostController.text.trim(),
      'description': descriptionController.text.trim(),
      'image': imageUrl ?? '',
      'createdAt': DateTime.now(),
      'availableDaysAndSlots': selectedDatesTimes, // Store time slots
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Court added successfully!')),
    );

    // Clear form fields
    nameController.clear();
    DistrictController.clear();
    CostController.clear();
    CityController.clear();
    descriptionController.clear();
    setState(() {
      selectedImage = null;
      selectedDatesTimes.clear();
    });
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e')),
    );
  }
}

Future<DocumentSnapshot> getCourtDetails(String userId, String courtId) async {
  try {
    var courtDoc = await FirebaseFirestore.instance
      .collection('Courtowners')
      .doc(userId)
      .collection('courts')
      .doc(courtId)
      .get();
    
    if (courtDoc.exists) {
      return courtDoc; // This is the document snapshot with all the data
    } else {
      throw 'Court not found';
    }
  } catch (e) {
    throw 'Error fetching court details: $e';
  }
}

Widget buildCourtDetails(String userId, String courtId) {
  return FutureBuilder<DocumentSnapshot>(
    future: getCourtDetails(userId, courtId),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else if (!snapshot.hasData || !snapshot.data!.exists) {
        return const Text('No court details found');
      } else {
        var courtData = snapshot.data!.data() as Map<String, dynamic>;
        // Display court data
        return Column(
          children: [
            Text('Name: ${courtData['name']}'),
            Text('District: ${courtData['District']}'),
            Text('City: ${courtData['City']}'),
            Text('Cost: ${courtData['Cost']}'),
            Text('Description: ${courtData['description']}'),
            // Add image display if image URL exists
            if (courtData['image'].isNotEmpty) 
              Image.network(courtData['image']),
            // Display available days and slots if any
            if (courtData['availableDaysAndSlots'] != null)
              Text('Available Days: ${courtData['availableDaysAndSlots']}'),
          ],
        );
      }
    },
  );
}


  @override
void addDayAndTime() {
  if (selectedDay != null && From != null && To != null) {
    setState(() {
      // Check if the selected day already exists in the list
      var existingDayIndex = selectedDatesTimes.indexWhere(
        (entry) => entry['day'] == selectedDay,
      );

      if (existingDayIndex != -1) {
        // Update the existing day's time slots
        var existingDay = selectedDatesTimes[existingDayIndex];
        var times = existingDay['time']!.split(', ');
        times.add('$From - $To');
        selectedDatesTimes[existingDayIndex] = {
          'day': existingDay['day']!,
          'time': times.join(', '),
        };
      } else {
        // Add a new entry for the selected day
        selectedDatesTimes.add({
          'day': selectedDay!,
          'time': '$From - $To',
        });
      }

      // Reset the fields after adding
      selectedDay = null;
      From = null;
      To = null;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Day and time slots added successfully')),
    );
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select both day and time')),
    );
  }
}


@override
Widget build(BuildContext context) {
  var elevatedButton = ElevatedButton(
    onPressed: addDayAndTime,  // Now this calls addDayAndTime() without parameters
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFF1B7340),
      minimumSize: const Size(200, 56),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
    ),
    child: const Text(
      'Add Day & Time',
      style: TextStyle(color: Colors.white),
    ),
  );
  
  return Scaffold(
    appBar: AppBar(
      title: const Text('Create Court'),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Padding(
      padding: const EdgeInsets.all(16.0),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Add Image',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: pickImage,
              child: Container(
                height: 150,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(8),
                  image: selectedImage != null
                      ? (kIsWeb
                          ? DecorationImage(
                              image: MemoryImage(selectedImage),
                              fit: BoxFit.cover,
                            )
                          : DecorationImage(
                              image: FileImage(selectedImage),
                              fit: BoxFit.cover,
                            ))
                      : null,
                ),
                child: selectedImage == null
                    ? const Center(
                        child: Icon(
                          Icons.add,
                          color: Color(0xFF1B7340),
                          size: 40,
                        ),
                      )
                    : isUploading
                        ? const Center(child: CircularProgressIndicator())
                        : null,
              ),
            ),
            const SizedBox(height: 16),
            // Name input
            TextField(
              controller: nameController,
              decoration: const InputDecoration(
                labelText: 'Name',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B7340), width: 2.0),
                ),
                floatingLabelStyle: TextStyle(color: Color(0xFF1B7340)),
              ),
            ),
            const SizedBox(height: 16),
            // District input
            // District dropdown
InputDecorator(
  
  decoration: const InputDecoration(
    labelText: 'District',
    border: OutlineInputBorder(),
    focusedBorder: OutlineInputBorder(
      borderSide: BorderSide(color: Color(0xFF1B7340), width: 2.0),
    ),
    floatingLabelStyle: TextStyle(color: Color(0xFF1B7340)),
  ),
  child: DropdownButton<String>(
    hint: const Text('Select District'),
    value: selectedDistrict,
    onChanged: (String? newValue) {
      setState(() {
        selectedDistrict = newValue;
        DistrictController.text = newValue ?? ''; // Update the controller text
      });
    },
    items: [
      "Ampara", "Anuradhapura", "Badulla", "Batticaloa", "Colombo", "Galle", 
      "Gampaha", "Hambantota", "Jaffna", "Kalutara", "Kandy", "Kegalle", 
      "Killinochchi", "Kurunegala", "Mannar", "Matale", "Matara", "Monaragala", 
      "Mullaitivu", "Nuwara Eliya", "Polonnaruwa", "Puttalam", "Rathnapura", 
      "Trincomalee", "Vavuniya"
    ]
    .map((District) => DropdownMenuItem(
      value: District,
      child: Text(District),
    ))
    .toList(),
    isExpanded: true, // Ensures the dropdown button stretches to fit the available width
    icon: const Icon(Icons.arrow_drop_down),
    underline: Container(), // Removes the underline of the dropdown
  ),
),


            const SizedBox(height: 16),
            // City input
            TextField(
              controller: CityController,
              decoration: const InputDecoration(
                labelText: 'City',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B7340), width: 2.0),
                ),
                floatingLabelStyle: TextStyle(color: Color(0xFF1B7340)),
              ),
            ),
            const SizedBox(height: 16),
            // Cost input
            TextField(
              controller: CostController,
              decoration: const InputDecoration(
                labelText: 'Cost per 30 min',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B7340), width: 2.0),
                ),
                floatingLabelStyle: TextStyle(color: Color(0xFF1B7340)),
              ),
            ),
            const SizedBox(height: 16),
            // Description input
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                border: OutlineInputBorder(),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF1B7340), width: 2.0),
                ),
                floatingLabelStyle: TextStyle(color: Color(0xFF1B7340)),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Available Days & Time Slots',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            // Day dropdown
           SizedBox(
  width: double.infinity, // Makes the width stretch to fill the available space
  height: 60, // Set the height for the dropdown
  child: DropdownButton<String>(
    hint: const Text('Select Day'),
    value: selectedDay,
    onChanged: (String? newValue) {
      setState(() {
        selectedDay = newValue;
      });
    },
    items: ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday']
        .map((day) => DropdownMenuItem(
              value: day,
              child: Text(day),
            ))
        .toList(),
    isExpanded: true, // Ensures the dropdown stretches to fill the container
  ),
),

            const SizedBox(height: 8),
            // Time Slot dropdown
SizedBox(
  width: double.infinity, // Makes the width stretch to fill the available space
  height: 60, // Set the height for the dropdown
  child: DropdownButton<String>(
    hint: const Text('From'),
    value: From,
    onChanged: (String? newValue) {
      setState(() {
        From = newValue;
      });
    },
    items: generateTimeSlots()
        .map((slot) => DropdownMenuItem(
              value: slot,
              child: Text(slot),
            ))
        .toList(),
    isExpanded: true, // Ensures the dropdown stretches to fill the container
  ),
),
const SizedBox(height: 8), // Space between dropdowns

SizedBox(
  width: double.infinity, // Makes the width stretch to fill the available space
  height: 60, // Set the height for the dropdown
  child: DropdownButton<String>(
    hint: const Text('To'),
    value: To,
    onChanged: (String? newValue) {
      setState(() {
        To = newValue;
      });
    },
    items: generateTimeSlots()
        .map((slot) => DropdownMenuItem(
              value: slot,
              child: Text(slot),
            ))
        .toList(),
    isExpanded: true, // Ensures the dropdown stretches to fill the container
  ),
),

            const SizedBox(height: 8),
            // Add Day & Time button
            Center(
              child: elevatedButton,
            ),
            const SizedBox(height: 16),
            // Display the added day and time slots
            if (selectedDatesTimes.isNotEmpty)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: selectedDatesTimes.map((entry) {
                return ListTile(
                  title: Text('Day: ${entry['day']}'),
                  subtitle: Text('Time: ${entry['time']}'),
                );
              }).toList(),
            ),

            const SizedBox(height: 16),
            // Save Court button
            Center(
              child: ElevatedButton(
                onPressed: () => saveCourtToFirestore(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1B7340),
                  minimumSize: const Size(200, 56),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                child: const Text(
                  'Save Court',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
}