import 'dart:convert';

import 'package:http/http.dart' as http;

class ProductInfo {
  ProductInfo({
    required this.name,
    required this.ingredients,
    required this.allergens,
    required this.labels,
    required this.imageUrl,
  });

  final String name;
  final String ingredients;
  final String allergens;
  final String labels;
  final String? imageUrl;

  factory ProductInfo.fromOpenFoodFacts(Map<String, dynamic> json) {
    final product = json['product'] as Map<String, dynamic>? ?? {};
    return ProductInfo(
      name: (product['product_name'] as String?)?.trim() ?? 'Unknown product',
      ingredients: (product['ingredients_text'] as String?)?.trim() ?? 'No ingredients listed',
      allergens: (product['allergens'] as String?)?.replaceAll('en:', '').trim() ?? 'No allergens listed',
      labels: (product['labels'] as String?)?.trim() ?? 'No labels listed',
      imageUrl: product['image_front_url'] as String?,
    );
  }
}

class ProductApi {
  static const _baseUrl = 'https://world.openfoodfacts.org/api/v2/product';

  Future<ProductInfo?> fetchProduct(String barcode) async {
    final response = await http.get(Uri.parse('$_baseUrl/$barcode.json'));
    if (response.statusCode != 200) {
      throw Exception('Failed to fetch product');
    }
    final data = jsonDecode(response.body) as Map<String, dynamic>;
    if (data['status'] != 1) {
      return null;
    }
    return ProductInfo.fromOpenFoodFacts(data);
  }
}
