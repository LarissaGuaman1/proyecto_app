import 'package:flutter/material.dart';

class ProductCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback? onTap;
  final double width;
  final double height;

  ProductCard({
    required this.title,
    required this.icon,
    this.onTap,
    this.width = 100,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        color: Colors.purple[50],
        elevation: 4,
        child: Container(
          width: width,
          height: height,
          padding: EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: width / 2, color: Colors.purple[300]),
              SizedBox(height: 8),
              Text(
                title,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.purple[800],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
