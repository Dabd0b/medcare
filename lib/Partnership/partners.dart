import 'package:flutter/material.dart';

class PartnersPage extends StatelessWidget {
   @override
  Widget build(BuildContext context) {
    final categories = [
      {"name": "Hospitals", "image": "assets/images/Rectangle 22.png", "route": "/hospitals"},
      {"name": "Doctors", "image": "assets/images/image 2.png", "route": "/doctors"},
      {"name": "Clinics", "image": "assets/images/Rectangle 23.png", "route": "/clinics"},
      {"name": "Labs and Imaging centers", "image": "assets/images/Rectangle 27.png", "route": "/xray"},
      {"name": "Pharmacies", "image": "assets/images/Rectangle 28.png", "route": "/pharmacies"},
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text("Partners" ,style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        backgroundColor: Color(0xFF5D56AF),  // Keep transparent AppBar if you want it
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"), // Your background image
            fit: BoxFit.fill,  // Ensure it covers the screen
          ),
        ),
        child: GridView.builder(
          padding: EdgeInsets.all(16.0),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.8,
          ),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final category = categories[index];
            return GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, category["route"]!);
              },
              child: Column(
                children: [
                  Image.asset(category["image"]!, width: 150, height: 150),
                  SizedBox(height: 8),
                  Text(
                    category["name"]!,
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
