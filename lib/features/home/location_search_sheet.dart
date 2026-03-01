import 'package:flutter/material.dart';
import 'package:ride_karo/shared/app_theme.dart';

/// Location search bottom sheet matching the Kotlin [LocationSearchFragment].
///
/// Allows the user to type a destination address and select it.
/// Uses a simple text entry approach matching the original geocoder-based flow.
class LocationSearchSheet extends StatefulWidget {
  /// Creates the location search sheet.
  const LocationSearchSheet({
    super.key,
    required this.onDestinationSelected,
  });

  /// Callback when a destination is selected.
  final ValueChanged<String> onDestinationSelected;

  @override
  State<LocationSearchSheet> createState() => _LocationSearchSheetState();
}

class _LocationSearchSheetState extends State<LocationSearchSheet> {
  final TextEditingController _searchController = TextEditingController();

  /// Suggested locations for quick selection.
  static const List<String> _suggestions = [
    'Bandra Station, Mumbai',
    'Bandra West, Mumbai',
    'Bandra East, Mumbai',
    'Gorai Naka, Mumbai',
    'Santosh Bhuvan, Mumbai',
    'Tulinj Road, Mumbai',
    'Vasai, Mumbai',
    'Andheri Station, Mumbai',
    'Juhu Beach, Mumbai',
    'CST Station, Mumbai',
  ];

  List<String> _filteredSuggestions = [];

  @override
  void initState() {
    super.initState();
    _filteredSuggestions = List.from(_suggestions);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Search drop location',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'ProductSans',
            ),
          ),
          const SizedBox(height: 12),
          // Search input
          TextField(
            controller: _searchController,
            autofocus: true,
            onChanged: _onSearchChanged,
            onSubmitted: _onSearchSubmitted,
            decoration: InputDecoration(
              hintText: 'Enter Destination',
              hintStyle: const TextStyle(fontFamily: 'ProductSans'),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Colors.grey.shade100,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Suggestions list
          Expanded(
            child: ListView.builder(
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                return ListTile(
                  leading: const Icon(
                    Icons.location_on_outlined,
                    color: AppTheme.accentOrange,
                  ),
                  title: Text(
                    _filteredSuggestions[index],
                    style: const TextStyle(fontFamily: 'ProductSans'),
                  ),
                  onTap: () {
                    widget.onDestinationSelected(_filteredSuggestions[index]);
                    Navigator.of(context).pop();
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _onSearchChanged(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSuggestions = List.from(_suggestions);
      } else {
        _filteredSuggestions = _suggestions
            .where((s) => s.toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _onSearchSubmitted(String query) {
    if (query.trim().isNotEmpty) {
      widget.onDestinationSelected(query.trim());
      Navigator.of(context).pop();
    }
  }
}
