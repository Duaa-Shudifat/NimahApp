class CartItemModel {
  String title;
  double price;
  String img;
  int qty;
  int maxQty;

  CartItemModel({
    required this.title,
    required this.price,
    required this.img,
    required this.qty,
    this.maxQty = 99,
  });
}

class CartData {
  static List<CartItemModel> cartItems = [];
  static String currentRestaurant = "";
  static String currentRestaurantId = "";
  static String currentRestaurantImage = "";
}