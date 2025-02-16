import 'package:connectmarian/addfound.dart';
import 'package:connectmarian/addlost.dart';
import 'package:connectmarian/itemdetail.dart';
import 'package:connectmarian/myitem.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LostAndFoundScreen extends StatefulWidget {
  @override
  _LostAndFoundScreenState createState() => _LostAndFoundScreenState();
}

class _LostAndFoundScreenState extends State<LostAndFoundScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  int _selectedIndex = 0; // 0 = Lost, 1 = Found, 2 = My Items

  // Define custom colors
  final Color primaryPurple = Color.fromARGB(255, 248, 71, 71);
  final Color accentGreen = Color.fromARGB(255, 13, 165, 13);
  final Color warningRed = Color.fromARGB(255, 205, 110, 109);
  final Color deepBlue = Color(0xFF1565C0);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Lost and Found",
          style: TextStyle(
            color: Colors.white,
            fontSize: 24,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: primaryPurple,
        elevation: 2,
      ),
      body: _selectedIndex == 2 ? MyItemsScreen() : _buildItemsList(),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: (index) => setState(() => _selectedIndex = index),
        selectedItemColor: primaryPurple,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.search), label: "Lost"),
          BottomNavigationBarItem(icon: Icon(Icons.check_circle), label: "Found"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "My Items"),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(
          Icons.add,
          size: 32,
          color: Colors.white,
        ),
        backgroundColor: accentGreen,
        elevation: 4,
        onPressed: () {
          if (_selectedIndex == 0) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddLostScreen()));
          } else if (_selectedIndex == 1) {
            Navigator.push(context, MaterialPageRoute(builder: (_) => AddFoundScreen()));
          }
        },
      ),
    );
  }

  Widget _buildItemsList() {
    String itemType = _selectedIndex == 0 ? "lost" : "found";
    return StreamBuilder(
      stream: _firestore
          .collection('items')
          .where('type', isEqualTo: itemType)
          .where('status', isEqualTo: 'pending')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(primaryPurple),
            ),
          );
        }

        return ListView(
          padding: EdgeInsets.all(12.0),
          children: snapshot.data!.docs.map((doc) {
            var data = doc.data() as Map<String, dynamic>;
            return Card(
              margin: EdgeInsets.only(bottom: 16.0),
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      data['title'] ?? "No Title",
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: deepBlue,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 8),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: itemType == 'found' 
                            ? accentGreen.withOpacity(0.1)
                            : warningRed.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        itemType == 'found' ? "✅ Found Item" : "🔴 Lost Item",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: itemType == 'found' ? accentGreen : warningRed,
                        ),
                      ),
                    ),
                    SizedBox(height: 16),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: data['imageUrl'] != null && data['imageUrl'].isNotEmpty
                          ? Image.network(
                              data['imageUrl'],
                              height: 200,
                              width: double.infinity,
                              fit: BoxFit.cover,
                            )
                          : Container(
                              height: 200,
                              width: double.infinity,
                              color: Colors.grey[200],
                              child: Icon(
                                Icons.image,
                                size: 64,
                                color: Colors.grey[400],
                              ),
                            ),
                    ),
                    SizedBox(height: 16),
                    Align(
                      alignment: Alignment.centerRight,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: itemType == 'found' ? Colors.redAccent : primaryPurple,
                          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          elevation: 2,
                        ),
                        child: Text(
                          itemType == 'found' ? "Claim" : "I Have This",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => ItemDetailsScreen(data, doc.id),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}