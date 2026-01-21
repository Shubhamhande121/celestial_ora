class Product {
  final String id;
  final String name;
  final String catname;
  final String productimage;

  Product({
    required this.id,
    required this.name,
    required this.catname,
    required this.productimage,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      catname: json['catname'] ?? '',
      productimage: json['productimage'] ?? '',
    );
  }
}
