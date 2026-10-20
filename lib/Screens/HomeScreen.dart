import 'package:flutter/material.dart';
import 'package:smartmartretailers/Screens/Edit_Add_Screen.dart';
import 'package:smartmartretailers/Screens/ProductDetailsScreen.dart';
import 'package:smartmartretailers/Screens/product_storage.dart';
import 'package:smartmartretailers/category_images.dart';
import 'package:file_saver/file_saver.dart'; // Added for export
import 'package:file_picker/file_picker.dart';
import 'dart:convert'; // Added for encoding text

class Product {
  final String code;
  final String name;
  final String category;
  final double price;
  final int quantity;
  final String status;
  final String image;

  Product({
    required this.code,
    required this.name,
    required this.category,
    required this.price,
    required this.quantity,
    required this.status,
    required this.image,
  });
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<Product> products = [
    Product(
      code: 'PRD001',
      name: 'Coca-Cola 2L',
      category: 'Beverages',
      price: 24.99,
      quantity: 35,
      status: 'Available',
      image: 'assets/images/bev_pic.png',
    ),
    Product(
      code: 'PRD002',
      name: 'White Bread',
      category: 'Bakery',
      price: 18.50,
      quantity: 12,
      status: 'Available',
      image: 'assets/images/bak_pic.png',
    ),
    Product(
      code: 'PRD003',
      name: 'Fresh Milk 2L',
      category: 'Dairy',
      price: 32.99,
      quantity: 4,
      status: 'Low Stock',
      image: 'assets/images/dairy_pic.png',
    ),
    Product(
      code: 'PRD004',
      name: 'Washing Powder 2kg',
      category: 'Household',
      price: 79.99,
      quantity: 0,
      status: 'Out of Stock',
      image: 'assets/images/hh_pic.png',
    ),
    Product(
      code: 'PRD005',
      name: 'USB Keyboard',
      category: 'Electronics',
      price: 199.99,
      quantity: 8,
      status: 'Available',
      image: 'assets/images/elec_pic.png',
    ),
    Product(
      code: 'PRD006',
      name: 'USB Mouse',
      category: 'Electronics',
      price: 299.00,
      quantity: 2,
      status: 'Available',
      image: 'assets/images/elec_pic.png',
    ),
  ];

  @override
  void initState() {
    super.initState();
    _loadFromFile();
  }

  Future<void> _loadFromFile() async {
    final loaded = await ProductStorage.loadProducts();
    if (!mounted) return;

    if (loaded.isNotEmpty) {
      setState(() => products = loaded);
    } else {
      await ProductStorage.saveProducts(products);
    }
  }

  Future<void> _persist() async {
    await ProductStorage.saveProducts(products);
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'Available':
        return Colors.green;
      case 'Low Stock':
        return Colors.orange;
      case 'Out of Stock':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  Future<void> _saveToFile() async {
    try {
      await ProductStorage.saveProducts(products);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products saved to app storage!')),
      );
    } catch (e, stack) {
      debugPrint('Save failed: $e');
      debugPrint('$stack');
    }
  }

