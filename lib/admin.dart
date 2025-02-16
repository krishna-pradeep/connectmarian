import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_fonts/google_fonts.dart';

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
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.redAccent,
          ),
        );
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.newspaper, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Advertisement Requests',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New requests will appear here',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
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
                        "Advertisement Requests",
                        style: GoogleFonts.poppins(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length}',
                          style: GoogleFonts.poppins(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildAdvertiseRequestCard(
                          snapshot.data!.docs[index], context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildAdvertiseRequestCard(
    QueryDocumentSnapshot doc, BuildContext context) {
  Map<String, dynamic> ad = doc.data() as Map<String, dynamic>;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with image - reduced height
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 140, // Reduced from 200
            width: double.infinity,
            child: ad['imageUrl'] != null
                ? Image.network(
                    ad['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => _buildImageError(),
                  )
                : _buildImageError(),
          ),
        ),
        // Content with reduced padding
        Padding(
          padding: const EdgeInsets.all(12), // Reduced from 16
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(ad, doc),
              const SizedBox(height: 8), // Reduced spacing
              _buildDescription(ad),
              const SizedBox(height: 12),
              _buildMetadata(ad),
              const SizedBox(height: 16),
              _buildActionButtons(doc, context),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildImageError() {
  return Container(
    color: Colors.grey[100],
    child: Icon(
      Icons.image_not_supported,
      size: 40, // Reduced from 50
      color: Colors.grey[400],
    ),
  );
}

Widget _buildHeader(Map<String, dynamic> ad, QueryDocumentSnapshot doc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          ad['title'] ?? 'N/A',
          style: GoogleFonts.poppins(
            fontSize: 16, // Reduced from 20
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 8,
          vertical: 4,
        ),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          'ID: ${doc.id.substring(0, 6)}', // Show less characters
          style: GoogleFonts.poppins(
            fontSize: 11,
            color: Colors.blue[700],
          ),
        ),
      ),
    ],
  );
}

Widget _buildDescription(Map<String, dynamic> ad) {
  return Text(
    ad['description'] ?? 'N/A',
    style: GoogleFonts.poppins(
      fontSize: 13, // Reduced from 14
      color: Colors.grey[600],
    ),
    maxLines: 2, // Reduced from 3
    overflow: TextOverflow.ellipsis,
  );
}

Widget _buildMetadata(Map<String, dynamic> ad) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(Icons.location_on, ad['location'] ?? 'N/A'),
      const SizedBox(height: 4),
      _buildInfoRow(Icons.person, 'By ${ad['hostedBy'] ?? 'N/A'}'),
      const SizedBox(height: 4),
      _buildInfoRow(Icons.access_time, _formatTimestamp(ad['createdAt'])),
    ],
  );
}

Widget _buildInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]), // Reduced from 20
      const SizedBox(width: 4), // Reduced from 8
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12, // Reduced from 14
            color: Colors.grey[600],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildActionButtons(QueryDocumentSnapshot doc, BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 36, // Fixed height for buttons
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: Text(
              'Approve',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _approveAdvertisement(doc),
          ),
        ),
      ),
      const SizedBox(width: 8), // Reduced from 12
      Expanded(
        child: SizedBox(
          height: 36, // Fixed height for buttons
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            label: Text(
              'Reject',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _rejectAdvertisement(doc),
          ),
        ),
      ),
    ],
  );
}


