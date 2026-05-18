import 'package:flutter/material.dart';
import 'M - Add Card.dart';

class PaymentMethodsScreen extends StatefulWidget {
  const PaymentMethodsScreen({super.key});

  @override
  State<PaymentMethodsScreen> createState() => _PaymentMethodsScreenState();
}

class _PaymentMethodsScreenState extends State<PaymentMethodsScreen> {
  List<Map<String, String>> cards = [
    {"number": "**** **** **** 43", "name": "John Smith"},
  ];

  int? selectedIndex;

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
                "Payment Methods",
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
                  child: Column(
                    children: [
                      Expanded(
                        child: ListView.builder(
                          itemCount: cards.length,
                          itemBuilder: (context, index) {
                            return _cardItem(index);
                          },
                        ),
                      ),

                      // ✅ زر Confirm — يظهر بس لو اختار كارد
                      if (selectedIndex != null) ...[
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.pop(
                                context,
                                cards[selectedIndex!]["number"],
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepOrange,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(15),
                              ),
                            ),
                            child: const Text(
                              "Confirm Payment",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                      ],

                      // ✅ زر Add Card
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => const AddCardScreen(),
                              ),
                            );
                            if (result != null) {
                              setState(() {
                                cards.add(Map<String, String>.from(result));
                              });
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amberAccent,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15),
                            ),
                          ),
                          child: const Text(
                            "Add Card",
                            style: TextStyle(
                              color: Colors.brown,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 35), // ← هذا يرفع الزر من تحت

            ],
          ),
        ],
      ),
    );
  }

  Widget _cardItem(int index) {
    final isSelected = selectedIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() {
          selectedIndex = isSelected ? null : index;
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: isSelected
              ? Colors.deepOrange.withOpacity(0.1)
              : Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: isSelected
              ? Border.all(color: Colors.deepOrange, width: 2)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.grey.shade300,
              blurRadius: 5,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(Icons.credit_card,
                color: isSelected ? Colors.deepOrange : Colors.grey),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(cards[index]["number"]!),
                  Text(
                    cards[index]["name"]!,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),

            Icon(
              isSelected
                  ? Icons.radio_button_checked
                  : Icons.radio_button_unchecked,
              color: isSelected ? Colors.grey : Colors.deepOrange,
            ),
          ],
        ),
      ),

    );

  }
}