import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        '/': (context) => AdminDashboard(),
      },
    );
  }
}

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({Key? key}) : super(key: key);

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
  }

  String _formatTimestamp(dynamic timestamp) {
    if (timestamp == null) return 'N/A';
    
    DateTime dateTime = timestamp is Timestamp 
      ? timestamp.toDate() 
      : timestamp;
    
    return '${dateTime.year}-${dateTime.month.toString().padLeft(2, '0')}-${dateTime.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: const [
            Icon(
              Icons.inventory_2,
              size: 24,
            ),
            SizedBox(width: 10),
            Text("Connect @ Marian Inventory"),
          ],
        ),
        backgroundColor: const Color.fromARGB(255, 199, 40, 40),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: const [
            Tab(text: "Dashboard"),
            Tab(text: "Products"),
            Tab(text: "Donations"),
            Tab(text:"Advertise Requests"),
            Tab(text: "Product Requests"),
            Tab(text: "Donation Requests"),
            Tab(text: "Manage Users")
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          
          _buildDashboardContent(),
          _buildProductsTable(),
          _buildDonationsTable(),
           _buildAdvertiseRequestsTable(),
          _buildProductRequestsTable(),
          _buildDonationRequestsTable(),
          _buildUsersTable()

        ],
      ),
    );
  }

 // Add this widget to your admin dashboard file

Widget _buildAdvertiseRequestsTable() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('advertise')
        .where('status', isEqualTo: 'Pending')
        .snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(child: Text('No advertisement requests found'));
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Advertisement Requests",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) => Colors.red.shade100,
                ),
                columns: const [
                  DataColumn(label: Text('ID')),
                  DataColumn(label: Text('Title')),
                  DataColumn(label: Text('Description')),
                  DataColumn(label: Text('Location')),
                  DataColumn(label: Text('Hosted By')),
                  DataColumn(label: Text('Image')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: _getAdvertiseRequestRows(snapshot.data!.docs),
              ),
            ),
          ],
        ),
      );
    },
  );
}

