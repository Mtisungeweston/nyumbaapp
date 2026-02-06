import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../theme/theme.dart';
import '../../widgets/map_picker.dart';
import '../../services/location_service.dart';

class AddPropertyScreen extends StatefulWidget {
  const AddPropertyScreen({Key? key}) : super(key: key);

  @override
  State<AddPropertyScreen> createState() => _AddPropertyScreenState();
}

class _AddPropertyScreenState extends State<AddPropertyScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController =
      TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _bedroomsController =
      TextEditingController(text: '2');
  final TextEditingController _bathroomsController =
      TextEditingController(text: '1');

  String _selectedCity = 'Lilongwe';
  String _selectedPropertyType = 'Apartment';
  
  // Location data
  LatLng? _selectedLocation;
  final LocationService _locationService = LocationService();

  final List<String> cities = [
    'Lilongwe',
    'Blantyre',
    'Mzuzu',
    'Zomba',
    'Mangochi'
  ];
  final List<String> propertyTypes = [
    'Apartment',
    'House',
    'Studio',
    'Villa',
    'Flat'
  ];

  void _openMapPicker() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => MapPicker(
          initialLocation: _selectedLocation,
          onLocationSelected: (location) {
            setState(() {
              _selectedLocation = location;
              _addressController.text = 
                '${location.latitude.toStringAsFixed(4)}, ${location.longitude.toStringAsFixed(4)}';
            });
          },
        ),
      ),
    );
  }

  void _getCurrentLocation() async {
    final position = await _locationService.getCurrentLocation();
    if (position != null) {
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _addressController.text = 
          '${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}';
      });
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _descriptionController.dispose();
    _addressController.dispose();
    _priceController.dispose();
    _bedroomsController.dispose();
    _bathroomsController.dispose();
    super.dispose();
  }

  void _submitProperty() {
    if (_titleController.text.isEmpty ||
        _priceController.text.isEmpty ||
        _addressController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fill in all required fields'),
        ),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Property listing created successfully!'),
      ),
    );

    context.go('/landlord/listings');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        title: const Text('Add New Property'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Basic info section
            Text(
              'Basic Information',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: 'Property Title',
                hintText: 'e.g., Modern 2BR Apartment',
              ),
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description',
                hintText: 'Describe your property...',
              ),
              maxLines: 4,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: _selectedPropertyType,
              decoration: const InputDecoration(
                labelText: 'Property Type',
              ),
              items: propertyTypes
                  .map((type) => DropdownMenuItem(
                    value: type,
                    child: Text(type),
                  ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedPropertyType = value);
                }
              },
            ),
            const SizedBox(height: 32),

            // Location section
            Text(
              'Location',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            DropdownButtonFormField<String>(
              value: _selectedCity,
              decoration: const InputDecoration(
                labelText: 'City',
              ),
              items: cities
                  .map((city) => DropdownMenuItem(
                    value: city,
                    child: Text(city),
                  ))
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() => _selectedCity = value);
                }
              },
            ),
            const SizedBox(height: 12),

            TextFormField(
              controller: _addressController,
              decoration: const InputDecoration(
                labelText: 'Address',
                hintText: 'Street address',
              ),
            ),
            const SizedBox(height: 32),

            // Pricing section
            Text(
              'Pricing',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            TextFormField(
              controller: _priceController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Monthly Rent (MWK)',
                prefixText: 'K',
              ),
            ),
            const SizedBox(height: 32),

            // Property details section
            Text(
              'Property Details',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: TextFormField(
                    controller: _bedroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bedrooms',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextFormField(
                    controller: _bathroomsController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Bathrooms',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),

            // Amenities section
            Text(
              'Amenities',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),

            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                'Air Conditioning',
                'Parking',
                'Kitchen',
                'Security',
                'Water Tank',
                'Balcony',
                'Garden',
                'Furnished',
              ]
                  .map(
                    (amenity) => FilterChip(
                      label: Text(amenity),
                      onSelected: (selected) {},
                      backgroundColor: AppTheme.backgroundColor,
                      side: const BorderSide(color: AppTheme.borderColor),
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 32),

            // Photo section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.surfaceColor,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.borderColor),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.image_outlined,
                    size: 48,
                    color: AppTheme.textSecondaryColor,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Add Photos',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Upload at least 3 photos of your property',
                    style: Theme.of(context).textTheme.bodySmall,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  ElevatedButton.icon(
                    onPressed: () {},
                    icon: const Icon(Icons.camera_alt),
                    label: const Text('Choose Photos'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _submitProperty,
                child: const Text('Post Property'),
              ),
            ),
            const SizedBox(height: 16),

            // Cancel button
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
