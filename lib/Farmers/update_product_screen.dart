import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_styled_toast/flutter_styled_toast.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditProductScreen extends StatefulWidget {
  final DocumentSnapshot product;

  const EditProductScreen({Key? key, required this.product}) : super(key: key);

  @override
  _EditProductScreenState createState() => _EditProductScreenState();
}

class _EditProductScreenState extends State<EditProductScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _priceController;
  late TextEditingController _desc;
  late TextEditingController _category;
  File? _image;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.product["name"]);
    _priceController = TextEditingController(text: widget.product["price"].toString());
    _desc = TextEditingController(text: widget.product['description']);
    _category = TextEditingController(text: widget.product['category']);
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  void _updateProduct() {
    if (_formKey.currentState!.validate()) {
      FirebaseFirestore.instance.collection('products').doc(widget.product.id).update({
        'name': _nameController.text,
        'price': double.parse(_priceController.text),
        'description' : _desc.text,
        'category' : _category.text,
        // 'imageUrl': Upload logic here (if using Firebase Storage)
      });
      Navigator.pop(context);
    }
  }

  void _deleteProduct() {
    FirebaseFirestore.instance.collection('products').doc(widget.product.id).delete();
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        title: Text("Edit Product"),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () {}, // Show help dialog
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Product Image
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 150,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(15),
                    color: Colors.grey[200],
                    image: _image == null && widget.product["imageUrl"] != "image_url_placeholder"
                        ? DecorationImage(
                            image: NetworkImage(widget.product["imageUrl"]),
                            fit: BoxFit.cover,
                          )
                        : null,
                  ),
                  child: _image == null
                      ? Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                      : Image.file(_image!, fit: BoxFit.cover),
                ),
              ),
              SizedBox(height: 20),

              // Name Field
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Product Name"),
                validator: (value) => value!.isEmpty ? "Enter a name" : null,
              ),
              SizedBox(height: 10),

              // Price Field
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(labelText: "Price"),
                keyboardType: TextInputType.number,
                validator: (value) => value!.isEmpty ? "Enter a price" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _desc,
                decoration: InputDecoration(labelText: "Description"),
                keyboardType: TextInputType.text,
                validator: (value) => value!.isEmpty ? "Enter Description" : null,
              ),
              SizedBox(height: 20),

              TextFormField(
                controller: _category,
                decoration: InputDecoration(labelText: "Category"),
                keyboardType: TextInputType.text,
                validator: (value) => value!.isEmpty ? "Change Category" : null,
              ),
              SizedBox(height: 20),

              // Update Button
              ElevatedButton.icon(
                icon: Icon(Icons.save),
                label: Text("Update Product"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                  textStyle: TextStyle(fontSize: 16),
                ),

                onPressed: widget.product["isSold"] ? 
                () {
                  showToast(
        "Cannot Edit already Sold",
        context: context,
        animation: StyledToastAnimation.scale,
        position: StyledToastPosition.bottom,
        duration: const Duration(seconds: 2),
        backgroundColor: Colors.red,
      );
                } 
                : 
                () {
                  _updateProduct();
          },
              ),

              SizedBox(height: 10),

              // Delete Button
              TextButton.icon(
                icon: Icon(Icons.delete, color: Colors.red),
                label: Text("Delete Product", style: TextStyle(color: Colors.red)),
                onPressed: _deleteProduct,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
