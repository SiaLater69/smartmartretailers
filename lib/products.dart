import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:smartmartretailers/Screens/HomeScreen.dart';
import 'package:smartmartretailers/category_images.dart';

class ProductStorage {
  static const _fileName = 'products.txt';

  static Future<File> _file() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/$_fileName');
  }

  static Future<File> saveProducts(List<Product> products) async {
    final file = await _file();
    final buffer = StringBuffer();

    for (final p in products) {
      buffer.writeln(
        '${p.code},${p.name},${p.category},'
        '${p.price.toStringAsFixed(2)},${p.quantity},${p.status}',
      );
    }

    await file.writeAsString(buffer.toString());
    return file;
  }

  static Future<List<Product>> loadProducts() async {
    final file = await _file();

    if (!await file.exists()) {
      await file.create(recursive: true);
      return [];
    }

    final contents = await file.readAsString();
    final lines = contents
        .split('\n')
        .map((l) => l.trim())
        .where((l) => l.isNotEmpty)
        .toList();

    final products = <Product>[];
    for (final line in lines) {
      final parts = line.split(',');
      if (parts.length < 6) continue;

      try {
        final code = parts[0].trim();
        final name = parts[1].trim();
        final category = parts[2].trim();
        final price = double.parse(parts[3].trim());
        final qty = int.parse(parts[4].trim());
        final status = parts[5].trim();

        products.add(
          Product(
            code: code,
            name: name,
            category: category,
            price: price,
            quantity: qty,
            status: status,
            image: imageForCategory(category),
          ),
        );
      } catch (_) {
        continue;
      }
    }

    return products;
  }
}