List<DataRow> _getAdvertiseRequestRows(List<QueryDocumentSnapshot> documents) {
  return documents.map((doc) {
    Map<String, dynamic> ad = doc.data() as Map<String, dynamic>;

    return DataRow(cells: [
      DataCell(Text(doc.id)),
      DataCell(Text(ad['title'] ?? 'N/A')),
      DataCell(Text(ad['description'] ?? 'N/A')),
      DataCell(Text(ad['location'] ?? 'N/A')),
      DataCell(Text(ad['hostedBy'] ?? 'N/A')),
      DataCell(
        ad['imageUrl'] != null
            ? Image.network(
                ad['imageUrl'],
                width: 50,
                height: 50,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Icon(Icons.error);
                },
              )
            : Text('No Image'),
      ),
      DataCell(Text(_formatTimestamp(ad['createdAt']))),
      DataCell(
        Row(
          children: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
              onPressed: () => _approveAdvertisement(doc),
              child: Text('Approve', style: TextStyle(color: Colors.white)),
            ),
            SizedBox(width: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () => _rejectAdvertisement(doc),
              child: Text('Reject', style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      ),
    ]);
  }).toList();
}

void _approveAdvertisement(QueryDocumentSnapshot doc) async {
  try {
    // Update the advertisement's status to approved
    await doc.reference.update({'status': 'Approved'});

    // Add to featured advertisements collection
    await FirebaseFirestore.instance.collection('advertise').add({
      'title': doc['title'],
      'description': doc['description'],
      'location': doc['location'],
      'hostedBy': doc['hostedBy'],
      'imageUrl': doc['imageUrl'],
      'createdAt': doc['createdAt'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Advertisement Approved')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error Approving Advertisement: $e')),
    );
  }
}

void _rejectAdvertisement(QueryDocumentSnapshot doc) async {
  try {
    // Delete the advertisement from Firestore
    await doc.reference.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Advertisement Rejected')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error Rejecting Advertisement: $e')),
    );
  }
}
  Widget _buildDonationRequestsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('donate')
          .where('status', isEqualTo: 'Pending')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No donation requests found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Donation Requests",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) => Colors.red.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Condition')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _getDonationRequestRows(snapshot.data!.docs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _getDonationRequestRows(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      Map<String, dynamic> donation = doc.data() as Map<String, dynamic>;

      return DataRow(cells: [
        DataCell(Text(doc.id)),
        DataCell(Text(donation['productName'] ?? 'N/A')),
        DataCell(Text(donation['description'] ?? 'N/A')),
        DataCell(Text(donation['category'] ?? 'N/A')),
        DataCell(Text(donation['condition'] ?? 'N/A')),
        DataCell(Text(donation['location'] ?? 'N/A')),
        DataCell(Text(donation['contactInfo'] ?? 'N/A')),
        DataCell(
          donation['imageUrl'] != null
              ? Image.network(
                  donation['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
              : Text('No Image'),
        ),
        DataCell(Text(_formatTimestamp(donation['createdAt']))),
        DataCell(
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _approveDonation(doc),
                child: Text('Approve', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _rejectDonation(doc),
                child: Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  void _approveDonation(QueryDocumentSnapshot doc) async {
  try {
    // Update the donation's status to approved
    await doc.reference.update({'status': 'Approved'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Donation Approved')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error Approving Donation: $e')),
    );
  }
}

  void _rejectDonation(QueryDocumentSnapshot doc) async {
    try {
      // Update the donation's status to rejected
      await doc.reference.update({'status': 'Rejected'});

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Donation Rejected')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error Rejecting Donation: $e')),
      );
    }
  }
   Widget _buildProductRequestsTable() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance
        .collection('sell')
        .where('status', isEqualTo: 'Pending')
        .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No product requests found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Product Requests",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) => Colors.red.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Condition')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Created At')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _getProductRequestRows(snapshot.data!.docs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _getProductRequestRows(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;

      return DataRow(cells: [
        DataCell(Text(doc.id)),
        DataCell(Text(product['productName'] ?? 'N/A')),
        DataCell(Text(product['description'] ?? 'N/A')),
        DataCell(Text(product['category'] ?? 'N/A')),
        DataCell(Text(product['condition'] ?? 'N/A')),
        DataCell(Text(product['price'] ?? 'N/A')),
        DataCell(Text(product['location'] ?? 'N/A')),
        DataCell(Text(product['contactInfo'] ?? 'N/A')),
        DataCell(
          product['imageUrl'] != null
              ? Image.network(
                  product['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
              : Text('No Image'),
        ),
        DataCell(Text(_formatTimestamp(product['timestamp']))),
        DataCell(
          Row(
            children: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                onPressed: () => _approveProduct(doc),
                child: Text('Approve', style: TextStyle(color: Colors.white)),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                onPressed: () => _rejectProduct(doc),
                child: Text('Reject', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ]);
    }).toList();
  }

  void _approveProduct(QueryDocumentSnapshot doc) async {
  Map<String, dynamic> product = doc.data() as Map<String, dynamic>;

  try {
    // Update the product's status in the sell collection
    await doc.reference.update({'status': 'Approved'});

    // Add to featured products collection
    await FirebaseFirestore.instance.collection('featured_products').add({
      'productName': product['productName'],
      'description': product['description'],
      'category': product['category'],
      'condition': product['condition'],
      'price': product['price'],
      'location': product['location'],
      'contactInfo': product['contactInfo'],
      'imageUrl': product['imageUrl'],
      'timestamp': product['timestamp'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product Approved and Added to Featured Products')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error Approving Product: $e')),
    );
  }
}

void _rejectProduct(QueryDocumentSnapshot doc) async {
  try {
    // Update the product's status to rejected
    await doc.reference.update({'status': 'Rejected'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Product Rejected')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error Rejecting Product: $e')),
    );
  }
}

  
}

  Widget _buildProductsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('sell').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No products found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Products",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) => Colors.red.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Condition')),
                    DataColumn(label: Text('Price')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Created At')),
                  ],
                  rows: _getProductRows(snapshot.data!.docs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _getProductRows(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      // Convert the document to a map
      Map<String, dynamic> product = doc.data() as Map<String, dynamic>;

      return DataRow(cells: [
        DataCell(Text(doc.id)), // Use Firestore document ID
        DataCell(Text(product['productName'] ?? 'N/A')),
        DataCell(Text(product['description'] ?? 'N/A')),
        DataCell(Text(product['category'] ?? 'N/A')),
        DataCell(Text(product['condition'] ?? 'N/A')),
        DataCell(Text(product['price'] ?? 'N/A')),
        DataCell(Text(product['location'] ?? 'N/A')),
        DataCell(Text(product['contactInfo'] ?? 'N/A')),
        DataCell(
          product['imageUrl'] != null
              ? Image.network(
                  product['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
              : Text('No Image'),
        ),
        DataCell(Text(_formatTimestamp(product['timestamp']))),
      ]);
    }).toList();
  }

  Widget _buildDonationsTable() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('donate').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Center(child: Text('No donations found'));
        }

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  "Donations",
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                    (states) => Colors.red.shade100,
                  ),
                  columns: const [
                    DataColumn(label: Text('ID')),
                    DataColumn(label: Text('Product Name')),
                    DataColumn(label: Text('Description')),
                    DataColumn(label: Text('Category')),
                    DataColumn(label: Text('Condition')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Contact')),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Created At')),
                  ],
                  rows: _getDonationRows(snapshot.data!.docs),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<DataRow> _getDonationRows(List<QueryDocumentSnapshot> documents) {
    return documents.map((doc) {
      // Convert the document to a map
      Map<String, dynamic> donation = doc.data() as Map<String, dynamic>;

      return DataRow(cells: [
        DataCell(Text(doc.id)), // Use Firestore document ID
        DataCell(Text(donation['productName'] ?? 'N/A')),
        DataCell(Text(donation['description'] ?? 'N/A')),
        DataCell(Text(donation['category'] ?? 'N/A')),
        DataCell(Text(donation['condition'] ?? 'N/A')),
        DataCell(Text(donation['location'] ?? 'N/A')),
        DataCell(Text(donation['contactInfo'] ?? 'N/A')),
        DataCell(
          donation['imageUrl'] != null
              ? Image.network(
                  donation['imageUrl'],
                  width: 50,
                  height: 50,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.error);
                  },
                )
              : Text('No Image'),
        ),
        DataCell(Text(_formatTimestamp(donation['createdAt']))),
      ]);
    }).toList();
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'N/A';
    return '${timestamp.toDate().year}-${timestamp.toDate().month.toString().padLeft(2, '0')}-${timestamp.toDate().day.toString().padLeft(2, '0')}';
  }

