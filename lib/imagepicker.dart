import 'dart:typed_data';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class CloudinaryUploadPage extends StatefulWidget {
  const CloudinaryUploadPage({Key? key}) : super(key: key);

  @override
  _CloudinaryUploadPageState createState() => _CloudinaryUploadPageState();
}

class _CloudinaryUploadPageState extends State<CloudinaryUploadPage> {
  final ImagePicker _picker = ImagePicker();
  Uint8List? _imageData;
  String? _uploadedImageUrl; // To store the uploaded image URL

  // Cloudinary configuration
  final String cloudName =
      "dvlwy2gr2"; // Replace with your Cloudinary cloud name
  final String uploadPreset =
      "Krishnapradeep"; // Replace with your unsigned preset name

  // Function to pick an image from the gallery
  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      // Read the image as bytes for web compatibility
      final imageData = await pickedFile.readAsBytes();
      setState(() {
        _imageData = imageData;
        _uploadedImageUrl = null; // Clear URL when picking a new image
      });
    }
  }

  // Function to upload image to Cloudinary
  Future<void> _uploadToCloudinary() async {
    if (_imageData == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please select an image first")),
      );
      return;
    }

    try {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Uploading to Cloudinary...")),
      );

      // Cloudinary upload endpoint
      final uri =
          Uri.parse("https://api.cloudinary.com/v1_1/dvlwy2gr2/image/upload");

      // Prepare the request
      final request = http.MultipartRequest("POST", uri)
        ..fields["upload_preset"] = uploadPreset
        ..files.add(
          http.MultipartFile.fromBytes(
            "file",
            _imageData!,
            filename: "image.jpg",
          ),
        );

      // Send the request
      final response = await request.send();

      // Handle the response
      if (response.statusCode == 200) {
        final responseData = await response.stream.bytesToString();
        final jsonResponse = jsonDecode(responseData);

        // Get the secure URL of the uploaded image
        final imageUrl = jsonResponse["secure_url"];
        setState(() {
          _uploadedImageUrl = imageUrl; // Store the uploaded image URL
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Uploaded successfully!")),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Upload failed. Please try again.")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error: ${e.toString()}")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Upload Image to Cloudinary"),
        backgroundColor: const Color.fromARGB(255, 238, 140, 165),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (_imageData != null) ...[
              Image.memory(
                _imageData!, // Display the image using Image.memory
                height: 200,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: 20),
            ],
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image from Gallery"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadToCloudinary,
              child: const Text("Upload to Cloudinary"),
            ),
            const SizedBox(height: 20),
            if (_uploadedImageUrl != null) ...[
              const Text(
                "Uploaded Image URL:",
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              GestureDetector(
                onTap: () {
                  // Copy URL to clipboard or open in browser
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("URL copied to clipboard!")),
                  );
                },
                child: Text(
                  _uploadedImageUrl!,
                  style: const TextStyle(
                    color: Colors.blue,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}