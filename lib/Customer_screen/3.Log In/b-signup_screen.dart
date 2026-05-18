import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import '../../Driver_screen/driver_dashboard.dart';
import '../../Driver_screen/driver_verification_screen.dart';
import '../../Provider_screen/provider_varification_screen.dart';
import '../../language/app_strings.dart';
import '../../provider_screen/provider_home_screen.dart';
import '../1.Launch/launch_welcome_screen.dart';
import '../2.On Boarding/onboarding_a_screen.dart';
import '../4.Home Page/HomePage.dart';
import '../4.Home Page/back_icon.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  String generatedOTP = "";
  String? selectedRole;
  String? selectedCity;
  String? selectedVehicleType;
  String? selectedProviderType;

  bool isPasswordHidden = true;
  bool isConfirmPasswordHidden = true;
  bool _isLoading = false;

  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
  TextEditingController();

  XFile? _restaurantImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    phoneController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  String generateOTP() {
    return (100000 + (DateTime.now().millisecondsSinceEpoch % 900000))
        .toString();
  }

  Future<void> sendEmailOTP(String email) async {
    generatedOTP = generateOTP();

    final url = Uri.parse('https://api.emailjs.com/api/v1.0/email/send');

    await http.post(
      url,
      headers: {
        'origin': 'http://localhost',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'service_id': 'service_xjfnutt',
        'template_id': 'template_ypvh1es',
        'user_id': 'ii-AiqdAYSDiSYL49',
        'template_params': {
          'to_email': email,
          'otp': generatedOTP,
        }
      }),
    );
  }

  Widget customInput({required Widget child}) {
    return Container(
      height: 50,
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      decoration: BoxDecoration(
        color: const Color(0xFFF5CB58),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Center(child: child),
    );
  }

  InputDecoration inputDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.brown, fontSize: 14),
      border: InputBorder.none,
    );
  }

  Future<String?> _uploadProviderImage(String uid) async {
    if (_restaurantImage == null) return null;
    try {
      final url = Uri.parse(
          'https://api.cloudinary.com/v1_1/dasrhmmgz/image/upload');
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'f19cagom'
        ..files.add(await http.MultipartFile.fromPath('file', _restaurantImage!.path));
      final response = await request.send();
      final responseData = await response.stream.toBytes();
      final jsonData = jsonDecode(String.fromCharCodes(responseData));
      if (response.statusCode == 200) return jsonData['secure_url'];
      return null;
    } catch (e) {
      debugPrint('Image upload error: $e');
      return null;
    }
  }

  bool _validateBeforeOTP() {
    final password = passwordController.text;

    // 1. Check for empty fields
    if (nameController.text.trim().isEmpty ||
        emailController.text.trim().isEmpty ||
        phoneController.text.trim().isEmpty ||
        password.isEmpty ||
        selectedCity == null ||
        selectedRole == null) {
      _showSnackBar('Please fill all fields');
      return false;
    }

    // 2. Email Validation
    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(emailController.text.trim())) {
      _showSnackBar("Invalid email format");
      return false;
    }

    // 3. 🔥 Password Strength Validations
    if (password.length < 8) {
      _showSnackBar("Password should be at least 8 characters");
      return false;
    }
    if (!RegExp(r'[A-Z]').hasMatch(password)) {
      _showSnackBar("Password should contain at least one uppercase letter");
      return false;
    }
    if (!RegExp(r'[a-z]').hasMatch(password)) {
      _showSnackBar("Password should contain at least one lowercase letter");
      return false;
    }
    if (!RegExp(r'[0-9]').hasMatch(password)) {
      _showSnackBar("Password should contain at least one number");
      return false;
    }
    if (!RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) {
      _showSnackBar("Password should contain at least one special character");
      return false;
    }

    // 4. Confirm Password Match
    if (password != confirmPasswordController.text) {
      _showSnackBar('Passwords do not match');
      return false;
    }

    // 5. Phone Validation (+962)
    String fullPhone = "+962${phoneController.text.trim()}";
    if (!RegExp(r'^\+9627\d{8}$').hasMatch(fullPhone)) {
      _showSnackBar("Phone should be +962 followed by 8 digits (7XXXXXXXX)");
      return false;
    }

    // 6. Role Specific Validations
    if (selectedRole == 'driver' && selectedVehicleType == null) {
      _showSnackBar('Please select vehicle type');
      return false;
    }

    if (selectedRole == 'provider') {
      if (selectedProviderType == null) {
        _showSnackBar('Please select provider type');
        return false;
      }
      if (_restaurantImage == null) {
        _showSnackBar("Please upload a logo");
        return false;
      }
    }

    // 7. Name Validation
    String name = nameController.text.trim();
    if (!RegExp(r'^[a-zA-Z\u0600-\u06FF ]{3,30}$').hasMatch(name)) {
      _showSnackBar("Name should be 3-30 letters only");
      return false;
    }

    return true;
  }

