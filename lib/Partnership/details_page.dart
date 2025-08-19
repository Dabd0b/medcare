import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailsPage extends StatelessWidget {
  final Map<String, dynamic> item;

  DetailsPage({required this.item});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(item["name"] ?? "Details", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),),
        backgroundColor: Color(0xFF5D56AF),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg1.png"), // Your background image
            fit: BoxFit.cover,  // Ensure it covers the screen
          ),
        ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Image Section
              Center(
                child: Image.network(
                  item["image"] ?? "",
                  width: 200,
                  height: 200,
                  fit: BoxFit.fill,
                  errorBuilder: (context, error, stackTrace) {
                    return Icon(Icons.broken_image, size: 100);
                  },
                ),
              ),
              SizedBox(height: 16),

              // Name
              Text(
                item["name"] ?? "Unknown",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),

              // Rating
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    "${item["rating"] ?? 0} Stars",
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(width: 8),
                  Icon(Icons.star, color: Colors.orange, size: 16),
                ],
              ),
              SizedBox(height: 16),

              // Description
              Text(
                item["description"] ?? " ",
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 16),
            

              // Timings Section
              if (item["timings"] != null) ...[
                Icon(Icons.schedule_outlined),
                Text(
                  "Schedule Time",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
               Container(
  decoration: BoxDecoration(
    border: Border.all(color: Colors.tealAccent, width: 2),  // Teal accent border
    borderRadius: BorderRadius.circular(12),  // Rounded corners
  ),
  padding: EdgeInsets.all(8.0),  // Padding inside the container
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.center,
    children: (item["timings"] as Map<String, dynamic>)
        .entries
        .where((entry) => entry.value.isNotEmpty)
        .map((entry) {  
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              "${entry.key}: ",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            Text(
              entry.value,
              style: TextStyle(fontSize: 16,fontWeight: FontWeight.bold),
            ),
          ],
        ),
      );
    }).toList(),
  ),
),

                SizedBox(height: 16),
              ],

              // Action Buttons
            Row(
  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  children: [
    // Image button for Location
    GestureDetector(
      onTap: () {
        final locationLink = item["location"]; // Ensure the 'locationLink' is available in the item map
        if (locationLink != null && locationLink.isNotEmpty) {
          // Open the location link
          launchUrl(Uri.parse(locationLink));
        } else {
          // Handle missing location link
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Location link not available")),
          );
        }
      },
      child: Column(
        children: [
          Image.asset(
            'assets/images/Rectangle 28 (1).png', // Replace with your location icon image path
            width: 50,
            height: 50,
          ),
          SizedBox(height: 8),
          Text("Location", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),),
        ],
      ),
    ),

    // Image button for Contact
    GestureDetector(
      onTap: () {
        final phoneNumber = item["contact"]; // Ensure the 'phone' is available in the item map
        if (phoneNumber != null && phoneNumber.isNotEmpty) {
          // Dial the phone number
          launchUrl(Uri(scheme: 'tel', path: phoneNumber));
        } else {
          // Handle missing phone number
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Phone number not available")),
          );
        }
      },
      child: Column(
        children: [
          Image.asset(
            'assets/images/Ellipse 19.png', // Replace with your phone icon image path
            width: 50,
            height: 50,
          ),
          SizedBox(height: 8),
          Text("Call", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    ),
  ],
)
            ],
          ),
        ),
      ),
      ),
    );
  }
}
