import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class SellProductPage extends StatefulWidget {
  @override
  _SellProductPageState createState() => _SellProductPageState();
}

class _SellProductPageState extends State<SellProductPage> {
  String selectedCategory = 'Electronics';
  String selectedCondition = 'New';
  final _formKey = GlobalKey<FormState>();
  bool isUploading = false;
  
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _priceController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _contactController = TextEditingController();

  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;

  final String cloudName = "dvlwy2gr2";
  final String uploadPreset = "Krishnapradeep";

  // Image picker and upload methods remain the same
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final imageData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageData;
      });
    }
  }

  Future<String?> _uploadImageToCloudinary() async {
    if (_imageData == null) return null;

    try {
      final uri = Uri.parse("https://api.cloudinary.com/v1_1/$cloudName/image/upload");
      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            "file",
            _imageData!,
            filename: "image.jpg",
          ),
        );

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);
        return jsonResponse["secure_url"];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Image upload failed. Try again.")),
        );
        return null;
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error uploading image: $e")),
      );
      return null;
    }
  }

  Future<void> _sellProduct() async {
    if (!_formKey.currentState!.validate() || _imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_imageData == null ? 'Please select an image' : 'Please fill all required fields')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      final imageUrl = await _uploadImageToCloudinary();

      if (imageUrl == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      await FirebaseFirestore.instance.collection('sell').add({
        'productName': _productNameController.text,
        'description': _descriptionController.text,
        'category': selectedCategory,
        'condition': selectedCondition,
        'price': _priceController.text,
        'location': _locationController.text,
        'contactInfo': _contactController.text,
        'imageUrl': imageUrl,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Product listed for sale successfully!'),
          backgroundColor: Colors.green,
        ),
      );

      // Clear the form
      _productNameController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _locationController.clear();
      _contactController.clear();
      setState(() {
        selectedCategory = 'Electronics';
        selectedCondition = 'New';
        _imageData = null;
      });
    } catch (e) {
      print("Error listing product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error listing product: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      maxLines: maxLines,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
    );
  }

  Widget buildDropdownField({
    required String value,
    required String label,
    required List<String> items,
    required void Function(String?) onChanged,
    required IconData icon,
  }) {
    return DropdownButtonFormField<String>(
      value: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.grey[600]),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: Colors.red),
        ),
        filled: true,
        fillColor: Colors.white,
        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      items: items.map((item) => DropdownMenuItem(
        value: item,
        child: Text(item),
      )).toList(),
      onChanged: onChanged,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Container(
        decoration: BoxDecoration(
          color: Colors.grey[50],
        ),
        child: Form(
          key: _formKey,
          child: ListView(
            padding: EdgeInsets.all(16.0),
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'SELL A PRODUCT',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      letterSpacing: 1.2,
                    ),
                  ),
                  SizedBox(height: 8),
                  Container(
                    width: 400,
                    height: 4,
                    decoration: BoxDecoration(
                      color: Colors.red,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 24),
              
              buildTextField(
                controller: _productNameController,
                label: 'Product Name',
                icon: Icons.shopping_bag,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a product name' : null,
              ),
              SizedBox(height: 16),

              buildTextField(
                controller: _descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
              ),
              SizedBox(height: 16),

              buildDropdownField(
                value: selectedCategory,
                label: 'Category',
                items: ['Electronics', 'Study Materials', 'Books', 'Stationary'],
                onChanged: (value) => setState(() => selectedCategory = value!),
                icon: Icons.category,
              ),
              SizedBox(height: 16),

              buildDropdownField(
                value: selectedCondition,
                label: 'Condition',
                items: ['New', 'Used', 'Like New'],
                onChanged: (value) => setState(() => selectedCondition = value!),
                icon: Icons.star_border,
              ),
              SizedBox(height: 16),

              buildTextField(
                controller: _priceController,
                label: 'Price',
                icon: Icons.attach_money,
                keyboardType: TextInputType.number,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a price' : null,
              ),
              SizedBox(height: 16),

              buildTextField(
                controller: _locationController,
                label: 'Location',
                icon: Icons.location_on,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
              ),
              SizedBox(height: 16),

              buildTextField(
                controller: _contactController,
                label: 'Contact Information',
                icon: Icons.phone,
                validator: (value) => value?.isEmpty ?? true ? 'Please enter contact information' : null,
              ),
              SizedBox(height: 24),

              Container(
                width: double.infinity,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: Icon(Icons.upload_file, color: Colors.white),
                      label: Text(
                        "Upload Image",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    if (_imageData != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Row(
                          children: [
                            Icon(Icons.check_circle, color: Colors.green, size: 20),
                            SizedBox(width: 8),
                            Text(
                              "Image selected",
                              style: TextStyle(
                                color: Colors.green,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              SizedBox(height: 24),

              Container(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: isUploading ? null : _sellProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isUploading ? 'Uploading...' : 'List Product for Sale',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}