void _approveAdvertisement(QueryDocumentSnapshot doc) async {
  try {
    await doc.reference.update({'status': 'Approved'});

    await FirebaseFirestore.instance.collection('advertise').add({
      'title': doc['title'],
      'description': doc['description'],
      'location': doc['location'],
      'hostedBy': doc['hostedBy'],
      'imageUrl': doc['imageUrl'],
      'createdAt': doc['createdAt'],
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Advertisement Approved',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Error Approving Advertisement: $e',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

void _rejectAdvertisement(QueryDocumentSnapshot doc) async {
  try {
    await doc.reference.delete();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Advertisement Rejected',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Error Rejecting Advertisement: $e',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.redAccent,
          ),
        );
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inventory_2, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Donation Requests',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New requests will appear here',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
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
                        "Donation Requests",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length} Pending',
                          style: GoogleFonts.poppins(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildDonationRequestCard(
                          snapshot.data!.docs[index], context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

Widget _buildDonationRequestCard(QueryDocumentSnapshot doc, BuildContext context) {
  Map<String, dynamic> donation = doc.data() as Map<String, dynamic>;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with image
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 150,
            width: double.infinity,
            child: donation['imageUrl'] != null
                ? Image.network(
                    donation['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageError(),
                  )
                : _buildImageError(),
          ),
        ),
        // Content
        Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(donation, doc),
              const SizedBox(height: 8),
              _buildDescription(donation),
              const SizedBox(height: 12),
              _buildMetadata(donation),
              const SizedBox(height: 16),
              _buildActionButtons(doc, context),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _builddonationImageError() {
  return Container(
    color: Colors.grey[100],
    child: Icon(
      Icons.inventory_2,
      size: 40,
      color: Colors.grey[400],
    ),
  );
}

Widget _builddonationHeader(Map<String, dynamic> donation, QueryDocumentSnapshot doc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          donation['productName'] ?? 'N/A',
          style: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.blue[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              donation['category'] ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.blue[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              donation['condition'] ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 11,
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _builddonationDescription(Map<String, dynamic> donation) {
  return Text(
    donation['description'] ?? 'N/A',
    style: GoogleFonts.poppins(
      fontSize: 13,
      color: Colors.grey[600],
    ),
    maxLines: 2,
    overflow: TextOverflow.ellipsis,
  );
}

Widget _builddonationMetadata(Map<String, dynamic> donation) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(Icons.location_on, donation['location'] ?? 'N/A'),
      const SizedBox(height: 4),
      _buildInfoRow(Icons.phone, donation['contactInfo'] ?? 'N/A'),
      const SizedBox(height: 4),
      _buildInfoRow(
          Icons.access_time, _formatTimestamp(donation['createdAt'])),
    ],
  );
}

Widget _builddonationInfoRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 4),
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12,
            color: Colors.grey[600],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _builddonationActionButtons(QueryDocumentSnapshot doc, BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: Text(
              'Approve',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _approveDonation(doc),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Expanded(
        child: SizedBox(
          height: 36,
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            label: Text(
              'Reject',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13,
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _rejectDonation(doc),
          ),
        ),
      ),
    ],
  );
}



void _approveDonation(QueryDocumentSnapshot doc) async {
  try {
    await doc.reference.update({'status': 'Approved'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Donation Approved',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Error Approving Donation: $e',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

void _rejectDonation(QueryDocumentSnapshot doc) async {
  try {
    await doc.reference.update({'status': 'Rejected'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Donation Rejected',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Error Rejecting Donation: $e',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
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
        return const Center(
          child: CircularProgressIndicator(
            color: Colors.redAccent,
          ),
        );
      }

      if (snapshot.hasError) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
              const SizedBox(height: 16),
              Text(
                'Error: ${snapshot.error}',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: Colors.red[700],
                ),
              ),
            ],
          ),
        );
      }

      if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.shopping_bag, size: 80, color: Colors.grey[400]),
              const SizedBox(height: 16),
              Text(
                'No Product Requests',
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'New requests will appear here',
                style: GoogleFonts.poppins(
                  fontSize: 14,
                  color: Colors.grey[400],
                ),
              ),
            ],
          ),
        );
      }

      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(24.0),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.1),
                    spreadRadius: 1,
                    blurRadius: 10,
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
                        "Product Requests",
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: Colors.red[50],
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          '${snapshot.data!.docs.length} Pending',
                          style: GoogleFonts.poppins(
                            color: Colors.red[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: snapshot.data!.docs.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      return _buildProductRequestCard(
                          snapshot.data!.docs[index], context);
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    },
  );
}

// Previous imports and code remain the same...