// دالة مساعدة لتسهيل عرض الرسائل
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  Future<void> _signUpUser() async {
    String fullPhone = "+962${phoneController.text.trim()}";
    String name = nameController.text.trim();

    if (mounted) setState(() => _isLoading = true);

    try {
      var phoneDoc = await FirebaseFirestore.instance
          .collection('PHONE_INDEX')
          .doc(fullPhone)
          .get();

      if (phoneDoc.exists) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phone number already registered")),
          );
          setState(() => _isLoading = false);
        }
        return;
      }

      UserCredential user =
      await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: emailController.text.trim(),
        password: passwordController.text,
      );

      String uid = user.user!.uid;

      String collection = '';
      if (selectedRole == 'customer') collection = 'CUSTOMERS';
      if (selectedRole == 'provider') collection = 'FOOD_PROVIDERS';
      if (selectedRole == 'driver') collection = 'DRIVERS';

      String? logoUrl;
      if (selectedRole == 'provider') {
        logoUrl = await _uploadProviderImage(uid);
      }

      await FirebaseFirestore.instance.collection(collection).doc(uid).set({
        'uid': uid,
        'name': name,
        'email': emailController.text.trim(),
        'phone': fullPhone,
        'city': selectedCity,
        'role': selectedRole,
        'vehicleType': selectedVehicleType ?? "",
        'providerType': selectedProviderType ?? "",
        'createdAt': FieldValue.serverTimestamp(),
        'logoUrl': logoUrl ?? "",
        'VerificationStatus': 'new', // ✅ أضف هاد
      });

      await FirebaseFirestore.instance
          .collection('PHONE_INDEX')
          .doc(fullPhone)
          .set({'uid': uid});

      if (!mounted) return;

      nameController.clear();
      emailController.clear();
      phoneController.clear();
      passwordController.clear();
      confirmPasswordController.clear();

      if (selectedRole == 'customer') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const OnboardingAScreen()),
              (route) => false,
        );
      } else if (selectedRole == 'provider') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const ProviderVerificationScreen ()),
              (route) => false,
        );
      } else if (selectedRole == 'driver') {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const DriverVerificationScreen()),              (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      String message = 'An error occurred';
      if (e.code == 'email-already-in-use') message = 'Email already registered';
      if (e.code == 'weak-password') message = 'Password is too weak';
      if (e.code == 'invalid-email') message = 'Invalid email format';

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      }
    } catch (e) {
      debugPrint('SignUp error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Error: $e"),
            duration: const Duration(seconds: 15),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection:
      AppStrings.isArabic ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        backgroundColor: const Color(0xFFF5CB58),
        body: Stack(
          children: [
            const BackButtonPositioned(
              targetPage: LaunchWelcomeScreen(),
            ),
            Column(
              children: [
                const SizedBox(height: 70),
                Text(
                  AppStrings.signUp,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.brown,
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(25),
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
                          const SizedBox(height: 20),
                          Text(
                            AppStrings.createAccountDesc1,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.deepOrangeAccent,
                            ),
                          ),
                          const SizedBox(height: 30),

                          // Name
                          customInput(
                            child: TextField(
                              controller: nameController,
                              decoration: inputDecoration("Name"),
                            ),
                          ),

                          // Email
                          customInput(
                            child: TextField(
                              controller: emailController,
                              decoration: inputDecoration(AppStrings.email),
                            ),
                          ),

                          // Phone
                          customInput(
                            child: Row(
                              children: [
                                const Text(
                                  "+962 ",
                                  style: TextStyle(
                                    color: Colors.brown,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                  ),
                                ),
                                Expanded(
                                  child: TextField(
                                    controller: phoneController,
                                    keyboardType: TextInputType.phone,
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly,
                                    ],
                                    decoration: inputDecoration("7XXXXXXXX"),
                                    onChanged: (value) {
                                      String digits = value.replaceAll(
                                          RegExp(r'[^0-9]'), "");
                                      if (digits.length > 9) {
                                        digits = digits.substring(0, 9);
                                      }
                                      phoneController.value = TextEditingValue(
                                        text: digits,
                                        selection: TextSelection.collapsed(
                                            offset: digits.length),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // City
                          customInput(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedCity,
                                hint: Text(AppStrings.selectCity),
                                items: [
                                  "Amman",
                                  "Irbid",
                                  "Zarqa",
                                  "Aqaba",
                                  "Salt",
                                  "Mafraq",
                                  "Jerash",
                                  "Ajloun",
                                  "Karak",
                                  "Tafilah",
                                  "Ma'an"
                                ].map((e) {
                                  return DropdownMenuItem(
                                    value: e,
                                    child: Center(child: Text(e)),
                                  );
                                }).toList(),
                                onChanged: (v) =>
                                    setState(() => selectedCity = v),
                              ),
                            ),
                          ),

                          // Password
                          customInput(
                            child: TextField(
                              controller: passwordController,
                              obscureText: isPasswordHidden,
                              decoration:
                              inputDecoration(AppStrings.password).copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(isPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                  isPasswordHidden = !isPasswordHidden),
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 5),

                          // Confirm Password
                          customInput(
                            child: TextField(
                              controller: confirmPasswordController,
                              obscureText: isConfirmPasswordHidden,
                              decoration:
                              inputDecoration(AppStrings.confirmPassword)
                                  .copyWith(
                                suffixIcon: IconButton(
                                  icon: Icon(isConfirmPasswordHidden
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () => setState(() =>
                                  isConfirmPasswordHidden =
                                  !isConfirmPasswordHidden),
                                ),
                              ),
                            ),
                          ),

                          // Role
                          customInput(
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                isExpanded: true,
                                value: selectedRole,
                                hint: const Text("Select Role"),
                                items: const [
                                  DropdownMenuItem(
                                    value: "customer",
                                    child: Center(child: Text("Customer")),
                                  ),
                                  DropdownMenuItem(
                                    value: "provider",
                                    child: Center(child: Text("Provider")),
                                  ),
                                  DropdownMenuItem(
                                    value: "driver",
                                    child: Center(child: Text("Driver")),
                                  ),
                                ],
                                onChanged: (v) {
                                  setState(() {
                                    selectedRole = v;
                                    _restaurantImage = null;
                                    selectedProviderType = null;
                                    selectedVehicleType = null;
                                  });
                                },
                              ),
                            ),
                          ),

                          // Driver: Vehicle Type
                          if (selectedRole == "driver")
                            customInput(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedVehicleType,
                                  hint: const Text("Vehicle Type"),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "car",
                                        child: Center(child: Text("Car"))),
                                    DropdownMenuItem(
                                        value: "bike",
                                        child: Center(child: Text("Bike"))),
                                    DropdownMenuItem(
                                        value: "Scooter",
                                        child:
                                        Center(child: Text("Scooter"))),
                                    DropdownMenuItem(
                                        value: "Motorcycle",
                                        child:
                                        Center(child: Text("Motorcycle"))),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => selectedVehicleType = v),
                                ),
                              ),
                            ),

                          // Provider: Provider Type
                          if (selectedRole == "provider")
                            customInput(
                              child: DropdownButtonHideUnderline(
                                child: DropdownButton<String>(
                                  isExpanded: true,
                                  value: selectedProviderType,
                                  hint: const Text("Provider Type"),
                                  items: const [
                                    DropdownMenuItem(
                                        value: "meals",
                                        child: Center(child: Text("Meals"))),
                                    DropdownMenuItem(
                                        value: "fresh_produce",
                                        child: Center(
                                            child: Text("Fresh Produce"))),
                                    DropdownMenuItem(
                                        value: "bakery",
                                        child: Center(
                                            child: Text("Bakery Products"))),
                                    DropdownMenuItem(
                                        value: "store",
                                        child: Center(child: Text("Store"))),
                                  ],
                                  onChanged: (v) =>
                                      setState(() => selectedProviderType = v),
                                ),
                              ),
                            ),

                          // Provider: Upload Logo
                          if (selectedRole == "provider")
                            GestureDetector(
                              onTap: () async {
                                final img = await _picker.pickImage(
                                    source: ImageSource.gallery);
                                setState(() => _restaurantImage = img);
                              },
                              child: customInput(
                                child: Row(
                                  children: [
                                    const Icon(Icons.image,
                                        color: Colors.brown),
                                    const SizedBox(width: 10),
                                    Text(
                                      _restaurantImage == null
                                          ? "Upload Logo"
                                          : "✅ Image Selected",
                                      style: const TextStyle(
                                          color: Colors.brown),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                          const SizedBox(height: 20),

                          // Sign Up Button
                          SizedBox(
                            height: 50,
                            width: 200,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : () async {
                                if (!_validateBeforeOTP()) return;
                                setState(() => _isLoading = true);
                                await sendEmailOTP(
                                    emailController.text.trim());
                                if (mounted)
                                  setState(() => _isLoading = false);
                                if (!mounted) return;
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EmailOTPScreen(
                                      correctOTP: generatedOTP,
                                      onVerified: _signUpUser,
                                    ),
                                  ),
                                );
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _isLoading
                                    ? Colors.grey
                                    : Colors.deepOrangeAccent,
                              ),
                              child: _isLoading
                                  ? const CircularProgressIndicator(
                                  color: Colors.white)
                                  : const Text("Sign Up",
                                  style: TextStyle(color: Colors.white)),
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
      ),
    );
  }
}

class OTPScreen extends StatefulWidget {
  final String verificationId;
  final String phone;

  const OTPScreen({
    super.key,
    required this.verificationId,
    required this.phone,
  });

  @override
  State<OTPScreen> createState() => _OTPScreenState();
}

class _OTPScreenState extends State<OTPScreen> {
  final TextEditingController codeController = TextEditingController();

  Future<void> verifyOTP() async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: codeController.text.trim(),
      );
      await FirebaseAuth.instance.signInWithCredential(credential);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Phone Verified ✅")),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Invalid code ❌")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Enter OTP")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Text("Code sent to ${widget.phone}"),
            TextField(
              controller: codeController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(hintText: "Enter OTP"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: verifyOTP, child: const Text("Verify")),
          ],
        ),
      ),
    );
  }
}

