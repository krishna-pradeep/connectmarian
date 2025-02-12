import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(home: Lost()));
}

class Lost extends StatefulWidget {
  @override
  _LostState createState() => _LostState();
}

class _LostState extends State<Lost> {
  final List<Map<String, dynamic>> lostItems = [
    {
      "timestamp": "2024-02-05T21:30:32.622654",
      "description": "Wallet found at canteen in the morning",
      "image": "assets/wallet.jpg", // Placeholder image
      "question": "Amount of money",
    },
    {
      "timestamp": "2024-02-05T21:27:30.977285",
      "description": "Found this mobile at 9607",
      "image": "assets/phone.jpg",
      "question": "Phone color",
    },
    {
      "timestamp": "2024-02-04T11:07:02.272",
      "description": "Found",
      "image": "assets/book.jpg",
      "question": "Brand name",
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Home"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView.builder(
        padding: EdgeInsets.all(8),
        itemCount: lostItems.length,
        itemBuilder: (context, index) {
          final item = lostItems[index];

          return Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
              side: BorderSide(color: Colors.black),
            ),
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("Posted: ${item['timestamp']}",
                      style: TextStyle(fontSize: 12, color: Colors.grey)),
                  SizedBox(height: 5),
                  Text(item['description'],
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  SizedBox(height: 5),
                  Container(
                    height: 100,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                    ),
                    child: Center(
                      child: Icon(Icons.image, size: 50, color: Colors.grey),
                    ),
                  ),
                  SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () => _showClaimDialog(context, item['question']),
                      child: Text("Claim"),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.white,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.black54,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: ""),
          BottomNavigationBarItem(
              icon: Icon(Icons.add_circle, size: 40), label: ""),
          BottomNavigationBarItem(icon: Icon(Icons.archive), label: ""),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.push(
                context, MaterialPageRoute(builder: (context) => CreatePost()));
          }
        },
      ),
    );
  }

  void _showClaimDialog(BuildContext context, String question) {
    TextEditingController answerController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10)),
          title: Text("Claim Box"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text("Question: $question"),
              SizedBox(height: 10),
              TextField(
                controller: answerController,
                decoration: InputDecoration(
                  hintText: "Your Answer",
                  border: OutlineInputBorder(),
                ),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
              ),
              onPressed: () {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text("Claim submitted")));
              },
              child: Text("Submit"),
            ),
          ],
        );
      },
    );
  }
}

// Create Post Screen
class CreatePost extends StatefulWidget {
  @override
  _CreatePostState createState() => _CreatePostState();
}

class _CreatePostState extends State<CreatePost> {
  bool isLost = true;
  TextEditingController descriptionController = TextEditingController();
  TextEditingController questionController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Create Post"),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _buildToggleButton("Lost", isLost, () {
                  setState(() {
                    isLost = true;
                  });
                }),
                SizedBox(width: 10),
                _buildToggleButton("Found", !isLost, () {
                  setState(() {
                    isLost = false;
                  });
                }),
              ],
            ),
            SizedBox(height: 10),
            _buildTextField(descriptionController, "Enter your description here..."),
            SizedBox(height: 10),
            _buildTextField(questionController, "Enter your question here..."),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                onPressed: () {},
                child: Text("Import Photo"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleButton(String label, bool isSelected, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.black : Colors.grey[300],
        foregroundColor: isSelected ? Colors.white : Colors.black,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hintText) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        hintText: hintText,
        border: OutlineInputBorder(),
      ),
    );
  }
}