  Future<void> _importProductsFromTxt() async {
    try {
      // 1. New API: pickFiles returns a List<PlatformFile> directly
      final files = await FilePicker.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['txt'],
      );

      // Check if the user canceled or didn't pick a file
      if (files.isEmpty) {
        return;
      }

      // 2. Get the first file and read its bytes directly
      final file = files.first;
      final bytes = await file.readAsBytes();
      final contents = utf8.decode(bytes);

      final lines = contents
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();

      final importedProducts = <Product>[];

      // 3. Parse the text file
      for (final line in lines) {
        if (line.startsWith('Code,Name')) continue;

        final parts = line.split(',');
        if (parts.length < 7) continue;

        try {
          importedProducts.add(
            Product(
              code: parts[0].trim(),
              name: parts[1].trim(),
              category: parts[2].trim(),
              price: double.parse(parts[3].trim()),
              quantity: int.parse(parts[4].trim()),
              status: parts[5].trim(),
              image: parts[6].trim(),
            ),
          );
        } catch (e) {
          debugPrint('Error parsing line: $line -> $e');
        }
      }

      // 4. Update state and persist
      if (importedProducts.isNotEmpty) {
        setState(() => products = importedProducts);
        await _persist();

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Successfully imported ${importedProducts.length} products!',
              ),
            ),
          );
        }
      } else {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No valid products found in the file.'),
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Import failed: $e');
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Failed to import file.')));
      }
    }
  }

  // NEW HELPER METHOD TO EXPORT TO TXT FILE
  Future<void> _exportProductsAsTxt() async {
    final buffer = StringBuffer();
    buffer.writeln('Code,Name,Category,Price,Quantity,Status,Image');

    for (final p in products) {
      buffer.writeln(
        '${p.code},${p.name},${p.category},'
        '${p.price.toStringAsFixed(2)},${p.quantity},${p.status},${p.image}',
      );
    }

    final textContent = buffer.toString();

    await FileSaver.instance.saveFile(
      name: 'smartmart_products',
      bytes: utf8.encode(textContent),
      fileExtension: 'txt',
      mimeType: MimeType.text,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Products exported to file!')),
      );
    }
  }

  Future<void> _confirmDelete(Product product) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Product'),
        content: Text('Delete "${product.name}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      setState(() => products.removeWhere((p) => p.code == product.code));
      await _persist();
      if (!mounted) return;
      Navigator.pop(context, 'deleted');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SmartMart Inventory'),
        backgroundColor: Theme.of(context).colorScheme.primaryContainer,
        elevation: 2,
        actions: [
          // 1. IMPORT BUTTON (Upload icon)
          IconButton(
            icon: const Icon(Icons.file_upload),
            tooltip: 'Import from .txt file',
            onPressed: _importProductsFromTxt,
          ),

          // 2. SAVE TO APP STORAGE BUTTON (Save icon)
          IconButton(
            icon: const Icon(Icons.save_alt),
            tooltip: 'Save to app storage',
            onPressed: _saveToFile,
          ),

          // 3. EXPORT TO TXT BUTTON (Download icon)
          IconButton(
            icon: const Icon(Icons.download),
            tooltip: 'Export to .txt file',
            onPressed: _exportProductsAsTxt,
          ),
        ],
      ),
      body: products.isEmpty
          ? const Center(child: Text('No products yet'))
          : SafeArea(
              child: ListView.builder(
                padding: const EdgeInsets.all(8),
                itemCount: products.length,
                itemBuilder: (context, index) {
                  final product = products[index];
                  final statusColor = _getStatusColor(product.status);

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 6,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),

                      leading: CircleAvatar(
                        radius: 28,
                        backgroundColor: Colors.grey.shade200,
                        child: ClipOval(
                          child: Image.asset(
                            product.image.isNotEmpty
                                ? product.image
                                : imageForCategory(product.category),
                            width: 56,
                            height: 56,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.inventory_2, size: 24),
                          ),
                        ),
                      ),

                      title: Text(
                        product.name,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Code: ${product.code}',
                              style: TextStyle(
                                color: Colors.grey.shade700,
                                fontSize: 13,
                              ),
                            ),
                            Text(
                              'R${product.price.toStringAsFixed(2)}',
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      ),

                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: statusColor, width: 1.2),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              '${product.quantity}',
                              style: TextStyle(
                                color: statusColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              product.status,
                              style: TextStyle(
                                color: statusColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),

                      onTap: () async {
                        final updated = await Navigator.push<Product>(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ProductDetailsScreen(
                              product: product,
                              onDelete: () {
                                setState(
                                  () => products.removeWhere(
                                    (p) => p.code == product.code,
                                  ),
                                );
                              },
                            ),
                          ),
                        );

                        if (updated != null) {
                          setState(() {
                            final productIndex = products.indexWhere(
                              (p) => p.code == updated.code,
                            );
                            if (productIndex != -1) {
                              products[productIndex] = updated;
                            } else {
                              products[index] = updated;
                            }
                          });
                          await _persist();
                        }
                      },
                      onLongPress: () => _confirmDelete(product),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () async {
          final newProduct = await Navigator.push<Product>(
            context,
            MaterialPageRoute(builder: (context) => AddEditProductScreen()),
          );
          if (newProduct != null) {
            setState(() => products.add(newProduct));
            await _persist();
          }
        },
        icon: const Icon(Icons.add),
        label: const Text('Add'),
      ),
    );
  }
}
