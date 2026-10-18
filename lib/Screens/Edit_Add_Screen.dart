import 'package:flutter/material.dart';
import 'HomeScreen.dart';

class AddEditProductScreen extends StatefulWidget {
  final Product? product; // null = add, not null = edit
  const AddEditProductScreen({super.key, this.product});

  @override
  State<AddEditProductScreen> createState() => _AddEditProductScreenState();
}

class _AddEditProductScreenState extends State<AddEditProductScreen> {
  final _formKey = GlobalKey<FormState>();

  late String code;
  late String name;
  late String category;
  late double price;
  late int quantity;
  late String status;
  late String image;

  final List<String> categories = const [
    'Beverages',
    'Groceries',
    'Bakery',
    'Dairy',
    'Household',
    'Personal Care',
    'Electronics',
    'Other',
  ];

  final List<String> statuses = const [
    'Available',
    'Low Stock',
    'Out of Stock',
  ];

  final List<String> images = const [
    'assets/images/bev_pic.png',
    'assets/images/groc_pic.png',
    'assets/images/bak_pic.png',
    'assets/images/dairy_pic.png',
    'assets/images/hh_pic.png',
    'assets/images/pcare_pic.png',
    'assets/images/elec_pic.png',
    'assets/images/rand_pic.png',
  ];

  bool get isEditing => widget.product != null;

  @override
  void initState() {
    super.initState();
    // Initialize variables with existing product data or defaults
    code = widget.product?.code ?? '';
    name = widget.product?.name ?? '';
    category = widget.product?.category ?? categories.first;
    price = widget.product?.price ?? 0;
    quantity = widget.product?.quantity ?? 0;
    status = widget.product?.status ?? statuses.first;
    image = widget.product?.image ?? images.last;
  }

  void save() {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      final result = Product(
        code: code,
        name: name,
        category: category,
        price: price,
        quantity: quantity,
        image: image,
        status: status,
      );
      Navigator.pop(context, result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isEditing ? 'Edit Product' : 'Add Product')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                initialValue: code,
                decoration: const InputDecoration(
                  labelText: 'Product Code',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Product Code';
                  }
                  return null;
                },
                onSaved: (v) => code = v!,
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: name,
                decoration: const InputDecoration(
                  labelText: 'Product Name',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a Product Name';
                  }
                  return null;
                },
                onSaved: (v) => name = v!,
              ),
              const SizedBox(height: 12),

              // FIXED CATEGORY DROPDOWN
              DropdownButtonFormField<String>(
                value: category, // Changed from initialValue to value
                decoration: const InputDecoration(
                  labelText: 'Category',
                  border: OutlineInputBorder(),
                ),
                items: categories
                    .map((c) => DropdownMenuItem(value: c, child: Text(c)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => category = v);
                },
                // No need for onSaved since we update state directly
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: isEditing ? price.toString() : '',
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                decoration: const InputDecoration(
                  labelText: 'Unit Price (R)',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a unit price';
                  }
                  final parsedPrice = double.tryParse(value.trim());
                  if (parsedPrice == null) {
                    return 'Price must be a number';
                  }
                  if (parsedPrice <= 0) {
                    return 'Price must be greater than 0';
                  }
                  return null;
                },
                onSaved: (v) => price = double.parse(v!.trim()),
              ),
              const SizedBox(height: 12),

              TextFormField(
                initialValue: isEditing ? quantity.toString() : '',
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Quantity in Stock',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a quantity';
                  }
                  final qty = int.tryParse(value.trim());
                  if (qty == null) {
                    return 'Quantity must be a whole number';
                  }
                  if (qty < 0) {
                    return 'Quantity cannot be negative';
                  }
                  return null;
                },
                onSaved: (v) => quantity = int.parse(v!.trim()),
              ),
              const SizedBox(height: 12),

              // FIXED STATUS DROPDOWN
              DropdownButtonFormField<String>(
                value: status, // Changed from initialValue to value
                decoration: const InputDecoration(
                  labelText: 'Status',
                  border: OutlineInputBorder(),
                ),
                items: statuses
                    .map((s) => DropdownMenuItem(value: s, child: Text(s)))
                    .toList(),
                onChanged: (v) {
                  if (v != null) setState(() => status = v);
                },
              ),
              const SizedBox(height: 16),

              // FIXED IMAGE PICKER
              const Text(
                'Product Image',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),

              // Replaced the squished GridView with a nice horizontal ListView
              SizedBox(
                height: 90, // Fixed height for the horizontal list
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: images.length,
                  itemBuilder: (context, index) {
                    final path = images[index];
                    final isSelected = image == path;

                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          image = path;
                        });
                      },
                      child: Container(
                        width: 80, // Width of each image item
                        margin: const EdgeInsets.only(right: 12),
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Colors.blue
                                : Colors.transparent,
                            width: 3,
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(
                            4.0,
                          ), // Padding inside border
                          child: CircleAvatar(
                            backgroundColor: Colors.grey.shade200,
                            backgroundImage: AssetImage(path),
                            // Add an error builder just in case the image is missing
                            onBackgroundImageError: (exception, stackTrace) {},
                            child: const SizedBox.shrink(),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 32),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: save,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