Widget _buildProductRequestCard(QueryDocumentSnapshot doc, BuildContext context) {
  Map<String, dynamic> product = doc.data() as Map<String, dynamic>;

  return Card(
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header with image - height reduced from 200 to 150
        ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
          child: SizedBox(
            height: 150, // Matched with donation request height
            width: double.infinity,
            child: product['imageUrl'] != null
                ? Image.network(
                    product['imageUrl'],
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImageError(),
                  )
                : _buildImageError(),
          ),
        ),
        // Content - padding reduced from 16 to 12
        Padding(
          padding: const EdgeInsets.all(12), // Matched with donation request padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(product, doc),
              const SizedBox(height: 8), // Reduced from 12
              _buildDescription(product),
              const SizedBox(height: 12),
              _buildMetadata(product),
              const SizedBox(height: 16),
              _buildActionButtons(doc, context),
            ],
          ),
        ),
      ],
    ),
  );
}

Widget _buildproductHeader(Map<String, dynamic> product, QueryDocumentSnapshot doc) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.spaceBetween,
    children: [
      Expanded(
        child: Text(
          product['productName'] ?? 'N/A',
          style: GoogleFonts.poppins(
            fontSize: 16, // Reduced from 18
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.purple[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product['category'] ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 11, // Reduced from 12
                color: Colors.purple[700],
              ),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 4,
            ),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              product['condition'] ?? 'N/A',
              style: GoogleFonts.poppins(
                fontSize: 11, // Reduced from 12
                color: Colors.green[700],
              ),
            ),
          ),
        ],
      ),
    ],
  );
}

Widget _buildproductDescription(Map<String, dynamic> product) {
  return Text(
    product['description'] ?? 'N/A',
    style: GoogleFonts.poppins(
      fontSize: 13, // Reduced from 14
      color: Colors.grey[600],
    ),
    maxLines: 2, // Reduced from 3
    overflow: TextOverflow.ellipsis,
  );
}

Widget _buildproductMetadata(Map<String, dynamic> product) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      _buildInfoRow(Icons.location_on, product['location'] ?? 'N/A'),
      const SizedBox(height: 4),
      _buildInfoRow(Icons.phone, product['contactInfo'] ?? 'N/A'),
      const SizedBox(height: 4),
      _buildInfoRow(
          Icons.access_time, _formatTimestamp(product['timestamp'])),
    ],
  );
}

Widget _buildInfoproductRow(IconData icon, String text) {
  return Row(
    children: [
      Icon(icon, size: 16, color: Colors.grey[600]),
      const SizedBox(width: 4), // Reduced from 8
      Expanded(
        child: Text(
          text,
          style: GoogleFonts.poppins(
            fontSize: 12, // Reduced from 13
            color: Colors.grey[600],
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ],
  );
}

Widget _buildActionproductButtons(QueryDocumentSnapshot doc, BuildContext context) {
  return Row(
    children: [
      Expanded(
        child: SizedBox(
          height: 36, // Reduced from 40
          child: ElevatedButton.icon(
            icon: const Icon(Icons.check, color: Colors.white, size: 16),
            label: Text(
              'Approve',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13, // Reduced from 14
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _approveProduct(doc, context),
          ),
        ),
      ),
      const SizedBox(width: 8), // Reduced from 12
      Expanded(
        child: SizedBox(
          height: 36, // Reduced from 40
          child: ElevatedButton.icon(
            icon: const Icon(Icons.close, color: Colors.white, size: 16),
            label: Text(
              'Reject',
              style: GoogleFonts.poppins(
                color: Colors.white,
                fontSize: 13, // Reduced from 14
              ),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            onPressed: () => _rejectProduct(doc, context),
          ),
        ),
      ),
    ],
  );
}

// Rest of the code (like _approveProduct, _rejectProduct, etc.) remains the same...


void _approveProduct(QueryDocumentSnapshot doc, BuildContext context) async {
  Map<String, dynamic> product = doc.data() as Map<String, dynamic>;

  try {
    await doc.reference.update({'status': 'Approved'});

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
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Product Approved and Added to Featured Products',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error Approving Product: $e',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }
}

void _rejectProduct(QueryDocumentSnapshot doc, BuildContext context) async {
  try {
    await doc.reference.update({'status': 'Rejected'});

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Text(
              'Product Rejected',
              style: GoogleFonts.poppins(),
            ),
          ],
        ),
        backgroundColor: Colors.orange,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Error Rejecting Product: $e',
                style: GoogleFonts.poppins(),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
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
    }