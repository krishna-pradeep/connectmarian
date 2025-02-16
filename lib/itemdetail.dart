import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ItemDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> item;
  final String itemId;

  ItemDetailsScreen(this.item, this.itemId);

  // Define custom red colors
  final Color primaryRed = Color(0xFFE53935);
  final Color lightRed = Color(0xFFFFEBEE);
  final Color darkRed = Color(0xFFC62828);

  @override
  Widget build(BuildContext context) {
    final TextEditingController _answerController = TextEditingController();
    final user = FirebaseAuth.instance.currentUser;
    
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: lightRed,
        foregroundColor: darkRed,
        title: Text(
          item['title'] ?? "Item Details",
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 24,
            color: darkRed,
          ),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Item Details Card
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: primaryRed.withOpacity(0.1),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                    border: Border.all(
                      color: lightRed,
                      width: 1,
                    ),
                  ),
                  padding: EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Verification Question",
                        style: TextStyle(
                          fontSize: 16,
                          color: primaryRed,
                          letterSpacing: 0.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        item['question'] ?? 'No question provided',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                          color: Colors.black87,
                        ),
                      ),
                      SizedBox(height: 24),
                      TextField(
                        controller: _answerController,
                        decoration: InputDecoration(
                          labelText: "Your Answer",
                          labelStyle: TextStyle(
                            color: primaryRed,
                            fontWeight: FontWeight.w500,
                          ),
                          hintText: "Enter your answer here...",
                          filled: true,
                          fillColor: lightRed.withOpacity(0.3),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: primaryRed,
                              width: 2,
                            ),
                          ),
                          contentPadding: EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 16,
                          ),
                        ),
                        maxLines: 3,
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        cursorColor: primaryRed,
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 32),
                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: () async {
                      if (user == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("User not authenticated"),
                            backgroundColor: darkRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      if (_answerController.text.trim().isEmpty) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Please enter an answer"),
                            backgroundColor: primaryRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      if (item['userId'] == null) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error: Item owner ID missing!"),
                            backgroundColor: darkRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        return;
                      }

                      try {
                        await FirebaseFirestore.instance.collection('claims').add({
                          'itemId': itemId,
                          'itemTitle': item['title'] ?? 'Unknown Item',
                          'claimedBy': user.uid,
                          'itemOwnerId': item['userId'],
                          'answer': _answerController.text.trim(),
                          'contact': item['contact'] ?? 'No contact info',
                          'status': 'pending',
                          'createdAt': FieldValue.serverTimestamp(),
                        });

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Claim request sent successfully!"),
                            backgroundColor: Colors.green,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                        Navigator.pop(context);
                      } catch (error) {
                        print("Error submitting claim: $error");
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text("Error submitting claim: $error"),
                            backgroundColor: darkRed,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      foregroundColor: Colors.white, backgroundColor: primaryRed,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: 0,
                    ),
                    child: Text(
                      "Submit Claim",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}