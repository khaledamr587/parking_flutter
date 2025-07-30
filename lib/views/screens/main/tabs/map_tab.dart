import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../../../../constants/app_constants.dart';
import '../../../../widgets/custom_button.dart';
import '../../../../widgets/custom_search_field.dart';

class MapTab extends StatefulWidget {
  const MapTab({super.key});

  @override
  State<MapTab> createState() => _MapTabState();
}

class _MapTabState extends State<MapTab> {
  MapController? _mapController;
  Position? _currentPosition;
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  List<Marker> _markers = [];

  // Default map center (will be updated with user's location)
  static const LatLng _defaultCenter = LatLng(48.8566, 2.3522); // Paris coordinates

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _loadParkingMarkers();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Check location permission
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _isLoading = false;
          });
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      // Get current position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentPosition = position;
        _isLoading = false;
      });

      // Animate map to current position
      if (_mapController != null) {
        _mapController!.move(
          LatLng(position.latitude, position.longitude),
          15.0,
        );
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadParkingMarkers() async {
    // Load parking data from API
    try {
      if (_currentPosition != null) {
        // TODO: Replace with actual API call
        // final parkings = await _apiService.getNearbyParkings(
        //   latitude: _currentPosition!.latitude,
        //   longitude: _currentPosition!.longitude,
        //   radius: AppConstants.defaultSearchRadius,
        // );
        
        // Sample parking locations for now
        final sampleParkings = [
          {
            'id': '1',
            'name': 'Central Parking',
            'latitude': 48.8566,
            'longitude': 2.3522,
            'availableSpots': 15,
            'totalSpots': 50,
            'hourlyRate': 5.0,
          },
          {
            'id': '2',
            'name': 'Downtown Parking',
            'latitude': 48.8606,
            'longitude': 2.3376,
            'availableSpots': 8,
            'totalSpots': 30,
            'hourlyRate': 7.0,
          },
          {
            'id': '3',
            'name': 'Shopping Center Parking',
            'latitude': 48.8526,
            'longitude': 2.3666,
            'availableSpots': 25,
            'totalSpots': 100,
            'hourlyRate': 3.0,
          },
        ];

        List<Marker> markers = [];

        for (var parking in sampleParkings) {
          final marker = Marker(
            point: LatLng((parking['latitude'] as num).toDouble(), (parking['longitude'] as num).toDouble()),
            width: 40,
            height: 40,
            child: GestureDetector(
              onTap: () => _showParkingDetails(parking),
              child: Container(
                decoration: BoxDecoration(
                  color: (parking['availableSpots'] as int) > 0 
                      ? AppColors.success 
                      : AppColors.error,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 4,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_parking,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          );
          markers.add(marker);
        }

        setState(() {
          _markers = markers;
        });
      }
    } catch (e) {
      // Handle error
      print('Error loading parking markers: $e');
    }
  }

  void _showParkingDetails(Map<String, dynamic> parking) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildParkingDetailsSheet(parking),
    );
  }

  Widget _buildParkingDetailsSheet(Map<String, dynamic> parking) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.6,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.textSecondary,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    parking['name'],
                    style: AppTextStyles.h2,
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  
                  // Availability info
                  Row(
                    children: [
                      Icon(
                        (parking['availableSpots'] as int) > 0 
                            ? Icons.check_circle 
                            : Icons.cancel,
                        color: (parking['availableSpots'] as int) > 0 
                            ? AppColors.success 
                            : AppColors.error,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                                              Text(
                          (parking['availableSpots'] as int) > 0 
                              ? '${parking['availableSpots']} spots available'
                            : 'No spots available',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: parking['availableSpots']! > 0 
                              ? AppColors.success 
                              : AppColors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.smallPadding),
                  
                  // Price info
                  Row(
                    children: [
                      const Icon(
                        Icons.attach_money,
                        color: AppColors.primary,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '\$${parking['hourlyRate']}/hour',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.primary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppConstants.defaultPadding),
                  
                  // Action buttons
                  if (parking['availableSpots']! > 0) ...[
                    CustomButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _navigateToBooking(parking);
                      },
                      child: const Text('Book Now'),
                    ),
                    const SizedBox(height: AppConstants.smallPadding),
                  ],
                  
                  CustomButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _navigateToParkingDetails(parking);
                    },
                    isOutlined: true,
                    child: const Text('View Details'),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _navigateToBooking(Map<String, dynamic> parking) {
    // TODO: Navigate to booking screen
    Navigator.of(context).pushNamed(
      AppRoutes.booking,
      arguments: parking,
    );
  }

  void _navigateToParkingDetails(Map<String, dynamic> parking) {
    // TODO: Navigate to parking details screen
    Navigator.of(context).pushNamed(
      AppRoutes.parkingDetails,
      arguments: parking,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // OSM Map
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: _currentPosition != null
                  ? LatLng(_currentPosition!.latitude, _currentPosition!.longitude)
                  : _defaultCenter,
              initialZoom: 15.0,
              onMapReady: () {
                _loadParkingMarkers();
              },
            ),
            children: [
              // OSM Tile Layer
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.parkingapp.app',
              ),
              // Parking Markers
              MarkerLayer(markers: _markers),
            ],
          ),
          
          // Search bar
          Positioned(
            top: MediaQuery.of(context).padding.top + AppConstants.smallPadding,
            left: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            child: CustomSearchField(
              controller: _searchController,
              hintText: 'Search for parking...',
              onTap: () {
                // Navigate to search screen
                Navigator.of(context).pushNamed(AppRoutes.search);
              },
            ),
          ),
          
          // Location button
          Positioned(
            bottom: AppConstants.defaultPadding,
            right: AppConstants.defaultPadding,
            child: FloatingActionButton(
              onPressed: () async {
                await _getCurrentLocation();
                if (_currentPosition != null && _mapController != null) {
                  _mapController!.move(
                    LatLng(_currentPosition!.latitude, _currentPosition!.longitude),
                    15.0,
                  );
                }
              },
              backgroundColor: Colors.white,
              foregroundColor: AppColors.primary,
              child: const Icon(Icons.my_location),
            ),
          ),
          
          // Loading indicator
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.3),
              child: const Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
} 