Widget _buildUsersTable() {
  return StreamBuilder<QuerySnapshot>(
    stream: FirebaseFirestore.instance.collection('users').snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      }

      if (snapshot.hasError) {
        return Center(child: Text('Error: ${snapshot.error}'));
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return const Center(child: Text('No users found'));
      }

      final users = snapshot.data!.docs;

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                "Manage Users",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: DataTable(
                headingRowColor: MaterialStateProperty.resolveWith<Color?>(
                  (states) => Colors.red.shade100,
                ),
                columns: const [
                  DataColumn(label: Text('Name')),
                  DataColumn(label: Text('Email')),
                  DataColumn(label: Text('Phone Number')),
                  DataColumn(label: Text('Created At')),
                  DataColumn(label: Text('Actions')),
                ],
                rows: users.map((doc) {
                  Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;

                  return DataRow(cells: [
                    DataCell(Text(userData['name'] ?? 'N/A')),
                    DataCell(Text(userData['email'] ?? 'N/A')),
                    DataCell(Text(userData['number'] ?? 'N/A')),
                    DataCell(Text(_formatUserTimestamp(userData['createdAt']))),
                    DataCell(
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.block, color: Colors.orange),
                            onPressed: () => _showBlockUserConfirmation(context, doc),
                            tooltip: 'Block/Unblock User',
                          ),
                        ],
                      ),
                    ),
                  ]);
                }).toList(),
              ),
            ),
          ],
        ),
      );
    },
  );
}

