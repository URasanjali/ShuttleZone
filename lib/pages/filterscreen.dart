import 'package:flutter/material.dart';


class FilterScreen extends StatefulWidget {
  final List<Map<String, dynamic>> courtsData;

  const FilterScreen({
    super.key,
    required this.courtsData, required Null Function(dynamic filters) onFiltersApplied,
  });

  @override
  _FilterScreenState createState() => _FilterScreenState();
}

class _FilterScreenState extends State<FilterScreen> {
  // Dropdown filter options
  final List<String> districts = [
    'Ampara', 'Anuradhapura', 'Badulla', 'Batticaloa', 'Colombo',
    'Galle', 'Gampaha', 'Hambantota', 'Jaffna', 'Kalutara',
    'Kandy', 'Kegalle', 'Kilinochchi', 'Kurunegala', 'Mannar',
    'Matale', 'Matara', 'Monaragala', 'Mullaitivu', 'Nuwara Eliya',
    'Polonnaruwa', 'Puttalam', 'Ratnapura', 'Trincomalee', 'Vavuniya'
  ];

  final List<String> categories = ['Tennis', 'Badminton'];
  final List<String> durations = ['30 min', '1 h', '1 h 30 min', '2 h', '2 h 30 min', '3 h'];

  // Selected filter values
  String? selectedDistrict;
  String? selectedCategory;
  DateTime? selectedDate;
  TimeOfDay? selectedTime;
  String? selectedDuration;

  // Method to select a date
  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  // Method to select a time
  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
    if (picked != null) {
      setState(() {
        selectedTime = picked;
      });
    }
  }

  // Apply filters and navigate to FilteredCourtsScreen
  void _applyFilters() {
    List<Map<String, dynamic>> filteredCourts = widget.courtsData;

    // Apply district filter
    if (selectedDistrict != null) {
      filteredCourts = filteredCourts
          .where((court) => court['Distric'] == selectedDistrict)
          .toList();
    }

    // Apply category filter
    if (selectedCategory != null) {
      filteredCourts = filteredCourts
          .where((court) => court['category'] == selectedCategory)
          .toList();
    }

    // Apply date filter
    if (selectedDate != null) {
      filteredCourts = filteredCourts
          .where((court) =>
              court['date'] != null &&
              (court['date'] as DateTime).isAtSameMomentAs(selectedDate!))
          .toList();
    }

    // Apply time filter
    if (selectedTime != null) {
      final selectedTimeString = "${selectedTime!.hour}:${selectedTime!.minute}";
      filteredCourts = filteredCourts
          .where((court) =>
              court['time'] != null &&
              court['time'] == selectedTimeString)
          .toList();
    }

    // Apply duration filter
    if (selectedDuration != null) {
      filteredCourts = filteredCourts
          .where((court) => court['duration'] == selectedDuration)
          .toList();
    }

    // Navigate to FilteredCourtsScreen with the filtered data
    // Navigator.push(
    //   context,
    //   MaterialPageRoute(
    //     //builder: (context) => FilteredCourtsScreen(),
    //   ),
    // );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filters'),
        backgroundColor: const Color(0xFF1B7340),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // District filter dropdown
              DropdownButtonFormField<String>(
                value: selectedDistrict,
                decoration: const InputDecoration(labelText: 'Location'),
                items: districts.map((String district) {
                  return DropdownMenuItem<String>(
                    value: district,
                    child: Text(district),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDistrict = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Category filter dropdown
              DropdownButtonFormField<String>(
                value: selectedCategory,
                decoration: const InputDecoration(labelText: 'Category'),
                items: categories.map((String category) {
                  return DropdownMenuItem<String>(
                    value: category,
                    child: Text(category),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedCategory = newValue;
                  });
                },
              ),
              const SizedBox(height: 20),

              // Date and Time selectors
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectDate(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Date'),
                          controller: TextEditingController(
                            text: selectedDate != null
                                ? "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}"
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => _selectTime(context),
                      child: AbsorbPointer(
                        child: TextFormField(
                          decoration: const InputDecoration(labelText: 'Time'),
                          controller: TextEditingController(
                            text: selectedTime != null
                                ? "${selectedTime!.hour}:${selectedTime!.minute}"
                                : '',
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Duration filter dropdown
              DropdownButtonFormField<String>(
                value: selectedDuration,
                decoration: const InputDecoration(labelText: 'Duration'),
                items: durations.map((String duration) {
                  return DropdownMenuItem<String>(
                    value: duration,
                    child: Text(duration),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedDuration = newValue;
                  });
                },
              ),
              const SizedBox(height: 40),

              // Apply Filters Button
              Center(
                child: ElevatedButton(
                  onPressed: _applyFilters,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1B7340),
                    padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  ),
                  child: const Text('Apply Filters', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class FilteredCourtsScreen {
}
