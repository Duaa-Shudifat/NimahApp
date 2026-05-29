import 'package:flutter/material.dart';

class UsersPage extends StatefulWidget {
  const UsersPage({super.key});

  @override
  State<UsersPage> createState() => _UsersPageState();
}

class _UsersPageState extends State<UsersPage> {

  final List<Map<String, dynamic>> users = [
    {
      "name": "Ahmad Ali",
      "email": "ahmad@email.com",
      "phone": "0791234567",
      "location": "Irbid",
      "orders": "12",
      "cancelled": "2",
      "spent": "85 JD",
      "blocked": false,
    },
    {
      "name": "Sara Mohamed",
      "email": "sara@email.com",
      "phone": "0789876543",
      "location": "Amman",
      "orders": "8",
      "cancelled": "1",
      "spent": "50 JD",
      "blocked": false,
    },
    {
      "name": "Ali Ahmad",
      "email": "ali@email.com",
      "phone": "0775555555",
      "location": "Zarqa",
      "orders": "20",
      "cancelled": "3",
      "spent": "140 JD",
      "blocked": true,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5CB58),

      body: Column(
        children: [

          const SizedBox(height: 60),

          const Text(
            "Users Analytics",
            style: TextStyle(
              fontSize: 26,
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

              child: ListView(
                children: users.map((u) {
                  return _buildUser(u);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUser(Map<String, dynamic> u) {
    bool isBlocked = u["blocked"];

    return Container(
      margin: const EdgeInsets.only(bottom: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isBlocked ? Colors.grey.shade300 : const Color(0xFFF5CB58),
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [

              Text(
                u["name"],
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: Colors.brown,
                ),
              ),

              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(
                  color: isBlocked ? Colors.red : Colors.green,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  isBlocked ? "BLOCKED" : "ACTIVE",
                  style: const TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),

          const SizedBox(height: 5),

          Text(u["email"]),
          Text("📱 ${u["phone"]}"),
          Text("📍 ${u["location"]}"),

          const SizedBox(height: 10),

          Text("Orders: ${u["orders"]}"),
          Text("Cancelled: ${u["cancelled"]}"),
          Text("Spent: ${u["spent"]}", style: const TextStyle(color: Colors.green)),

          const SizedBox(height: 10),

          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    u["blocked"] = !u["blocked"];
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isBlocked ? Colors.green : Colors.orange,
                ),
                child: Text(
                  isBlocked ? "Unblock" : "Block",
                  style: const TextStyle(color: Colors.white),
                ),
              ),

              const SizedBox(width: 10),

              ElevatedButton(
                onPressed: () {
                  setState(() {
                    users.remove(u);
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                ),
                child: const Text(
                  "Delete",
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}