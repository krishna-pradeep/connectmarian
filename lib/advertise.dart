import 'dart:convert';
import 'dart:typed_data';
import 'package:connectmarian/termsandcondition.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
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
        '/': (context) => AddAdvertisementPage(),
        '/terms': (context) => TermsAndConditionsPage(),
      },
    );
  }
}

class AddAdvertisementPage extends StatefulWidget {
  @override
  _AddAdvertisementPageState createState() => _AddAdvertisementPageState();
}

class _AddAdvertisementPageState extends State<AddAdvertisementPage> {
  bool isAgreed = false;
  DateTime? selectedDate;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final TextEditingController titleController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  final TextEditingController hostedByController = TextEditingController();
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;

  final String cloudName = "dvlwy2gr2"; // Replace with your Cloudinary cloud name
  final String uploadPreset = "Krishnapradeep"; // Replace with your Cloudinary preset name

  Future<void> _pickDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

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

  Future<void> _uploadFile() async {
    final User? user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('You must be logged in to add an advertisement.')),
      );
      return;
    }

    if (titleController.text.isEmpty ||
        locationController.text.isEmpty ||
        descriptionController.text.isEmpty ||
        hostedByController.text.isEmpty ||
        selectedDate == null ||
        _imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill in all fields and select an image.')),
      );
      return;
    }

    try {
      // Upload the image to Cloudinary
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Uploading image...')),
      );
      final imageUrl = await _uploadImageToCloudinary();

      if (imageUrl == null) return;

      // Prepare advertisement data
      final adData = {
        'userId': user.uid, // Store the user ID
        'title': titleController.text,
        'location': locationController.text,
        'description': descriptionController.text,
        'hostedBy': hostedByController.text,
        'imageUrl': imageUrl,
        'date': selectedDate!.toIso8601String(),
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'Pending',
      };

      // Add new advertisement to Firestore
      await FirebaseFirestore.instance.collection('advertise').add(adData);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Advertisement added successfully!')),
      );

      setState(() {
        titleController.clear();
        locationController.clear();
        descriptionController.clear();
        hostedByController.clear();
        _imageData = null;
        selectedDate = null;
      });
    } catch (e) {
      print("Error uploading advertisement: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error adding advertisement: $e')),
      );
    }
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
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'ADD ADVERTISEMENT',
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
                controller: titleController,
                label: 'Title',
                icon: Icons.title,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: locationController,
                label: 'Location',
                icon: Icons.location_on,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: descriptionController,
                label: 'Description',
                icon: Icons.description,
                maxLines: 3,
              ),
              SizedBox(height: 16),
              buildTextField(
                controller: hostedByController,
                label: 'Hosted By',
                icon: Icons.person,
              ),
              SizedBox(height: 16),
              buildDateField(context),
              SizedBox(height: 24),
              Align(
                alignment: Alignment.centerLeft,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 150,
                      child: ElevatedButton.icon(
                        onPressed: _pickImage,
                        icon: Icon(Icons.upload_file, color: Colors.white),
                        label: Text(
                          "Upload image",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: EdgeInsets.symmetric(vertical: 10),
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
                          mainAxisSize: MainAxisSize.min,
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
              SizedBox(height: 16),
              buildTermsAndConditions(),
              SizedBox(height: 24),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: isAgreed ? _uploadFile : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    disabledBackgroundColor: Colors.grey,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 2,
                  ),
                  child: Text(
                    'Add Advertisement',
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

  Widget buildDateField(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: 'Date',
        prefixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
        suffixIcon: IconButton(
          icon: Icon(Icons.calendar_today),
          onPressed: () => _pickDate(context),
        ),
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
      controller: TextEditingController(
        text: selectedDate == null
            ? ''
            : "${selectedDate!.day}/${selectedDate!.month}/${selectedDate!.year}",
      ),
      readOnly: true,
    );
  }

  Widget buildTermsAndConditions() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[300]!),
      ),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          Transform.scale(
            scale: 1.1,
            child: Checkbox(
              value: isAgreed,
              onChanged: (value) => setState(() => isAgreed = value!),
              activeColor: Colors.red,
            ),
          ),
          Expanded(
            child: Row(
              children: [
                Text(
                  'I have read and agree to',
                  style: TextStyle(fontSize: 14),
                ),
                GestureDetector(
                  onTap: () => Navigator.pushNamed(context, '/terms'),
                  child: Text(
                    'terms and conditions',
                    style: TextStyle(
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}