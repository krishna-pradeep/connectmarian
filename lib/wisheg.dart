import 'package:flutter/material.dart';

class ProductList extends StatelessWidget {
  const ProductList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          ProductCard(
            title: 'New Study Lamp',
            subtitle: 'Rs. 1200.00',
            description: 'Brand new study lamp, perfect for hostel rooms.',
            imagePath: 'images/study_lamp.jpg',
          ),
          ProductCard(
            title: 'Laptop Bag',
            subtitle: 'Rs. 800.00',
            description: 'Durable laptop bag with excellent condition.',
            imagePath: 'images/laptop_bag.jpg',
          ),
          ProductCard(
            title: 'JBL Headphones',
            subtitle: 'Rs. 3500.00',
            description: 'Noise-cancelling Bluetooth headphones.',
            imagePath: 'images/bt_headphones.jpeg',
          ),
          ProductCard(
            title: 'IPHONE Pro',
            subtitle: 'Rs. 29999.00',
            description: '6.5-inch AMOLED, Dimensity 1200 processor.',
            imagePath: 'images/electronics.jpg',
          ),
        ],
      ),
    );
  }
}

class ProductCard extends StatefulWidget {
  final String title;
  final String subtitle;
  final String description;
  final String imagePath;

  const ProductCard({
    Key? key,
    required this.title,
    required this.subtitle,
    required this.description,
    required this.imagePath,
  }) : super(key: key);

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  bool isWishlisted = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 200,
      margin: const EdgeInsets.all(8),
      child: Card(
        elevation: 4,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Image.asset(
                  widget.imagePath,
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: GestureDetector(
                    onTap: () {
                      setState(() {
                        isWishlisted = !isWishlisted;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        isWishlisted ? Icons.favorite : Icons.favorite_border,
                        color: isWishlisted ? Colors.red : Colors.grey,
                        size: 20,
                      ),
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
                    widget.title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.subtitle,
                    style: const TextStyle(
                      color: Colors.green,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.description,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}