// K - Add New Address Screen
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';

class AddAddressScreen extends StatefulWidget {
  const AddAddressScreen({super.key});

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final MapController _mapController = MapController();

  LatLng _selectedLocation = const LatLng(32.5568, 35.8469); // إربد افتراضي
  bool _isLoadingLocation = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    setState(() => _isLoadingLocation = true);
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.whileInUse ||
          permission == LocationPermission.always) {
        Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
        setState(() {
          _selectedLocation = LatLng(position.latitude, position.longitude);
        });
        _mapController.move(_selectedLocation, 15);
      }
    } catch (e) {
      debugPrint('Location error: $e');
    } finally {
      if (mounted) setState(() => _isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Positioned(
            top: 35,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "Add New Address",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                  ),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        // ✅ الخريطة مع تحديد الموقع
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: SizedBox(
                            height: 250,
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(
                                    initialCenter: _selectedLocation,
                                    initialZoom: 15,
                                    onTap: (tapPosition, point) {
                                      setState(() {
                                        _selectedLocation = point;
                                        addressController.text =
                                        "${point.latitude.toStringAsFixed(5)}, ${point.longitude.toStringAsFixed(5)}";
                                      });
                                    },
                                  ),
                                  children: [
                                    TileLayer(
                                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                                      userAgentPackageName: 'com.example.nimah_app', // ← اسم الباكج تبعك
                                    ),
                                    MarkerLayer(
                                      markers: [
                                        Marker(
                                          point: _selectedLocation,
                                          width: 40,
                                          height: 40,
                                          child: const Icon(
                                            Icons.location_on,
                                            color: Colors.deepOrange,
                                            size: 40,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                // ✅ زر موقعي الحالي
                                Positioned(
                                  bottom: 10,
                                  right: 10,
                                  child: FloatingActionButton.small(
                                    backgroundColor: Colors.white,
                                    onPressed: _getCurrentLocation,
                                    child: _isLoadingLocation
                                        ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.deepOrange,
                                      ),
                                    )
                                        : const Icon(
                                      Icons.my_location,
                                      color: Colors.deepOrange,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),
                        const Text(
                          "Tap on the map to select your location",
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 20),

                        _input("Name", "Anna House", nameController),
                        _input(
                          "Address",
                          "778 Locust View Drive, CA",
                          addressController,
                        ),

                        const SizedBox(height: 20),

                        // ✅ زر Apply
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (nameController.text.isEmpty) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text("Please enter a name"),
                                  ),
                                );
                                return;
                              }
                              Navigator.pop(context, {
                                "title": nameController.text,
                                "address": addressController.text.isEmpty
                                    ? "${_selectedLocation.latitude.toStringAsFixed(5)}, ${_selectedLocation.longitude.toStringAsFixed(5)}"
                                    : addressController.text,
                                "lat": _selectedLocation.latitude,
                                "lng": _selectedLocation.longitude,
                              });
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Apply",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _input(
      String label, String hint, TextEditingController controller) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.deepOrange,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 5),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}