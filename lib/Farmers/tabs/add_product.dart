import 'dart:typed_data';

import 'package:eva_icons_flutter/eva_icons_flutter.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:kisaansetu/Farmers/user_products_screen.dart';
import 'dart:io';

import 'package:kisaansetu/Services/product_service.dart';
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
       showToast(
        "Please fill all the field to proceed",
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.top,
        duration: const Duration(seconds: 3),
        backgroundColor: Colors.red,
      );
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
      imageUrl: (url != 'null')? url : "image_url_placeholder",
      category: _categoryController.text,
    );

     showToast(
        "Product Added Sucessfully!",
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.top,
        duration: const Duration(seconds: 10),
        backgroundColor: Colors.red,
      );

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => UserProductsScreen())
      );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Column(
          children: [
            _buildHeader(),
            Expanded(child: _buildAdd()),

          ],
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
  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.green[700],
        borderRadius: const BorderRadius.only(bottomLeft: Radius.circular(20), bottomRight: Radius.circular(20)),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10, spreadRadius: 2),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 40), // Space for status bar
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Add a Product",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.white),
              ),
              Icon(EvaIcons.folderAdd, size: 30, color: Colors.white),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            "Enter a detailed descriptiona and your contact information",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
        ],
      ),
    );
  }
  Widget _buildAdd() {
return SingleChildScrollView(
  child: Column(
    children: [
      Padding(
        padding: const EdgeInsets.all(16.0),
        // child: ClipRRect(
        //   borderRadius: BorderRadius.circular(40),
        //   child: Image.asset('assets/images/img11.png'),
        // ),
      ),
      Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(topLeft: Radius.circular(60), topRight: Radius.circular(60)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: GestureDetector(
                                onTap: () async{
                                   Uint8List im = await pickImage();
                setState(() {
                  _selectedImage = im;
                });
                                },
                                child: Container(
                                  width: double.infinity,
                                  height: 120,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(15),
                                    border: Border.all(color: Colors.black, width: 2),
                                    boxShadow: [
                                      BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 5,
                offset: const Offset(0, 3),
                                      ),
                                    ],
                                  ),
                                  child: _selectedImage == null
                                      ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(EvaIcons.cloudUploadOutline, size: 40, color: Colors.grey),
                    const SizedBox(height: 5),
                    Text("Upload Image", style: TextStyle(color: Colors.grey[700])),
                  ],
                )
                                      : ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.memory(_selectedImage!, fit: BoxFit.cover),
                ),
                                ),
                              ),
              ),
  
              SizedBox(height: 15,),
  
  
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  prefixIcon: Icon(EvaIcons.shoppingBagOutline),
                  hintText: "Enter Product Name",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(EvaIcons.editOutline),
                  hintText: "Description",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                keyboardType: TextInputType.numberWithOptions(),
                controller: _priceController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(EvaIcons.pricetagsOutline),
                  hintText: "Price",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _categoryController,
                decoration: InputDecoration(
                  prefixIcon: const Icon(EvaIcons.gridOutline),
                  hintText: "Category",
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(40)),
                ),
              ),
              const SizedBox(height: 20),
  
              SizedBox(
    width: double.infinity,
    child: ElevatedButton(
      onPressed: _uploadProduct,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16), // Increased padding for better touch feel
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(25), // More rounded corners for a modern look
        ),
        elevation: 6, // Adds depth to the button
        shadowColor: Colors.green.withOpacity(0.3), // Soft shadow
        backgroundColor: Colors.green, // Primary green color
      ),
      child: const Text(
        "Submit Product",
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold, // Bold for better visibility
          color: Colors.white, // White text for contrast
          letterSpacing: 1.1, // Slight spacing for elegance
        ),
      ),
    ),
  ),
  
  
             
  
             
              
            ],
          ),
        ),
      ),
    ],
  ),
);
}
}
