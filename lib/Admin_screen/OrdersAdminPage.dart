// import 'package:flutter/material.dart';
//
// class OrdersAdminPage extends StatefulWidget {
//   const OrdersAdminPage({super.key});
//
//   @override
//   State<OrdersAdminPage> createState() => _OrdersAdminPageState();
// }
//
// class _OrdersAdminPageState extends State<OrdersAdminPage> {
//   int selectedIndex = 0;
//
//   final List<Map<String, dynamic>> orders = [
//
//
//     {
//       "customer": {
//         "name": "Duaa",
//         "phone": "0790000000",
//       },
//       "driver": {
//         "name": "Ahmad Ali",
//         "phone": "0781111111",
//       },
//       "restaurant": "Pizza Hut",
//       "price": "8 JD",
//       "location": "Irbid - Downtown",
//       "time": "6:30 PM",
//       "status": "approved",
//     },
//
//
//     {
//       "customer": {
//         "name": "Omar",
//         "phone": "0792222222",
//       },
//       "driver": {
//         "name": "Mohammed Hassan",
//         "phone": "0773333333",
//       },
//       "restaurant": "Burger King",
//       "price": "5 JD",
//       "location": "Amman - Abdali",
//       "time": "5:10 PM",
//       "status": "cancelled",
//     },
//   ];
//
//   @override
//   Widget build(BuildContext context) {
//     final filteredOrders = orders.where((o) {
//       if (selectedIndex == 0) return o["status"] == "approved";
//       return o["status"] == "cancelled";
//     }).toList();
//
//     return Scaffold(
//       backgroundColor: const Color(0xFFF5CB58),
//       body: Column(
//         children: [
//
//           const SizedBox(height: 60),
//
//           const Text(
//             "Orders Dashboard",
//             style: TextStyle(
//               fontSize: 26,
//               fontWeight: FontWeight.bold,
//               color: Colors.brown,
//             ),
//           ),
//
//           const SizedBox(height: 20),
//
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//
//               GestureDetector(
//                 onTap: () => setState(() => selectedIndex = 0),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Approved",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: selectedIndex == 0
//                             ? Colors.green
//                             : Colors.brown,
//                       ),
//                     ),
//                     if (selectedIndex == 0)
//                       Container(
//                         height: 3,
//                         width: 80,
//                         color: Colors.green,
//                       ),
//                   ],
//                 ),
//               ),
//
//               const SizedBox(width: 40),
//
//               GestureDetector(
//                 onTap: () => setState(() => selectedIndex = 1),
//                 child: Column(
//                   children: [
//                     Text(
//                       "Cancelled",
//                       style: TextStyle(
//                         fontSize: 18,
//                         fontWeight: FontWeight.bold,
//                         color: selectedIndex == 1
//                             ? Colors.red
//                             : Colors.brown,
//                       ),
//                     ),
//                     if (selectedIndex == 1)
//                       Container(
//                         height: 3,
//                         width: 90,
//                         color: Colors.red,
//                       ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//
//           const SizedBox(height: 10),
//
//           Expanded(
//             child: Container(
//               padding: const EdgeInsets.all(20),
//               decoration: const BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.only(
//                   topLeft: Radius.circular(40),
//                   topRight: Radius.circular(40),
//                 ),
//               ),
//
//               child: ListView(
//                 children: filteredOrders.map((o) {
//                   return _buildOrder(
//                     o["customer"]["name"],
//                     o["customer"]["phone"],
//                     o["driver"]["name"],
//                     o["driver"]["phone"],
//                     o["restaurant"],
//                     o["price"],
//                     o["location"],
//                     o["time"],
//                     o["status"],
//                   );
//                 }).toList(),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildOrder(
//       String customerName,
//       String customerPhone,
//       String driverName,
//       String driverPhone,
//       String restaurant,
//       String price,
//       String location,
//       String time,
//       String status,
//       ) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 15),
//       padding: const EdgeInsets.all(15),
//       decoration: BoxDecoration(
//         color: const Color(0xFFF5CB58),
//         borderRadius: BorderRadius.circular(15),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//
//           Text(
//             "👤 Customer: $customerName",
//             style: const TextStyle(
//               fontWeight: FontWeight.bold,
//               color: Colors.brown,
//             ),
//           ),
//
//           Text("📱 Customer Phone: $customerPhone"),
//
//           const SizedBox(height: 8),
//
//           Text("🚚 Driver: $driverName"),
//           Text("📱 Driver Phone: $driverPhone"),
//
//           const SizedBox(height: 8),
//
//           Text("🍔 Restaurant: $restaurant"),
//           Text("💰 Price: $price"),
//           Text("📍 Location: $location"),
//           Text("⏰ Time: $time"),
//
//           const SizedBox(height: 12),
//
//           Align(
//             alignment: Alignment.centerRight,
//             child: Container(
//               padding: const EdgeInsets.symmetric(
//                 horizontal: 12,
//                 vertical: 6,
//               ),
//               decoration: BoxDecoration(
//                 color: status == "approved"
//                     ? Colors.green
//                     : Colors.red,
//                 borderRadius: BorderRadius.circular(10),
//               ),
//               child: Text(
//                 status.toUpperCase(),
//                 style: const TextStyle(color: Colors.white),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }