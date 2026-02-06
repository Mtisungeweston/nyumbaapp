import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../theme/theme.dart';
import '../../widgets/property_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late TextEditingController _searchController;
  String _selectedCity = 'All';
  String _selectedPriceRange = 'All';
  bool _showFilters = false;

  final List<String> cities = ['All', 'Lilongwe', 'Blantyre', 'Mzuzu', 'Zomba'];
  final List<String> priceRanges = [
    'All',
    'Under 50,000',
    '50,000 - 100,000',
    '100,000 - 200,000',
    'Over 200,000'
  ];

  // Mock property data
  final List<Map<String, dynamic>> properties = [
    {
      'id': '1',
      'title': 'Modern 2BR Apartment',
      'location': 'Lilongwe',
      'price': 75000,
      'bedrooms': 2,
      'bathrooms': 1,
      'image': 'https://via.placeholder.com/400x300?text=Apartment+1',
      'isFavorite': false,
    },
    {
      'id': '2',
      'title': 'Spacious 3BR House',
      'location': 'Blantyre',
      'price': 120000,
      'bedrooms': 3,
      'bathrooms': 2,
      'image': 'https://via.placeholder.com/400x300?text=House+1',
      'isFavorite': false,
    },
    {
      'id': '3',
      'title': 'Cozy Studio Apartment',
      'location': 'Lilongwe',
      'price': 35000,
      'bedrooms': 1,
      'bathrooms': 1,
      'image': 'https://via.placeholder.com/400x300?text=Studio+1',
      'isFavorite': false,
    },
    {
      'id': '4',
      'title': 'Luxury 4BR Villa',
      'location': 'Blantyre',
      'price': 250000,
      'bedrooms': 4,
      'bathrooms': 3,
      'image': 'https://via.placeholder.com/400x300?text=Villa+1',
      'isFavorite': false,
    },
    {
      'id': '5',
      'title': 'Comfortable 2BR Flat',
      'location': 'Mzuzu',
      'price': 55000,
      'bedrooms': 2,
      'bathrooms': 1,
      'image': 'https://via.placeholder.com/400x300?text=Flat+1',
      'isFavorite': false,
    },
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Nyumba'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () => context.go('/profile'),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar
            Padding(
              padding: const EdgeInsets.all(16),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Search properties...',
                  prefixIcon: const Icon(Icons.search),
                  suffixIcon: _showFilters
                      ? IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () {
                            setState(() => _showFilters = false);
                          },
                        )
                      : IconButton(
                          icon: const Icon(Icons.tune),
                          onPressed: () {
                            setState(() => _showFilters = !_showFilters);
                          },
                        ),
                ),
              ),
            ),

            // Filters
            if (_showFilters)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'City',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: cities
                            .map(
                              (city) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(city),
                                  selected: _selectedCity == city,
                                  onSelected: (selected) {
                                    setState(() => _selectedCity = city);
                                  },
                                  backgroundColor: AppTheme.surfaceColor,
                                  selectedColor: AppTheme.primaryColor,
                                  labelStyle: TextStyle(
                                    color: _selectedCity == city
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Price Range',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: priceRanges
                            .map(
                              (range) => Padding(
                                padding: const EdgeInsets.only(right: 8),
                                child: FilterChip(
                                  label: Text(range),
                                  selected: _selectedPriceRange == range,
                                  onSelected: (selected) {
                                    setState(
                                        () => _selectedPriceRange = range);
                                  },
                                  backgroundColor: AppTheme.surfaceColor,
                                  selectedColor: AppTheme.primaryColor,
                                  labelStyle: TextStyle(
                                    color: _selectedPriceRange == range
                                        ? Colors.white
                                        : AppTheme.textPrimaryColor,
                                  ),
                                ),
                              ),
                            )
                            .toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),

            // Properties list
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: properties
                    .map(
                      (property) => Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: PropertyCard(
                          property: property,
                          onTap: () => context.go('/property/${property['id']}'),
                          onFavoriteTap: () {
                            setState(() {
                              property['isFavorite'] =
                                  !property['isFavorite'];
                            });
                          },
                        ),
                      ),
                    )
                    .toList(),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/landlord/listings'),
        backgroundColor: AppTheme.primaryColor,
        child: const Icon(Icons.add),
      ),
    );
  }
}
