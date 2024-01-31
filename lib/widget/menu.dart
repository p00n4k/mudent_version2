import 'package:flutter/material.dart';

class Menu extends StatelessWidget {
  final String path;
  final String title;
  final callback; // Add callback function

  const Menu({required this.path, required this.title, this.callback});

  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => callback!(), // Call the callback function
          ),
        );
      },
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
        ),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius:
                  BorderRadius.circular(20), // Adjust the radius as needed
              child: Image.asset(
                path,
              ),
            ),
            Center(
              child: Container(
                width: 100,
                color: Colors.grey[850],
                child: Text(
                  title,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
