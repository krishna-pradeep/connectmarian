import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:lottie/lottie.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:connectmarian/home_screen.dart';
import 'package:connectmarian/myads.dart';
import 'package:connectmarian/wishmaeg.dart';
import 'package:connectmarian/profilepage.dart';
import 'package:connectmarian/loginpage.dart';
import 'package:firebase_auth/firebase_auth.dart';

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
      theme: ThemeData(
        primaryColor: Colors.redAccent,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: DashboardPage(),
    );
  }
}

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  int _selectedIndex = 0;
  bool _isMenuExpanded = false;

  // User Statistics
  int totalAdsPosted = 0;
  int totalProducts = 0;
  int totalDonations = 0;

  // Pages for navigation
  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();
    _pages = [
      DashboardContent(
        totalAdsPosted: totalAdsPosted,
        totalProducts: totalProducts,
        totalDonations: totalDonations,
      ),
      ProfilePage(),
      WishlistPage(wishlist: []),
      AdsPage(),
    ];
    _fetchUserStats();
  }

  Future<void> _fetchUserStats() async {
    final FirebaseFirestore firestore = FirebaseFirestore.instance;

    // Fetch total ads posted from the 'advertise' collection with status 'Approved'
    final QuerySnapshot adsSnapshot = await firestore
        .collection('advertise')
        .where('status', isEqualTo: 'Approved')
        .get();
    setState(() {
      totalAdsPosted = adsSnapshot.docs.length;
    });

    // Fetch total products from the 'sell' collection with status 'Approved'
    final QuerySnapshot sellSnapshot = await firestore
        .collection('sell')
        .where('status', isEqualTo: 'Approved')
        .get();
    setState(() {
      totalProducts = sellSnapshot.docs.length;
    });

    // Fetch total donations from the 'donate' collection with status 'Approved'
    final QuerySnapshot donateSnapshot = await firestore
        .collection('donate')
        .where('status', isEqualTo: 'Approved')
        .get();
    setState(() {
      totalDonations = donateSnapshot.docs.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final double expandedWidth = 220.0;
    final double collapsedWidth = 80.0;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      body: Row(
        children: [
          // Sidebar
          AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: _isMenuExpanded ? expandedWidth : collapsedWidth,
            decoration: BoxDecoration(
              color: const Color.fromARGB(255, 183, 28, 28),
              boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 10)],
            ),
            child: Column(
              children: [
                const SizedBox(height: 40.0),
                IconButton(
                  icon: Icon(
                    _isMenuExpanded ? Icons.close : Icons.menu,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    setState(() {
                      _isMenuExpanded = !_isMenuExpanded;
                    });
                  },
                ),
                Expanded(
                  child: ListView(
                    children: [
                      _buildNavItem(Icons.dashboard, "Dashboard", 0),
                      _buildNavItem(Icons.home, "Home", -1, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => HomePage()),
                        );
                      }),
                      _buildNavItem(Icons.person, "Profile", 1, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => ProfilePage()),
                        );
                      }),
                      _buildNavItem(Icons.add_box, "My Ads", 3, onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyAdsPage()),
                        );
                      }),
                      _buildNavItem(Icons.logout, "Logout", -1, onTap: () {
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                              builder: (context) => Loginpage(title: 'ts')),
                          (route) => false,
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Main Content
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DashboardContent(
                totalAdsPosted: totalAdsPosted,
                totalProducts: totalProducts,
                totalDonations: totalDonations,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index,
      {VoidCallback? onTap}) {
    bool isSelected = _selectedIndex == index;
    return InkWell(
      onTap: onTap ??
          () {
            setState(() {
              _selectedIndex = index;
            });
          },
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        child: Row(
          mainAxisAlignment: _isMenuExpanded
              ? MainAxisAlignment.start
              : MainAxisAlignment.center,
          children: [
            Icon(icon, color: isSelected ? Colors.black : Colors.white, size: 28),
            if (_isMenuExpanded) ...[
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: isSelected ? Colors.black : Colors.white,
                  fontSize: 18,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class DashboardContent extends StatelessWidget {
  final int totalAdsPosted;
  final int totalProducts;
  final int totalDonations;

  DashboardContent({
    required this.totalAdsPosted,
    required this.totalProducts,
    required this.totalDonations,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Header (Moved slightly upwards)
          Padding(
            padding: const EdgeInsets.only(top: 0), // Adjusted top padding
            child: Row(
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundImage: AssetImage('images/bird.jpg'),
                ),
                const SizedBox(width: 16),
                Text(
                  "Dashboard",
                  style: GoogleFonts.poppins(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: const Color.fromARGB(255, 183, 28, 28),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          // Lottie Animation and Welcome Text
          Column(
            children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: Lottie.asset(
                  'images/shopping.json', // Add your Lottie JSON file here
                  fit: BoxFit.contain,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Welcome to Dashboard",
                style: GoogleFonts.poppins(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          // Stats Row
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  "Total Ads",
                  "$totalAdsPosted",
                  Icons.post_add,
                  Colors.redAccent,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStatCard(
                  "Total Products",
                  "$totalProducts",
                  Icons.sell,
                  Colors.green,
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: _buildStatCard(
                  "Total Donation",
                  "$totalDonations",
                  Icons.volunteer_activism,
                  Colors.pink,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 30, color: color),
          const SizedBox(height: 8),
          Text(
            count,
            style: GoogleFonts.poppins(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: GoogleFonts.poppins(
              fontSize: 14,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

class AdsPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return const Center(child: Text("Ads Page"));
  }
}