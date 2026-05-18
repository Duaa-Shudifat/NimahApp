class OrderModel {
  String image;
  String title;
  String details;
  String status;
  String cancelReason;

  OrderModel({
    required this.image,
    required this.title,
    required this.details,
    this.status = "Active",
    this.cancelReason = "",
  });
}

class OrdersData {
  static List<OrderModel> orders = [];
}