// ✅ EmailOTPScreen
class EmailOTPScreen extends StatefulWidget {
  final String correctOTP;
  final VoidCallback onVerified;

  const EmailOTPScreen({
    super.key,
    required this.correctOTP,
    required this.onVerified,
  });

  @override
  State<EmailOTPScreen> createState() => _EmailOTPScreenState();
}

class _EmailOTPScreenState extends State<EmailOTPScreen> {
  final List<TextEditingController> _controllers =
  List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) c.dispose();
    for (var f in _focusNodes) f.dispose();
    super.dispose();
  }

  String get _enteredOTP => _controllers.map((c) => c.text).join();

  void verify() {
    if (_enteredOTP.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please enter the full code")),
      );
      return;
    }
    if (_enteredOTP == widget.correctOTP) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Email Verified ✅")),
      );
      widget.onVerified();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Wrong OTP ❌")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFFF5CB58),
      body: Stack(
        children: [
          Column(
            children: [
              const SizedBox(height: 70),
              const Text(
                "Verify Email",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 30),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(25),
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
                        const SizedBox(height: 30),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: const Color(0xFFF5CB58),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Icon(
                            Icons.mark_email_read_outlined,
                            size: 45,
                            color: Colors.brown,
                          ),
                        ),
                        const SizedBox(height: 20),
                        const Text(
                          "Check your email",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.deepOrangeAccent,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          "We sent a 6-digit code to your email",
                          textAlign: TextAlign.center,
                          style:
                          TextStyle(fontSize: 14, color: Colors.brown),
                        ),
                        const SizedBox(height: 40),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: List.generate(6, (i) {
                            return SizedBox(
                              width: 45,
                              height: 55,
                              child: Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF5CB58),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _controllers[i],
                                  focusNode: _focusNodes[i],
                                  textAlign: TextAlign.center,
                                  keyboardType: TextInputType.number,
                                  maxLength: 1,
                                  style: const TextStyle(
                                    fontSize: 22,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.brown,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    counterText: "",
                                  ),
                                  inputFormatters: [
                                    FilteringTextInputFormatter.digitsOnly,
                                  ],
                                  onChanged: (value) {
                                    if (value.isNotEmpty && i < 5) {
                                      _focusNodes[i + 1].requestFocus();
                                    } else if (value.isEmpty && i > 0) {
                                      _focusNodes[i - 1].requestFocus();
                                    }
                                  },
                                ),
                              ),
                            );
                          }),
                        ),
                        const SizedBox(height: 40),
                        SizedBox(
                          height: 50,
                          width: 200,
                          child: ElevatedButton(
                            onPressed: verify,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrangeAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Verify",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          Positioned(
            top: 40,
            left: 15,
            child: IconButton(
              icon: const Icon(Icons.arrow_back, color: Colors.deepOrange),
              onPressed: () {
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => const SignUpScreen()),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}