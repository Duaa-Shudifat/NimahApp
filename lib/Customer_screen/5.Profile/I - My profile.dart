import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedCity;
  bool _isLoading = false;
  final user = FirebaseAuth.instance.currentUser;

  final List<String> _jordanCities = [
    'Amman', 'Irbid', 'Zarqa', 'Aqaba', 'Salt',
    'Mafraq', 'Jerash', 'Ajloun', 'Karak', 'Tafilah', "Ma'an", 'Madaba',
  ];

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    String fullPhone = "+962${_phoneController.text.trim()}";
    if (!RegExp(r'^\+9627\d{8}$').hasMatch(fullPhone)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Phone should be +962 followed by 9 digits starting with 7")),
      );
      return;
    }

    if (_selectedCity == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select a city")),
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      await FirebaseFirestore.instance
          .collection('CUSTOMERS')
          .doc(user?.uid)
          .update({
        'name': _nameController.text.trim(),
        'phone': fullPhone,
        'city': _selectedCity,
        'selectedCity': '$_selectedCity, Jordan',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Profile Updated Successfully! ✅")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: $e")),
      );
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange, size: 30),
              onPressed: () => Navigator.pop(context, _selectedCity),            ),
          ),
          Column(
            children: [
              const SizedBox(height: 60),
              const Text(
                "My Profile",
                style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown),
              ),
              const SizedBox(height: 40),
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
                  child: FutureBuilder<DocumentSnapshot>(
                    future: FirebaseFirestore.instance
                        .collection('CUSTOMERS')
                        .doc(user?.uid)
                        .get(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }

                      if (!snapshot.hasData || !snapshot.data!.exists) {
                        return const Center(child: Text("User not found"));
                      }

                      var userData =
                      snapshot.data!.data() as Map<String, dynamic>;

                      if (_nameController.text.isEmpty) {
                        _nameController.text = userData['name'] ?? "";

                        String rawPhone = userData['phone'] ?? "";
                        _phoneController.text = rawPhone.startsWith('+962')
                            ? rawPhone.substring(4)
                            : rawPhone;

                        String savedCity = userData['city'] ?? "";
                        if (_jordanCities.contains(savedCity)) {
                          _selectedCity = savedCity;
                        }
                      }

                      return SingleChildScrollView(
                        child: Column(
                          children: [
                            const CircleAvatar(
                              radius: 50,
                              backgroundImage: AssetImage(
                                  'assets/images/profile_photo.png'),
                            ),
                            const SizedBox(height: 20),

                            _buildEditableField(
                              "Full Name",
                              _nameController,
                              Icons.person,
                            ),

                            _buildPhoneField(),

                            _buildCityDropdown(),

                            _buildReadOnlyField(
                                "Email", userData['email'] ?? "N/A"),
                            _buildReadOnlyField(
                                "Role", userData['role'] ?? "User"),

                            const SizedBox(height: 30),

                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.deepOrange,
                                  padding: const EdgeInsets.symmetric(
                                      vertical: 14),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                      BorderRadius.circular(15)),
                                ),
                                onPressed:
                                _isLoading ? null : _updateProfile,
                                child: _isLoading
                                    ? const CircularProgressIndicator(
                                    color: Colors.white)
                                    : const Text(
                                  "Save Changes",
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16),
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
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPhoneField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Phone Number",
          style: TextStyle(
              color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 12, vertical: 14),
                decoration: BoxDecoration(
                  border: Border(
                    right: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: const Text(
                  "+962",
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: Colors.brown),
                ),
              ),
              Expanded(
                child: TextField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(9),
                  ],
                  decoration: const InputDecoration(
                    hintText: "7XXXXXXXX",
                    hintStyle: TextStyle(color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                        horizontal: 12, vertical: 14),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildCityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "City",
          style: TextStyle(
              color: Colors.deepOrange, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(12),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              isExpanded: true,
              value: _selectedCity,
              hint: const Text("Select City",
                  style: TextStyle(color: Colors.grey)),
              icon: const Icon(Icons.keyboard_arrow_down_rounded,
                  color: Colors.deepOrange),
              items: _jordanCities.map((city) {
                return DropdownMenuItem(
                  value: city,
                  child: Row(
                    children: [
                      const Icon(Icons.location_city_rounded,
                          size: 16, color: Colors.deepOrange),
                      const SizedBox(width: 8),
                      Text(city,
                          style: const TextStyle(color: Colors.brown)),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (val) => setState(() => _selectedCity = val),
            ),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildEditableField(
      String label, TextEditingController controller, IconData icon) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.deepOrange, fontWeight: FontWeight.bold)),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            prefixIcon: Icon(icon, color: Colors.grey),
            filled: true,
            fillColor: Colors.grey.shade100,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
                horizontal: 15, vertical: 12),
          ),
        ),
        const SizedBox(height: 15),
      ],
    );
  }

  Widget _buildReadOnlyField(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: const TextStyle(
                color: Colors.grey, fontWeight: FontWeight.bold)),
        const SizedBox(height: 5),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(value,
              style:
              const TextStyle(fontSize: 16, color: Colors.black54)),
        ),
        const SizedBox(height: 15),
      ],
    );
  }
}