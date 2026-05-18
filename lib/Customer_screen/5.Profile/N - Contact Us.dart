import 'package:flutter/material.dart';

class ContactUsScreen extends StatelessWidget {
  const ContactUsScreen({super.key});

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
                "Contact Us",
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.brown,
                ),
              ),
              const SizedBox(height: 30),
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
                      _item(
                        icon: Icons.headset_mic,
                        iconBgColor: const Color(0xFFFBE9E7),
                        iconColor: Colors.deepOrange,
                        title: "Customer Service",
                        subtitle: "+962 6 500 1234",
                      ),
                      _item(
                        icon: Icons.language,
                        iconBgColor: const Color(0xFFE3F2FD),
                        iconColor: const Color(0xFF1565C0),
                        title: "Website",
                        subtitle: "www.myapp.com",
                      ),
                      _item(
                        icon: Icons.chat,
                        iconBgColor: const Color(0xFFE8F5E9),
                        iconColor: const Color(0xFF2E7D32),
                        title: "WhatsApp",
                        subtitle: "+962 7 9123 4567",
                      ),
                      _item(
                        icon: Icons.facebook,
                        iconBgColor: const Color(0xFFE8EAF6),
                        iconColor: const Color(0xFF1A237E),
                        title: "Facebook",
                        subtitle: "@MyAppOfficial",
                      ),
                      _item(
                        icon: Icons.camera_alt,
                        iconBgColor: const Color(0xFFFCE4EC),
                        iconColor: const Color(0xFF880E4F),
                        title: "Instagram",
                        subtitle: "@myapp.jo",
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _item({
    required IconData icon,
    required Color iconBgColor,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return ListTile(
      leading: CircleAvatar(
        backgroundColor: iconBgColor,
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: Colors.grey),
      ),
      trailing: const Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
    );
  }
}