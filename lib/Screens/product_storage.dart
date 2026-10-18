import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartmartretailers/Screens/HomeScreen.dart';

class ProductStorage {
  static const _storageKey = 'smartmart_products';

  static Future<void> saveProducts(List<Product> products) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Convert the list of products into a JSON string
    final List<Map<String, dynamic>> jsonList = products.map((p) => {
      'code': p.code,
      'name': p.name,
      'category': p.category,
      'price': p.price,
      'quantity': p.quantity,
      'status': p.status,
      'image': p.image,
    }).toList();

    final String jsonString = jsonEncode(jsonList);
    
    await prefs.setString(_storageKey, jsonString);
    debugPrint('Successfully saved ${products.length} products to browser storage.');
  }

  static Future<List<Product>> loadProducts() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_storageKey);

    if (jsonString == null || jsonString.isEmpty) {
      debugPrint('No saved products found in browser storage.');
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      final products = jsonList.map((item) {
        return Product(
          code: item['code'] as String,
          name: item['name'] as String,
          category: item['category'] as String,
          price: (item['price'] as num).toDouble(),
          quantity: item['quantity'] as int,
          status: item['status'] as String,
          image: item['image'] as String,
        );
      }).toList();

      debugPrint('Loaded ${products.length} products from browser storage.');
      return products;
    } catch (e) {
      debugPrint('Error decoding saved products: $e');
      return [];
    }
  }
}