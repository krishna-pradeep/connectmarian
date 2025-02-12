import 'package:connectmarian/advertise.dart';
import 'package:connectmarian/dashboard.dart';
import 'package:connectmarian/donate.dart';
import 'package:connectmarian/sell.dart';
import 'package:connectmarian/wishmaeg.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String selectedTab = 'DASHBOARD';
  List<Map<String, dynamic>> featuredProducts = [];
  List<Map<String, dynamic>> featuredAdvertisements = [];
  List<Map<String, dynamic>> wishlist = [];
  List<Map<String, dynamic>> donatedProducts = [];

  @override
  void initState() {
    super.initState();
    _fetchFeaturedProducts();
    _fetchFeaturedAdvertisements();
    _fetchDonatedProducts();
  }

  void _fetchFeaturedProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('sell')
          .where('status', isEqualTo: 'Approved')
          .get();

      setState(() {
        featuredProducts = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching featured products: $e');
    }
  }

  void _fetchFeaturedAdvertisements() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('advertise')
          .where('status', isEqualTo: 'Approved')
          .get();

      setState(() {
        featuredAdvertisements = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching advertisements: $e');
    }
  }

  void _fetchDonatedProducts() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection('donate')
          .where('status', isEqualTo: 'Approved')
          .get();

      setState(() {
        donatedProducts = querySnapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print('Error fetching donated products: $e');
    }
  }

  void _toggleWishlist(Map<String, dynamic> product) {
    setState(() {
      if (wishlist.contains(product)) {
        wishlist.remove(product);
      } else {
        wishlist.add(product);
      }
    });
  }

  Widget _buildTabButton(String title, VoidCallback onPressed) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: selectedTab == title
            ? const Color.fromARGB(255, 199, 40, 40)
            : Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      onPressed: () {
        setState(() {
          selectedTab = title;
        });
        onPressed();
      },
      child: Text(title),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildTabButton('DASHBOARD', () {
                Navigator.push(
                    context, MaterialPageRoute(builder: (context) => DashboardPage()));
              }),
              _buildTabButton('WISHLIST', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => WishlistPage(wishlist: wishlist)),
                );
              }),
              _buildTabButton('ADVERTISE', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => AddAdvertisementPage()),
                );
              }),
              _buildTabButton('DONATE', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => DonateProductPage()),
                );
              }),
              _buildTabButton('+ SELL', () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SellProductPage()),
                );
              }),
            ],
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 400,
              width: double.infinity,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('images/images.png'),
                  fit: BoxFit.cover,
                ),
              ),
              child: Center(
                child: GestureDetector(
                  onTap: () => _showSearchDialog(context),
                  child: Container(
                    color: Colors.black.withOpacity(0.5),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.search, color: Colors.white, size: 24),
                        SizedBox(width: 10),
                        Text(
                          'Welcome to Connect at Marian! :)',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),

            // Featured Advertisements
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Featured Advertisements',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 200,
              child: featuredAdvertisements.isEmpty
                  ? Center(child: Text('No advertisements'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredAdvertisements.length,
                      itemBuilder: (context, index) {
                        var ad = featuredAdvertisements[index];
                        return _buildAdCard(
                          title: ad['title'] ?? 'N/A',
                          subtitle: ad['location'] ?? 'N/A',
                          description: ad['description'] ?? 'N/A',
                          imagePath: ad['imageUrl'] ?? 'images/placeholder.jpg',
                        );
                      },
                    ),
            ),

            // Featured Products
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Featured Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 260,
              child: featuredProducts.isEmpty
                  ? Center(child: Text('No featured products'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: featuredProducts.length,
                      itemBuilder: (context, index) {
                        var product = featuredProducts[index];
                        return _buildProductCard(
                          product: product,
                          isWishlist: wishlist.contains(product),
                          onWishlistToggle: () => _toggleWishlist(product),
                        );
                      },
                    ),
            ),

            // Donated Products Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Donated Products',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 260,
              child: donatedProducts.isEmpty
                  ? Center(child: Text('No donated products'))
                  : ListView.builder(
                      scrollDirection: Axis.horizontal,
                      itemCount: donatedProducts.length,
                      itemBuilder: (context, index) {
                        var product = donatedProducts[index];
                        return _buildProductCard(
                          product: product,
                          isWishlist: wishlist.contains(product),
                          onWishlistToggle: () => _toggleWishlist(product),
                        );
                      },
                    ),
            ),

            // Shop by Category Section
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Text(
                  'Shop by Category',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 120,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: [
                  _buildCategoryCard('Electronics', 'images/electronics.jpg', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsPage(category: 'Electronics'),
                      ),
                    );
                  }),
                  _buildCategoryCard('Study Materials', 'images/study_materials.jpg', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsPage(category: 'Study Materials'),
                      ),
                    );
                  }),
                  _buildCategoryCard('Hostel Materials', 'images/hostel_materials.jpg', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsPage(category: 'Hostel Materials'),
                      ),
                    );
                  }),
                  _buildCategoryCard('Stationary', 'images/stationary.jpg', () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => CategoryProductsPage(category: 'Stationary'),
                      ),
                    );
                  }),
                ],
              ),
            ),

            // Contact Us Section
            Container(
              width: double.infinity,
              color: const Color.fromARGB(255, 199, 40, 40),
              padding: const EdgeInsets.all(16.0),
              child: Column(
                children: [
                  Text(
                    'Contact Us',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'If you have any complaints, feedback, or inquiries, feel free to reach out to us at:',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Email: connectatmarian@gmail.com',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 8),
                  Text(
                    'We appreciate your feedback and will get back to you as soon as possible!',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 16),
                  Text(
                    '© 2025 Connect at Marian',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdCard({
    required String title,
    required String subtitle,
    String? description,
    required String imagePath,
  }) {
    return Container(
      width: 180,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 80,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
              image: DecorationImage(
                image: NetworkImage(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 12, color: Colors.black),
                    SizedBox(width: 4),
                    Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.black)),
                  ],
                ),
                if (description != null) SizedBox(height: 8),
                if (description != null)
                  Text(description, style: TextStyle(fontSize: 12, color: Colors.black)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard({
    required Map<String, dynamic> product,
    required bool isWishlist,
    required VoidCallback onWishlistToggle,
  }) {
    return Container(
      width: 200,
      margin: EdgeInsets.symmetric(horizontal: 8.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.3),
            blurRadius: 5,
            spreadRadius: 2,
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          showModalBottomSheet(
            context: context,
            builder: (BuildContext context) {
              return Container(
                padding: EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      children: [
                        Image.network(
                          product['imageUrl'] ?? 'images/placeholder.jpg', 
                          height: 100, 
                          width: 100, 
                          fit: BoxFit.cover
                        ),
                        SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                product['productName'] ?? 'N/A',
                                style: TextStyle(
                                  fontSize: 18, 
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Description: ${product['description'] ?? 'No description'}',
                      style: TextStyle(fontSize: 14),
                    ),
                    SizedBox(height: 16),
                    Text('Category: ${product['category'] ?? 'N/A'}'),
                    Text('Condition: ${product['condition'] ?? 'N/A'}'),
                    Text('Location: ${product['location'] ?? 'N/A'}'),
                    SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: () => _callPhone(product['contactInfo']),
                      icon: Icon(Icons.call),
                      label: Text('Call Seller'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 100,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(8.0)),
                    image: DecorationImage(
                      image: NetworkImage(product['imageUrl'] ?? 'images/placeholder.jpg'),
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: onWishlistToggle,
                    child: Icon(
                      isWishlist ? Icons.favorite : Icons.favorite_border,
                      color: isWishlist ? Colors.red : Colors.grey,
                    ),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    product['productName'] ?? 'N/A',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Rs. ${product['price'] ?? 'N/A'}',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.black,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    product['description'] ?? 'No description',
                    style: TextStyle(fontSize: 12, color: Colors.black),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: 8),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () => _callPhone(product['contactInfo']),
                        icon: Icon(Icons.call),
                        label: Text('Call'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color.fromARGB(255, 244, 241, 241),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _callPhone(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      } else {
        print('Could not launch $phoneUri');
      }
    } else {
      print('Phone number is not available.');
    }
  }

void _showSearchDialog(BuildContext context) {
  final TextEditingController _searchController = TextEditingController();

  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Search'),
        content: TextField(
          controller: _searchController,
          decoration: InputDecoration(
            hintText: 'Enter product name...',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final String query = _searchController.text.trim();
              if (query.isNotEmpty) {
                // Search in the featuredProducts list
                final Map<String, dynamic>? foundProduct = featuredProducts.cast<Map<String, dynamic>?>().firstWhere(
                  (product) => product!['productName']
                      .toLowerCase()
                      .contains(query.toLowerCase()),
                  orElse: () => null, // Properly return null
                );

                if (foundProduct != null) {
                  // If product is found, show its details
                  _showProductDetails(context, foundProduct);
                } else {
                  // If product is not found, show a message
                  _showNoProductFound(context);
                }
              } else {
                // If search query is empty, show an error
                _showError(context, 'Please enter a product name to search.');
              }
            },
            child: Text('Search'),
          ),
        ],
      );
    },
  );
}


void _showProductDetails(BuildContext context, Map<String, dynamic> product) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Product Found'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (product['imageUrl'] != null)
                Image.network(
                  product['imageUrl'],
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              SizedBox(height: 10),
              Text('Product Name: ${product['productName']}'),
              Text('Category: ${product['category']}'),
              Text('Condition: ${product['condition']}'),
              Text('Description: ${product['description']}'),
              Text('Price: ₹${product['price']}'),
              Text('Location: ${product['location']}'),
              Text('Contact Info: ${product['contactInfo']}'),
              Text('Status: ${product['status']}'),
              Text('Posted on: ${product['timestamp']?.toDate().toString()}'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showNoProductFound(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('No Product Found'),
        content: Text('No such product exists.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Close'),
          ),
        ],
      );
    },
  );
}

void _showError(BuildContext context, String message) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('OK'),
          ),
        ],
      );
    },
  );
}
  Widget _buildCategoryCard(String title, String imagePath, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 120,
        margin: EdgeInsets.symmetric(horizontal: 8.0),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.3),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: 60,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8.0),
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 8),
            Text(
              title,
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}

