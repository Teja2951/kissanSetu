import 'dart:typed_data';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'package:kisaansetu/farmer/products/product_service.dart';
import 'package:kisaansetu/helpers.dart';
import 'package:kisaansetu/storage_methods.dart';

class AddProductScreen extends StatefulWidget {
  const AddProductScreen({Key? key}) : super(key: key);

  @override
  _AddProductScreenState createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _categoryController = TextEditingController();
  
  Uint8List? _selectedImage; // Store picked image
  String url = 'null';

  Future<void> _uploadProduct() async {
    if (_nameController.text.isEmpty || _priceController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }


    if(_selectedImage != null){
      url = await StorageMethods().getUploadedImage(_selectedImage!);
      print(url);
    }

    await ProductService().addProduct(
      farmerId: FirebaseAuth.instance.currentUser!.uid,
      name: _nameController.text,
      price: double.parse(_priceController.text),
      description: _descriptionController.text,
      imageUrl: (url != 'null')? url : "EmptyBhai",
      category: _categoryController.text,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA), // Soft background color
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Custom App Bar
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: const BorderRadius.only(
                    bottomLeft: Radius.circular(25),
                    bottomRight: Radius.circular(25),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      "Upload Product",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                    // Help Icon with Circular Button
                    GestureDetector(
                      onTap: () {
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Need Help?"),
                            content: const Text("Fill in product details and press Submit."),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.of(context).pop(),
                                child: const Text("OK"),
                              ),
                            ],
                          ),
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: Colors.blueAccent,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.help_outline, color: Colors.white, size: 24),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              
              // Image Picker Section
              GestureDetector(
                onTap: () async{
                   Uint8List im = await pickImage();
                        setState(() {
                          _selectedImage = im;
                        });
                },
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[200],
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 5,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: _selectedImage == null
                      ? const Icon(Icons.upload, size: 50, color: Colors.grey)
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(15),
                          child: Image.memory(_selectedImage!),
                        ),
                ),
              ),
              
              const SizedBox(height: 20),

              // Form Section
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Card(
                  elevation: 4,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        // Product Name
                        _buildTextField(_nameController, "Product Name", Icons.label),
                        const SizedBox(height: 16),
                        
                        // Product Description
                        _buildTextField(_descriptionController, "Description", Icons.description, maxLines: 3),
                        const SizedBox(height: 16),
                        
                        // Price Field
                        _buildTextField(_priceController, "Price", Icons.attach_money, isNumber: true),
                        const SizedBox(height: 16),
                        
                        // Category Field
                        _buildTextField(_categoryController, "Category", Icons.category),
                        const SizedBox(height: 24),
                        
                        // Submit Button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _uploadProduct,
                            style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                            child: const Text(
                              "Submit Product",
                              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool isNumber = false, int maxLines = 1}) {
    return TextField(
      controller: controller,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      maxLines: maxLines,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
