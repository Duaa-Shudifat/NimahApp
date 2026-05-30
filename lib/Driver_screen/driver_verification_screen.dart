import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../Customer_screen/1.Launch/launch_welcome_screen.dart';
import 'driver_dashboard.dart';

class DriverVerificationScreen extends StatefulWidget {
  const DriverVerificationScreen({super.key});

  @override
  State<DriverVerificationScreen> createState() =>
      _DriverVerificationScreenState();
}

class _DriverVerificationScreenState extends State<DriverVerificationScreen> {
  final String uid = FirebaseAuth.instance.currentUser?.uid ?? "";
  bool _isLoading = false;
  bool _agreed = false;

  final _licenseController = TextEditingController();
  final _carModelController = TextEditingController();
  final _carPlateController = TextEditingController();
  final _carYearController = TextEditingController();
  final _experienceController = TextEditingController();

  Future<void> _submitForm() async {
    if (_licenseController.text.trim().isEmpty ||
        _carModelController.text.trim().isEmpty ||
        _carPlateController.text.trim().isEmpty ||
        _carYearController.text.trim().isEmpty ||
        _experienceController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fill all fields ⚠️")),
      );
      return;
    }

    if (!_agreed) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please agree to the pledge ⚠️")),
      );
      return;
    }

    setState(() => _isLoading = true);

    await FirebaseFirestore.instance.collection('DRIVERS').doc(uid).update({
      'driverLicense': _licenseController.text.trim(),
      'carModel': _carModelController.text.trim(),
      'carPlate': _carPlateController.text.trim(),
      'carYear': _carYearController.text.trim(),
      'experience': _experienceController.text.trim(),
      'agreedToPledge': true,
      'VerificationStatus': 'pending',
      'rejectionReason': null,
      'hasSeenAcceptedScreen': false,
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
        title: const Text("Driver Verification",
            style: TextStyle(color: Colors.brown, fontWeight: FontWeight.bold)),
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
              .collection('DRIVERS')
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
                        color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        await FirebaseAuth.instance.signOut();
                        if (!context.mounted) return;
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const LaunchWelcomeScreen()),
                              (route) => false,
                        );
                      },
                      icon: const Icon(Icons.logout, color: Colors.red),
                      label: const Text("Logout",
                          style: TextStyle(color: Colors.red, fontSize: 16)),
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
                  const Icon(Icons.celebration, size: 90, color: Colors.green),
                  const SizedBox(height: 24),
                  const Text(
                    "🎉 Congratulations!",
                    style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        color: Colors.green),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Your account has been approved.\nYou can now start delivering!",
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
                            .collection('DRIVERS')
                            .doc(uid)
                            .update({'hasSeenAcceptedScreen': true});

                        if (!context.mounted) return;
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const DriverDashboard()),
                        );
                      },
                      icon: const Icon(Icons.arrow_forward, color: Colors.white),
                      label: const Text("Start Delivering 🚗",
                          style:
                          TextStyle(color: Colors.white, fontSize: 18)),
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
                  MaterialPageRoute(builder: (_) => const DriverDashboard()),
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
                        color: Colors.orange),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.orange),
                      label: const Text("Back to Home",
                          style:
                          TextStyle(color: Colors.orange, fontSize: 16)),
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
                        color: Colors.red),
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
                      icon: const Icon(Icons.arrow_back, color: Colors.orange),
                      label: const Text("Back to Home",
                          style:
                          TextStyle(color: Colors.orange, fontSize: 16)),
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
                            .collection('DRIVERS')
                            .doc(uid)
                            .update({
                          'VerificationStatus': 'new',
                          'rejectionReason': null,
                          'hasSeenAcceptedScreen': false,
                        });
                      },
                      icon: const Icon(Icons.refresh, color: Colors.white),
                      label: const Text("Reapply",
                          style:
                          TextStyle(color: Colors.white, fontSize: 16)),
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
                  const Text("Please fill in your details",
                      style: TextStyle(fontSize: 16, color: Colors.brown)),
                  const SizedBox(height: 20),
                  _field("Driver License Number", _licenseController,
                      Icons.badge),
                  _field("Car Model (e.g. Toyota Corolla)",
                      _carModelController, Icons.directions_car),
                  _field("Car Plate Number", _carPlateController, Icons.pin),
                  _field("Car Year (e.g. 2020)", _carYearController,
                      Icons.calendar_today),
                  _field("Years of Experience", _experienceController,
                      Icons.work),
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
                            "I pledge to deliver orders safely and on time, treat customers with respect, and follow all traffic laws. I take full responsibility for any violation.",
                            style:
                            TextStyle(fontSize: 13, color: Colors.brown),
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
                          : const Text("Submit for Review",
                          style: TextStyle(
                              color: Colors.white, fontSize: 16)),
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

  Widget _field(String label, TextEditingController controller, IconData icon,
      {String? hint}) {
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