// New Page for Displaying Category Products
class CategoryProductsPage extends StatelessWidget {
  final String category;

  CategoryProductsPage({required this.category});

  void _callPhone(String? phoneNumber) async {
    if (phoneNumber != null && phoneNumber.isNotEmpty) {
      final Uri phoneUri = Uri(scheme: 'tel', path: phoneNumber);
      if (await canLaunchUrl(phoneUri)) {
        await launchUrl(phoneUri);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          category,
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black87),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('sell')
            .where('status', isEqualTo: 'Approved')
            .where('category', isEqualTo: category)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inventory_2_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No products found in this category',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            );
          }

          var products = snapshot.data!.docs
              .map((doc) => doc.data() as Map<String, dynamic>)
              .toList();

          return CustomScrollView(
            slivers: [
              SliverPadding(
                padding: EdgeInsets.all(16),
                sliver: SliverGrid(
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    childAspectRatio: 0.68, // Adjusted aspect ratio
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      var product = products[index];
                      return GestureDetector(
                        onTap: () {
                          showModalBottomSheet(
                            context: context,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.vertical(
                                top: Radius.circular(20),
                              ),
                            ),
                            builder: (context) => ProductDetailsBottomSheet(
                              product: product,
                              onCallPressed: () => _callPhone(product['contactInfo']),
                            ),
                          );
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 4, // Adjusted flex value
                                child: ClipRRect(
                                  borderRadius: BorderRadius.vertical(
                                    top: Radius.circular(12),
                                  ),
                                  child: Image.network(
                                    product['imageUrl'] ?? 'images/placeholder.jpg',
                                    width: double.infinity,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                              Expanded(
                                flex: 3, // Adjusted flex value
                                child: Padding(
                                  padding: EdgeInsets.all(8), // Reduced padding
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min, // Added this
                                    children: [
                                      Text(
                                        product['productName'] ?? 'N/A',
                                        style: TextStyle(
                                          fontSize: 14, // Reduced font size
                                          fontWeight: FontWeight.bold,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      SizedBox(height: 2), // Reduced spacing
                                      Text(
                                        'Rs. ${product['price'] ?? 'N/A'}',
                                        style: TextStyle(
                                          fontSize: 13, // Reduced font size
                                          color: const Color.fromARGB(255, 199, 40, 40),
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      SizedBox(height: 4), // Reduced spacing
                                      Text(
                                        product['description'] ?? 'No description',
                                        style: TextStyle(
                                          fontSize: 11, // Reduced font size
                                          color: Colors.grey[600],
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                    childCount: products.length,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

class ProductDetailsBottomSheet extends StatelessWidget {
  final Map<String, dynamic> product;
  final VoidCallback onCallPressed;

  const ProductDetailsBottomSheet({
    required this.product,
    required this.onCallPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.network(
                  product['imageUrl'] ?? 'images/placeholder.jpg',
                  height: 120,
                  width: 120,
                  fit: BoxFit.cover,
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product['productName'] ?? 'N/A',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Rs. ${product['price'] ?? 'N/A'}',
                      style: TextStyle(
                        fontSize: 18,
                        color: const Color.fromARGB(255, 199, 40, 40),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          SizedBox(height: 20),
          Text(
            'Description',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 8),
          Text(
            product['description'] ?? 'No description',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          SizedBox(height: 16),
          Row(
            children: [
              InfoChip(
                icon: Icons.inventory_2_outlined,
                label: 'Condition: ${product['condition'] ?? 'N/A'}',
              ),
              SizedBox(width: 8),
              InfoChip(
                icon: Icons.location_on_outlined,
                label: 'Location: ${product['location'] ?? 'N/A'}',
              ),
            ],
          ),
          SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onCallPressed,
              icon: Icon(Icons.call),
              label: Text('Contact Seller'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color.fromARGB(255, 199, 40, 40),
                padding: EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const InfoChip({
    required this.icon,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: Colors.grey[600]),
          SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}