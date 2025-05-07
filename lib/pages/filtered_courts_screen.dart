import 'package:flutter/material.dart';

class FilteredCourtsScreen extends StatelessWidget {
  final List<Map<String, dynamic>> filteredCourts;

  const FilteredCourtsScreen({super.key, required this.filteredCourts});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Filtered Courts'),
        backgroundColor: const Color(0xFF1B7340),
      ),
      body: filteredCourts.isEmpty
          ? const Center(child: Text('No courts match your filters.'))
          : ListView.builder(
              itemCount: filteredCourts.length,
              itemBuilder: (context, index) {
                final court = filteredCourts[index];
                return Card(
                  margin: const EdgeInsets.all(8.0),
                  child: ListTile(
                    leading: Image.network(
                      court['image'] ?? 'https://example.com/default-image.jpg',
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    title: Text(court['name'] ?? 'Unnamed Court'),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('District: ${court['District'] ?? 'N/A'}'),
                        Text('Category: ${court['category'] ?? 'N/A'}'),
                        if (court['date'] != null)
                          Text(
                              'Date: ${court['date'].toString().split(' ')[0]}'),
                        if (court['time'] != null)
                          Text('Time: ${court['time']}'),
                        Text('Duration: ${court['duration'] ?? 'N/A'}'),
                      ],
                    ),
                    onTap: () {
                      // Navigate to court details page
                      // You can implement this navigation based on your app's structure
                    },
                  ),
                );
              },
            ),
    );
  }
}
