import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'provider_home_screen.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';

class ProviderVerificationScreen extends StatefulWidget {
  const ProviderVerificationScreen({super.key});

  @override
  State<ProviderVerificationScreen> createState() =>
      _ProviderVerificationScreenState();
}

class _ProviderVerificationScreenState
    extends State<ProviderVerificationScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool _isLoading = false;
  bool _agreed = false;
  LatLng? _selectedLocation;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      _selectedLocation = const LatLng(31.9454, 35.9284);
    }
  }

  final _locationNameController = TextEditingController();
  final _restaurantLicenseController = TextEditingController();
  final _foodLicenseController = TextEditingController();
  final _openTimeController = TextEditingController();
  final _closeTimeController = TextEditingController();

  Future<void> _submitForm() async {
    if (_locationNameController.text.trim().isEmpty ||
        _restaurantLicenseController.text.trim().isEmpty ||
        _foodLicenseController.text.trim().isEmpty ||
        _openTimeController.text.trim().isEmpty ||
        _closeTimeController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields ⚠️")),
      );
      return;
    }

    _selectedLocation ??= const LatLng(31.9454, 35.9284);

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the pledge ⚠️")),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance
        .collection('FOOD_PROVIDERS')
        .doc(uid)
        .update({
      'locationName': _locationNameController.text.trim(),
      'restaurantLicense': _restaurantLicenseController.text.trim(),
      'foodLicense': _foodLicenseController.text.trim(),
      'workingHours':
      '${_openTimeController.text.trim()} - ${_closeTimeController.text.trim()}',
      'agreedToPledge': true,
      'latitude': _selectedLocation!.latitude,
      'longitude': _selectedLocation!.longitude,
      'VerificationStatus': 'pending',
      'rejectionReason': null,
    });

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Account Verification",
          style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(top: 20),
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(40),
            topRight: Radius.circular(40),
          ),
        ),
        child: StreamBuilder<DocumentSnapshot>(
          stream: FirebaseFirestore.instance
              .collection('FOOD_PROVIDERS')
              .doc(uid)
              .snapshots(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }

            final data =
                snapshot.data!.data() as Map<String, dynamic>? ?? {};
            final status = data['VerificationStatus'] ?? 'new';
            final bool isBlocked = data['blocked'] ?? false;
            final bool hasSeenAccepted =
                data['hasSeenAcceptedScreen'] ?? false;

            if (isBlocked) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.block, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    "Your account has been blocked.\nPlease contact support.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LaunchWelcomeScreen()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text(
                        "Logout",
                        style: TextStyle(color: Colors.red, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.red),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (status == 'accepted' && !hasSeenAccepted) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.celebration,
                      size: 90, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    "🎉 Congratulations!",
                    style: TextStyle(
                      fontSize: 26,
                      fontWeight: FontWeight.bold,
                      color: Colors.green,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your account has been accepted.\nYou can now start receiving orders!",
                    style: TextStyle(fontSize: 16, color: Colors.black54),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('FOOD_PROVIDERS')
                            .doc(uid)
                            .update({'hasSeenAcceptedScreen': true});

                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ProviderHomeScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward,
                          color: Colors.white),
                      label: const Text(
                        "Continue",
                        style:
                        TextStyle(color: Colors.white, fontSize: 18),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (status == 'accepted' && hasSeenAccepted) {
              WidgetsBinding.instance.addPostFrameCallback((_) {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const ProviderHomeScreen()),
                );
              });
              return const Center(
                child: CircularProgressIndicator(color: Colors.green),
              );
            }

            if (status == 'pending') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.hourglass_top,
                      size: 80, color: Colors.orange),
                  const SizedBox(height: 20),
                  const Text(
                    "Under Review... Please wait.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LaunchWelcomeScreen()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.orange),
                      label: const Text(
                        "Back to Home",
                        style:
                        TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              );
            }

            if (status == 'rejected') {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.cancel, size: 80, color: Colors.red),
                  const SizedBox(height: 20),
                  const Text(
                    "Rejected ❌ Please contact support.",
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  if (data['rejectionReason'] != null &&
                      data['rejectionReason'].toString().isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.red.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.red.shade200),
                        ),
                        child: Text(
                          "Reason: ${data['rejectionReason']}",
                          style: const TextStyle(
                              color: Colors.red, fontSize: 14),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LaunchWelcomeScreen()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.arrow_back,
                          color: Colors.orange),
                      label: const Text(
                        "Back to Home",
                        style:
                        TextStyle(color: Colors.orange, fontSize: 16),
                      ),
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: Colors.orange),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 15),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton.icon(
                      onPressed: () async {
                        await FirebaseFirestore.instance
                            .collection('FOOD_PROVIDERS')
                            .doc(uid)
                            .update({
                          'VerificationStatus': 'new',
                          'rejectionReason': null,
                        });
                      },
                      icon:
                      const Icon(Icons.refresh, color: Colors.white),
                      label: const Text(
                        "Reapply",
                        style:
                        TextStyle(color: Colors.white, fontSize: 16),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                    ),
                  ),
                ],
              );
            }

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 10),
                  const Text(
                    "Please fill in your restaurant details",
                    style: TextStyle(fontSize: 16, color: Colors.brown),
                  ),
                  const SizedBox(height: 20),

                  _field("Restaurant Name", _locationNameController,
                      Icons.storefront),
                  _field("Restaurant License Number",
                      _restaurantLicenseController, Icons.badge),
                  _field("Food Safety License Number",
                      _foodLicenseController, Icons.food_bank),

                  const Text(
                    "Restaurant Location",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.deepOrange.withOpacity(0.3)),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(15),
                      child: FlutterMap(
                        options: MapOptions(
                          initialCenter: const LatLng(31.9454, 35.9284),
                          initialZoom: 10,
                          onTap: (tapPosition, point) {
                            setState(() => _selectedLocation = point);
                          },
                        ),
                        children: [
                          TileLayer(
                            urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                            userAgentPackageName: 'com.example.nimah_app',
                          ),
                          if (_selectedLocation != null)
                            MarkerLayer(
                              markers: [
                                Marker(
                                  point: _selectedLocation!,
                                  width: 40,
                                  height: 40,
                                  child: const Icon(
                                    Icons.location_pin,
                                    color: Colors.deepOrange,
                                    size: 40,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                    ),
                  ),
                  if (_selectedLocation != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6, bottom: 15),
                      child: Text(
                        "📍 ${_selectedLocation!.latitude.toStringAsFixed(4)}, ${_selectedLocation!.longitude.toStringAsFixed(4)}",
                        style: const TextStyle(
                            color: Colors.deepOrange, fontSize: 13),
                      ),
                    )
                  else
                    const Padding(
                      padding: EdgeInsets.only(top: 6, bottom: 15),
                      child: Text(
                        "Tap on the map to select your location",
                        style:
                        TextStyle(color: Colors.grey, fontSize: 13),
                      ),
                    ),

                  const Text(
                    "Working Hours",
                    style: TextStyle(
                        fontWeight: FontWeight.bold, color: Colors.brown),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                          child: _field("Open", _openTimeController,
                              Icons.access_time,
                              hint: "e.g. 9:00 AM")),
                      const SizedBox(width: 10),
                      Expanded(
                          child: _field("Close", _closeTimeController,
                              Icons.access_time_filled,
                              hint: "e.g. 11:00 PM")),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFF3DC),
                      borderRadius: BorderRadius.circular(15),
                      border: Border.all(
                          color: Colors.deepOrange.withOpacity(0.3)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Checkbox(
                          value: _agreed,
                          activeColor: Colors.deepOrange,
                          onChanged: (v) =>
                              setState(() => _agreed = v ?? false),
                        ),
                        const Expanded(
                          child: Text(
                            "I pledge that all products provided through this platform are safe for human consumption and comply with food safety standards. I take full responsibility for any violation of this pledge.",
                            style: TextStyle(
                                fontSize: 13, color: Colors.brown),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),

                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: _isLoading ? null : _submitForm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepOrange,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15)),
                      ),
                      child: _isLoading
                          ? const CircularProgressIndicator(
                          color: Colors.white)
                          : const Text(
                        "Submit for Review",
                        style: TextStyle(
                            color: Colors.white, fontSize: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _field(
      String label,
      TextEditingController controller,
      IconData icon, {
        String? hint,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CB58).withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.deepOrange.withOpacity(0.2)),
      ),
      child: TextField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          hintText: hint,
          prefixIcon: Icon(icon, color: Colors.deepOrange),
          border: InputBorder.none,
          contentPadding:
          const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
        ),
      ),
    );
  }
}