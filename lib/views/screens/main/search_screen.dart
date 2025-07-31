import 'package:flutter/material.dart';
import '../../../constants/app_constants.dart';
import '../../../widgets/custom_search_field.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCity = '';
  double _minPrice = 0.0;
  double _maxPrice = 100.0;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Parking'),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search Field
            CustomSearchField(
              controller: _searchController,
              hintText: 'Search for parking spots...',
              onSubmitted: (value) {
                // TODO: Implement search functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Searching for: $value'),
                    backgroundColor: AppColors.primary,
                  ),
                );
              },
            ),
            
            const SizedBox(height: 24),
            
            // Filters Section
            Text(
              'Filters',
              style: AppTextStyles.h3,
            ),
            
            const SizedBox(height: 16),
            
            // City Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedCity.isEmpty ? null : _selectedCity,
                      decoration: const InputDecoration(
                        hintText: 'Select city',
                        border: OutlineInputBorder(),
                      ),
                      items: const [
                        DropdownMenuItem(value: 'paris', child: Text('Paris')),
                        DropdownMenuItem(value: 'london', child: Text('London')),
                        DropdownMenuItem(value: 'newyork', child: Text('New York')),
                        DropdownMenuItem(value: 'tokyo', child: Text('Tokyo')),
                      ],
                      onChanged: (value) {
                        setState(() {
                          _selectedCity = value ?? '';
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Price Range Filter
            Card(
              child: Padding(
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Price Range (per hour)',
                      style: AppTextStyles.bodyMedium.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Min Price',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _minPrice.toString(),
                            onChanged: (value) {
                              setState(() {
                                _minPrice = double.tryParse(value) ?? 0.0;
                              });
                            },
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: TextFormField(
                            decoration: const InputDecoration(
                              labelText: 'Max Price',
                              prefixText: '\$',
                            ),
                            keyboardType: TextInputType.number,
                            initialValue: _maxPrice.toString(),
                            onChanged: (value) {
                              setState(() {
                                _maxPrice = double.tryParse(value) ?? 100.0;
                              });
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            
            const Spacer(),
            
            // Search Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  // TODO: Implement search with filters
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Search functionality coming soon!'),
                      backgroundColor: AppColors.primary,
                    ),
                  );
                },
                child: const Text('Search'),
              ),
            ),
          ],
        ),
      ),
    );
  }
} 