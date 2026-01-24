class Product {
  final String id;
  final String name;
  final String catname;
  final String productimage;
  final List<Variant>? variant; 

  Product({
    required this.id,
    required this.name,
    required this.catname,
    required this.productimage,
    this.variant,
  });

  factory Product.fromJson(Map<String, dynamic> json) {
    // Debug logging
    print("🔄 Parsing product JSON: ${json.keys.toList()}");
    
    // Try to get the ID from different possible fields
    final id = _getStringValue(json, ['id', 'productid']);
    final name = _getStringValue(json, ['name', 'productname']);
    final catname = _getStringValue(json, ['catname']);
    final productimage = _getStringValue(json, ['productimage', 'image']);
    
    // Parse variant if it exists
    List<Variant>? variants;
    if (json['variant'] != null && json['variant'] is List) {
      try {
        variants = (json['variant'] as List)
            .map((v) => Variant.fromJson(v))
            .toList();
        print("✅ Parsed ${variants.length} variants for product: $name");
      } catch (e) {
        print("❌ Error parsing variants: $e");
        print("❌ Variant data: ${json['variant']}");
      }
    } else {
      print("ℹ️ No variant data for product: $name");
    }
    
    print("🆔 Product parsed - ID: $id, Name: $name, Variants: ${variants?.length ?? 0}");
    
    return Product(
      id: id,
      name: name,
      catname: catname,
      productimage: productimage,
      variant: variants,
    );
  }
  
  // Helper method to get string value from multiple possible keys
  static String _getStringValue(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json[key] != null) {
        final value = json[key].toString();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }
  
  // Helper to get display price
  String get displayPrice {
    if (variant != null && variant!.isNotEmpty) {
      final v = variant!.first;
      return v.specialPrice?.isNotEmpty == true 
          ? v.specialPrice! 
          : v.price;
    }
    return '0';
  }
}

class Variant {
  final String id;
  final String productId;
  final String variantText;
  final String price;
  final String? specialPrice;
  
  Variant({
    required this.id,
    required this.productId,
    required this.variantText,
    required this.price,
    this.specialPrice,
  });
  
  factory Variant.fromJson(Map<String, dynamic> json) {
    print("🔄 Parsing variant JSON: ${json.keys.toList()}");
    
    return Variant(
      id: _getStringValue(json, ['id']),
      productId: _getStringValue(json, ['product_id']),
      variantText: _getStringValue(json, ['variant_text']),
      price: _getStringValue(json, ['price']),
      specialPrice: json['special_price']?.toString(),
    );
  }
  
  static String _getStringValue(Map<String, dynamic> json, List<String> keys) {
    for (var key in keys) {
      if (json[key] != null) {
        final value = json[key].toString();
        if (value.isNotEmpty) {
          return value;
        }
      }
    }
    return '';
  }
}