String _formatUserTimestamp(dynamic timestamp) {
  if (timestamp == null) return 'N/A';

  if (timestamp is Timestamp) {
    final dateTime = timestamp.toDate();
    return '${dateTime.day} ${_getMonthName(dateTime.month)} ${dateTime.year} at '
        '${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')} UTC';
  }

  return 'Invalid Date';
}

String _getMonthName(int month) {
  const monthNames = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December'
  ];
  return monthNames[month - 1];
}

void _showBlockUserConfirmation(BuildContext context, QueryDocumentSnapshot userDoc) {
  final userData = userDoc.data() as Map<String, dynamic>;
  final isBlocked = userData['isBlocked'] ?? false;

  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(isBlocked ? 'Unblock User' : 'Block User'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            isBlocked
                ? 'Are you sure you want to unblock this user?'
                : 'Are you sure you want to block this user?',
          ),
          const SizedBox(height: 16),
          Text('Name: ${userData['name']}'),
          Text('Email: ${userData['email']}'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isBlocked ? Colors.green : Colors.orange,
          ),
          onPressed: () => _toggleUserBlock(context, userDoc, !isBlocked),
          child: Text(
            isBlocked ? 'Unblock User' : 'Block User',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ],
    ),
  );
}

Future<void> _toggleUserBlock(BuildContext context, QueryDocumentSnapshot userDoc, bool block) async {
  try {
    await userDoc.reference.update({'isBlocked': block});

    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(block ? 'User blocked successfully' : 'User unblocked successfully'),
        backgroundColor: Colors.green,
      ),
    );
  } catch (error) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error updating user status: $error'),
        backgroundColor: Colors.red,
      ),
    );
  }
}
Widget _buildDashboardContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Dashboard Overview",
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 24),
          // Info Cards Row
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                _buildInfoCardFromDatabase("PRODUCTS", "sell", Icons.inventory_2),
                const SizedBox(width: 16),
                _buildInfoCardFromDatabase("DONATIONS", "donate", Icons.card_giftcard),
                const SizedBox(width: 16),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Charts Row
          Row(
            children: [
              Expanded(child: _buildCategoriesBarChart()),
              const SizedBox(width: 24),
              Expanded(child: _buildProductsLineChart()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCardFromDatabase(String title, String collection, IconData icon) {
    return FutureBuilder<int>(
      future: _getCollectionCount(collection),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildInfoCard(title, "Loading...", icon);
        } else if (snapshot.hasError) {
          return _buildInfoCard(title, "Error", icon);
        } else {
          return _buildInfoCard(title, snapshot.data.toString(), icon);
        }
      },
    );
  }

  Future<int> _getCollectionCount(String collection) async {
    QuerySnapshot querySnapshot =
        await FirebaseFirestore.instance.collection(collection).get();
    return querySnapshot.size;
  }

  

  
Widget _buildInfoCard(String title, String count, IconData icon) {
  return Container(
    width: 175,
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
            Icon(icon, color: Colors.blue),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          count,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}


Widget _buildCategoriesBarChart() {
  return FutureBuilder<Map<String, int>>(
    future: _getCategoryCounts(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return _loadingChart();
      } else if (snapshot.hasError) {
        return _errorChart();
      } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
        return _emptyChart();
      } else {
        return _buildBarChart(snapshot.data!);
      }
    },
  );
}

