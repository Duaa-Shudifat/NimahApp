import 'package:flutter/material.dart';

class AddCardScreen extends StatefulWidget {
  const AddCardScreen({super.key});

  @override
  State<AddCardScreen> createState() => _AddCardScreenState();
}

class _AddCardScreenState extends State<AddCardScreen> {
  final nameController = TextEditingController();
  final numberController = TextEditingController();
  final expiryController = TextEditingController();
  final cvvController = TextEditingController();

  final _formKey = GlobalKey<FormState>();
  bool obscureCVV = true;

  @override
  void dispose() {
    nameController.dispose();
    numberController.dispose();
    expiryController.dispose();
    cvvController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                "Add Card",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
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

                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [

                        const Icon(Icons.credit_card,
                            size: 80,
                            color: Colors.deepOrange),

                        const SizedBox(height: 20),

                        TextFormField(
                          controller: nameController,
                          decoration: const InputDecoration(
                            labelText: "Card Holder Name",
                          ),
                          validator: (value) =>
                          value!.isEmpty ? "Required" : null,
                        ),

                        TextFormField(
                          controller: numberController,
                          keyboardType: TextInputType.number,
                          decoration: const InputDecoration(
                            labelText: "Card Number",
                          ),
                          validator: (value) =>
                          value!.length < 8 ? "Invalid number" : null,
                        ),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: expiryController,
                                decoration: const InputDecoration(
                                  labelText: "Expiry",
                                  hintText: "MM/YY",
                                ),
                                validator: (value) =>
                                value!.isEmpty ? "Required" : null,
                              ),
                            ),

                            const SizedBox(width: 10),

                            Expanded(
                              child: TextFormField(
                                controller: cvvController,
                                obscureText: obscureCVV,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: "CVV",
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      obscureCVV
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () {
                                      setState(() {
                                        obscureCVV = !obscureCVV;
                                      });
                                    },
                                  ),
                                ),
                                validator: (value) =>
                                value!.length < 3 ? "Invalid" : null,
                              ),
                            ),
                          ],
                        ),

                        const Spacer(),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                Navigator.pop(context, {
                                  "number": numberController.text,
                                  "name": nameController.text,
                                });
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding:
                              const EdgeInsets.symmetric(vertical: 14),
                            ),
                            child: const Text("Save Card", style: TextStyle(color: Colors.white)),                          ),
                        )
                      ],
                    ),
                  ),

                ),
              ),
              const SizedBox(height: 30), // ← هذا يرفع الزر من تحت

    ],
          ),
        ],
      ),
    );
  }
}