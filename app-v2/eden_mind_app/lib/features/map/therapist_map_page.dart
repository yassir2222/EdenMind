import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:eden_mind_app/theme/app_theme.dart';
import 'package:eden_mind_app/features/map/models/therapist.dart';
import 'package:eden_mind_app/features/map/services/location_service.dart';
import 'package:eden_mind_app/features/map/services/therapist_repository.dart';

class TherapistMapPage extends StatefulWidget {
  const TherapistMapPage({super.key});

  @override
  State<TherapistMapPage> createState() => _TherapistMapPageState();
}

class _TherapistMapPageState extends State<TherapistMapPage> {
  final MapController _mapController = MapController();
  final LocationService _locationService = LocationService();
  final TherapistRepository _therapistRepository = TherapistRepository();

  Therapist? _selectedTherapist;
  List<Therapist> _therapists = [];
  bool _isLoading = true;
  LatLng _initialCenter = const LatLng(48.8566, 2.3522); // Default to Paris
  LatLng? _userLocation;

  @override
  void initState() {
    super.initState();
    _initializeMap();
  }

  Future<void> _initializeMap() async {
    try {
      final position = await _locationService.determinePosition();
      final latLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _initialCenter = latLng;
        _userLocation = latLng;
      });

      // Move map to user location immediately
      _mapController.move(latLng, 14.0);

      // Fetch nearby therapists
      final therapists = await _therapistRepository.searchTherapists(
        position.latitude,
        position.longitude,
      );

      setState(() {
        _therapists = therapists;
        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Error initializing map: $e");
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Could not get location: $e")));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Map Layer
          FlutterMap(
            mapController: _mapController,

            options: MapOptions(
              initialCenter: _initialCenter,
              initialZoom: 13.0,
              onTap: (_, __) {
                if (_selectedTherapist != null) {
                  setState(() => _selectedTherapist = null);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.edenmind.app',
                // Using a darkish minimal style if possible, or standard OSM
                // For "premium" feel, we might want a custom tile provider later,
                // but standard OSM is free and reliable for now.
                // We can add a dark overlay for style.
              ),
              if (_userLocation != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _userLocation!,
                      width: 20,
                      height: 20,
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.blue,
                          border: Border.all(color: Colors.white, width: 3),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.2),
                              blurRadius: 5,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),

              // Dark overlay for night mode feel if desired, or just clean OSM
              // Let's stick to clean OSM but maybe custom markers pop more.
              MarkerLayer(
                markers: _therapists.map((therapist) {
                  final isSelected = _selectedTherapist?.id == therapist.id;
                  return Marker(
                    point: therapist.location,
                    width: 60,
                    height: 60,
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedTherapist = therapist;
                        });
                        _mapController.move(therapist.location, 14.5);
                      },
                      child: _buildCustomMarker(therapist, isSelected),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // Custom Header
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 20),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                ),
              ),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white.withOpacity(0.3),
                        ),
                      ),
                      child: const Icon(Icons.arrow_back, color: Colors.white),
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Text(
                    "Nearby Therapists",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom Sheet / Info Card
          if (_selectedTherapist != null)
            Positioned(
              bottom: 30,
              left: 20,
              right: 20,
              child: _buildTherapistCard(_selectedTherapist!)
                  .animate()
                  .slideY(
                    begin: 1.0,
                    end: 0,
                    curve: Curves.easeOutExpo,
                    duration: 500.ms,
                  )
                  .fadeIn(),
            ),
          if (!_isLoading && _therapists.isEmpty)
            Center(
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Text(
                  "No therapists found nearby",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ),
          if (_isLoading)
            Container(
              color: Colors.black.withOpacity(0.5),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          try {
            final pos = await _locationService.determinePosition();
            _mapController.move(LatLng(pos.latitude, pos.longitude), 15);
          } catch (e) {
            // handle error
          }
        },
        backgroundColor: EdenMindTheme.primaryColor,
        child: const Icon(Icons.my_location),
      ),
    );
  }

  Widget _buildCustomMarker(Therapist therapist, bool isSelected) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        AnimatedContainer(
          duration: 300.ms,
          width: isSelected ? 55 : 45,
          height: isSelected ? 55 : 45,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.white,
            border: Border.all(
              color: isSelected ? EdenMindTheme.primaryColor : Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.3),
                blurRadius: 10,
                offset: const Offset(0, 5),
              ),
            ],
            image: DecorationImage(
              image: NetworkImage(therapist.imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        ),
        if (isSelected)
          Container(
            margin: const EdgeInsets.only(top: 4),
            padding: const EdgeInsets.all(2),
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.arrow_drop_down,
              color: EdenMindTheme.primaryColor,
              size: 14,
            ),
          ),
      ],
    );
  }

  Widget _buildTherapistCard(Therapist therapist) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D2E33), // Dark premium card
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(color: Colors.white.withOpacity(0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.network(
                  therapist.imageUrl,
                  width: 60,
                  height: 60,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      therapist.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      therapist.specialty,
                      style: TextStyle(color: Colors.grey[400], fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.star, color: Colors.amber, size: 16),
                        const SizedBox(width: 4),
                        Text(
                          "${therapist.rating}",
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          " (${therapist.reviewCount} reviews)",
                          style: TextStyle(
                            color: Colors.grey[500],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.grey, size: 18),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  therapist.address,
                  style: TextStyle(color: Colors.grey[300]),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    // In real app, make a call or open booking page
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white.withOpacity(0.1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 0,
                  ),
                  child: const Text("View Profile"),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: EdenMindTheme.primaryColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    elevation: 5,
                    shadowColor: EdenMindTheme.primaryColor.withOpacity(0.5),
                  ),
                  child: const Text("Book Now"),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