Future<Map<String, int>> _getCategoryCounts() async {
  QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection("sell").get();

  Map<String, int> categoryCounts = {};

  for (var doc in querySnapshot.docs) {
    String category = doc['category'] ?? 'Others';
    categoryCounts[category] = (categoryCounts[category] ?? 0) + 1;
  }

  return categoryCounts;
}

Widget _buildBarChart(Map<String, int> categoryCounts) {
  List<String> categories = categoryCounts.keys.toList();
  List<BarChartGroupData> barGroups = [];

  for (int i = 0; i < categories.length; i++) {
    barGroups.add(
      BarChartGroupData(
        x: i,
        barRods: [
          BarChartRodData(
            toY: categoryCounts[categories[i]]!.toDouble(),
            color: Colors.blue,
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
    );
  }

  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Top Categories",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: BarChart(
            BarChartData(
              alignment: BarChartAlignment.spaceEvenly,
              maxY: (categoryCounts.values.isNotEmpty ? categoryCounts.values.reduce((a, b) => a > b ? a : b) + 5 : 10).toDouble(),
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                horizontalInterval: 1,
                getDrawingHorizontalLine: (value) {
                  return FlLine(
                    color: Colors.grey[300],
                    strokeWidth: 1,
                  );
                },
              ),
              titlesData: FlTitlesData(
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    getTitlesWidget: (value, meta) {
                      if (value.toInt() < categories.length) {
                        return RotatedBox(
                          quarterTurns: 1,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 10.0),
                            child: Text(
                              categories[value.toInt()],
                              style: const TextStyle(fontSize: 8),
                            ),
                          ),
                        );
                      }
                      return const Text('');
                    },
                    interval: 1,
                  ),
                ),
              ),
              barGroups: barGroups,
            ),
          ),
        ),
      ],
    ),
  );
}

Widget _loadingChart() {
  return const Center(child: CircularProgressIndicator());
}

Widget _errorChart() {
  return const Center(child: Text("Error loading chart"));
}

Widget _emptyChart() {
  return const Center(child: Text("No category data available"));
}
Widget _buildProductsLineChart() {
  return Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Colors.grey.shade200),
      boxShadow: [
        BoxShadow(
          color: Colors.grey.withOpacity(0.1),
          spreadRadius: 1,
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Product Trends",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 24),
        SizedBox(
          height: 200,
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: true,
                horizontalInterval: 5,
                verticalInterval: 1,
                getDrawingHorizontalLine: (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                ),
                getDrawingVerticalLine: (value) => FlLine(
                  color: Colors.grey.shade300,
                  strokeWidth: 1,
                ),
              ),
              titlesData: FlTitlesData(
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 5,
                    getTitlesWidget: (value, meta) {
                      return Text(
                        value.toInt().toString(),
                        style: const TextStyle(fontSize: 10),
                      );
                    },
                  ),
                ),
                bottomTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1,
                    getTitlesWidget: (value, meta) {
                      const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
                      if (value.toInt() >= 0 && value.toInt() < months.length) {
                        return Text(
                          months[value.toInt()],
                          style: const TextStyle(fontSize: 10),
                        );
                      }
                      return const Text('');
                    },
                  ),
                ),
                rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
                topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
              ),
              borderData: FlBorderData(
                show: true,
                border: Border.all(color: Colors.grey.shade300, width: 1),
              ),
              lineBarsData: [
                LineChartBarData(
                  spots: [
                    const FlSpot(0, 10),
                    const FlSpot(1, 20),
                    const FlSpot(2, 15),
                    const FlSpot(3, 25),
                    const FlSpot(4, 18),
                  ],
                  isCurved: true,
                  color: Colors.blue,
                  barWidth: 3,
                  isStrokeCapRound: true,
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        Colors.blue.withOpacity(0.3),
                        Colors.blue.withOpacity(0.1),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
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
