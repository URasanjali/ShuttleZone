import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloudinary/cloudinary.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';

class EditCourtScreen extends StatefulWidget {
  final String courtId;
  final String userId;

  

  const EditCourtScreen({
    super.key,
    required this.courtId,
    required this.userId, required initialName, required initialDistrict, required initialDescription,
  });

  @override
  _EditCourtScreenState createState() => _EditCourtScreenState();
}

class _EditCourtScreenState extends State<EditCourtScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController DistrictController = TextEditingController();
  final TextEditingController CityController = TextEditingController();
  final TextEditingController CostController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  dynamic selectedImage;
  bool isUploading = false;
  bool isLoading = true;
  List<Map<String, String>> freeDaysAndSlots = []; 
  String? selectedDay;
  String? From;
  String? To;
  List<Map<String, String>> selectedDatesTimes = [];
  String? selectedDistrict;




  final cloudinary = Cloudinary.signedConfig(
    apiKey: '981395536329286',
    apiSecret: 'w0N4OTJmvZGtTcBaV2J7Fhb0Y2g',
    cloudName: 'ds0ore7dk',
  );


  @override
  void initState() {
    super.initState();
    fetchCourtDetails();
  }

// Helper method to show loading indicator while uploading image
Widget buildLoadingIndicator() {
  return isUploading
      ? const CircularProgressIndicator()
      : const SizedBox.shrink();
}

// Helper widget for text input fields
Widget buildTextInput(TextEditingController controller, String label) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
      const SizedBox(height: 8),
      TextField(
        controller: controller,
        decoration: InputDecoration(
          border: const OutlineInputBorder(),
          hintText: 'Enter $label',
        ),
      ),
      const SizedBox(height: 16),
    ],
  );
}

// Helper method to handle image pick and display
Widget buildImagePicker() {
  return GestureDetector(
    onTap: pickImage,
    child: Container(
      height: 150,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
        image: selectedImage != null
            ? (kIsWeb
                ? DecorationImage(image: MemoryImage(selectedImage), fit: BoxFit.cover)
                : DecorationImage(image: FileImage(selectedImage), fit: BoxFit.cover))
            : null,
      ),
      child: selectedImage == null
          ? const Center(child: Icon(Icons.add, color: Color(0xFF1B7340)))
          : null,
    ),
  );
}


Future<void> updateCourtInFirestore(BuildContext context) async {
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
          const SnackBar(content: Text('Image upload failed, court update aborted')),
        );
        return;
      }
    }

    // Get the current user ID from Firebase Authentication
    User? user = FirebaseAuth.instance.currentUser;
    String userId = user?.uid ?? '';

    // Update the court data in Firestore
    await FirebaseFirestore.instance
        .collection('Courtowners')
        .doc(userId)
        .collection('courts')
        .doc(widget.courtId)  // Use the courtId to reference the specific court document
        .update({
      'name': nameController.text.trim(),
      'District': DistrictController.text.trim(),
      'City': CityController.text.trim(),
      'Cost': CostController.text.trim(),
      'description': descriptionController.text.trim(),
      'image': imageUrl ?? '',  // Only update image if it's uploaded
      'availableDaysAndSlots': selectedDatesTimes, // Store time slots
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Court updated successfully!')),
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


Future<void> fetchCourtDetails() async {
  try {
    final docSnapshot = await FirebaseFirestore.instance
        .collection('Courtowners')
        .doc(widget.userId)
        .collection('courts')
        .doc(widget.courtId)
        .get();

    if (docSnapshot.exists) {
      final data = docSnapshot.data();
      if (data != null) {
        debugPrint("Fetched court data: $data"); // Log fetched data for debugging
        setState(() {
          nameController.text = data['name'] ?? '';
          DistrictController.text = data['District'] ?? '';
          selectedDistrict = data['District'];
          CityController.text = data['City'] ?? '';
          CostController.text = data['Cost'] ?? '';
          descriptionController.text = data['description'] ?? '';
          selectedDatesTimes = List<Map<String, String>>.from(data['availableDaysAndSlots'] ?? []);
          selectedImage = data['image'];

          // Handle available days and time slots
          if (selectedDatesTimes.isNotEmpty) {
            for (var entry in selectedDatesTimes) {
              selectedDay = entry['day']; // Set the selected day
              var times = entry['time']?.split(', ') ?? [];
              if (times.isNotEmpty) {
                From = times[0].split(' - ')[0];
                To = times[0].split(' - ')[1];
              }
            }
          }
        });
      }
    } else {
      debugPrint("Court document not found.");
    }
  } catch (e) {
    debugPrint("Failed to fetch court details: $e"); // Log error message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to fetch court details: $e')),
    );
  } finally {
    setState(() {
      isLoading = false;
    });
  }
}



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

  void addAvailableDaySlot() {
    setState(() {
      selectedDatesTimes.add({'day': '', 'time': ''});
    });
  }

  void removeAvailableDaySlot(int index) {
    setState(() {
      selectedDatesTimes.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
  var elevatedButton = ElevatedButton(
    onPressed: addDayAndTime, // Now this calls addDayAndTime() without parameters
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
    title: const Text('Edit Court'),
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
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : null,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: nameController,
            decoration: const InputDecoration(labelText: 'Court Name'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: DistrictController,
            decoration: const InputDecoration(labelText: 'District'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: CityController,
            decoration: const InputDecoration(labelText: 'City'),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: CostController,
            decoration: const InputDecoration(labelText: 'Cost'),
            keyboardType: TextInputType.number,
          ),
          const SizedBox(height: 16),
          TextField(
            controller: descriptionController,
            decoration: const InputDecoration(labelText: 'Description'),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          elevatedButton, // The Add Day & Time button
          const SizedBox(height: 16),
          selectedDatesTimes.isNotEmpty
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: selectedDatesTimes
                      .map(
                        (entry) => Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${entry['day']} : ${entry['time']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                removeAvailableDaySlot(
                                  selectedDatesTimes.indexOf(entry),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                      .toList(),
                )
              : const SizedBox.shrink(),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              await updateCourtInFirestore(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1B7340),
              minimumSize: const Size(double.infinity, 56),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            child: const Text(
              'Update Court',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    ),
  ),
);
  }
}