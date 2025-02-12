import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => DonateProductPage(),
      },
    );
  }
}

class DonateProductPage extends StatefulWidget {
  @override
  _DonateProductPageState createState() => _DonateProductPageState();
}

class _DonateProductPageState extends State<DonateProductPage> {
  final TextEditingController productNameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController contactInfoController = TextEditingController();
  
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  bool isUploading = false;

  String selectedCategory = 'Electronics';
  String selectedCondition = 'New';

  final String cloudName = "dvlwy2gr2"; // Replace with your Cloudinary cloud name
  final String uploadPreset = "Krishnapradeep"; // Replace with your unsigned preset name

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

  void _donateProduct() async {
    if (productNameController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        locationController.text.isEmpty ||
        contactInfoController.text.isEmpty ||
        _imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image.')),
      );
      return;
    }

    setState(() {
      isUploading = true;
    });

    try {
      // Upload image to Cloudinary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading image...')),
      );
      final imageUrl = await _uploadImageToCloudinary();

      if (imageUrl == null) {
        setState(() {
          isUploading = false;
        });
        return;
      }

      final donationData = {
        'productName': productNameController.text,
        'description': descriptionController.text,
        'category': selectedCategory,
        'condition': selectedCondition,
        'location': locationController.text,
        'contactInfo': contactInfoController.text,
        'imageUrl': imageUrl,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
      };

      await FirebaseFirestore.instance.collection('donate').add(donationData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Product donated successfully!')),
      );

      _clearForm();
    } catch (e) {
      print("Error donating product: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error donating product: $e')),
      );
    } finally {
      setState(() {
        isUploading = false;
      });
    }
  }

  void _clearForm() {
    productNameController.clear();
    descriptionController.clear();
    locationController.clear();
    contactInfoController.clear();
    setState(() {
      selectedCategory = 'Electronics';
      selectedCondition = 'New';
      _imageData = null;
    });
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
          color: Colors.grey[50], // Light background for better contrast
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'DONATE A PRODUCT',
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
                controller: productNameController,
                label: 'Product Name',
                icon: Icons.shopping_bag,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              buildDropdown(
                value: selectedCategory,
                label: 'Category',
                icon: Icons.category,
                items: ['Electronics', 'Study Materials', 'Books', 'Stationary'],
                onChanged: (value) {
                  setState(() {
                    selectedCategory = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              buildDropdown(
                value: selectedCondition,
                label: 'Condition',
                icon: Icons.star,
                items: ['New', 'Used', 'Like New'],
                onChanged: (value) {
                  setState(() {
                    selectedCondition = value!;
                  });
                },
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: contactInfoController,
                label: 'Contact Information',
                icon: Icons.contact_phone,
              ),
             SizedBox(height: 24),
              // Changed from Center to Align.centerLeft
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start, // Align children to the left
                  children: [
                    Container(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload_file, color: Colors.white),
                        label: Text(
                          "Upload Image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                    if (_imageData != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
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
                child: ElevatedButton(
                  onPressed: isUploading ? null : _donateProduct,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    isUploading ? 'Uploading...' : 'Donate Product',
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

  // Helper methods for consistent styling
  Widget buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
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
      ),
    );
  }

  Widget buildDropdown({
    required String value,
    required String label,
    required IconData icon,
    required List<String> items,
    required void Function(String?) onChanged,
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
      ),
      items: items
          .map((item) => DropdownMenuItem(
                value: item,
                child: Text(item),
              ))
          .toList(),
      onChanged: onChanged,
    );
  }
}