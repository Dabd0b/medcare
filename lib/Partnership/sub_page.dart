import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:medcare/Partnership/details_page.dart';

class SubPage extends StatefulWidget {
  final String category;

  SubPage({required this.category});

  @override
  _SubPageState createState() => _SubPageState();
}

class _SubPageState extends State<SubPage> {
  String searchQuery = ""; // To hold the current search query

  @override
  Widget build(BuildContext context) {
    final CollectionReference collection =
        FirebaseFirestore.instance.collection(widget.category);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.category, style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold,)),
        backgroundColor: Color(0xFF5D56AF), // Add AppBar color if desired
      ),
      body: Container(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                decoration: InputDecoration(
                  labelText: "Search Here",
                  labelStyle: TextStyle(color: Colors.black),
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value.trim().toLowerCase(); // Update the search query
                  });
                },
              ),
            ),
            Expanded(
              child: StreamBuilder(
                stream: collection.snapshots(),
                builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Center(child: CircularProgressIndicator());
                  }
                  if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                    return Center(child: Text("No items found"));
                  }

                  // Filter the items based on the search query
                  final filteredItems = snapshot.data!.docs.where((doc) {
                    final data = doc.data() as Map<String, dynamic>;
                    final name = data["name"]?.toString().toLowerCase() ?? "";
                    return name.contains(searchQuery);
                  }).toList();

                  if (filteredItems.isEmpty) {
                    return Center(child: Text("No items match your search."));
                  }

                  return ListView.builder(
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      final item = filteredItems[index].data() as Map<String, dynamic>;
                      
                      // Safely convert rating to double if it's a string
                      double rating = 0.0;
                      try {
                        rating = double.tryParse(item["rating"]?.toString() ?? '') ?? 0.0;
                      } catch (e) {
                        rating = 0.0;  // Default to 0 if parsing fails
                      }

                      // Determine the number of full stars and the half star
                      int fullStars = rating.floor();
                      bool hasHalfStar = (rating - fullStars) >= 0.2 && (rating - fullStars) <= 0.8;
                      // ignore: unused_local_variable
                      int totalStars = fullStars;

                      if (rating > 4.8) {
                        totalStars = 5;
                      } else if (rating < 0.2) {
                        totalStars = 0;
                      }

                      // Get the services array
                      List<String> services = List<String>.from(item["services"] ?? []);

                      return Card(
                        
                        margin: EdgeInsets.all(8.0),
                        color: Color(0xFF5D56AF),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 4,
                        child: Container(
                          padding: EdgeInsets.all(12.0),
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.tealAccent, width: 2),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            contentPadding: EdgeInsets.all(0),
                            leading: Container(
                                     width: 100,  // Set width of the image
                                     height: 100, // Set height of the image
                                     child: Image.network(
                                     item["image"] ?? "", 
                                     fit: BoxFit.fill,  // Ensures the image covers the space proportionally
                                  ),
                                ), // Bigger image size
                              title: Text(
                              item["name"] ?? "Unknown",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [ 
                                // Show services list under the name
                                if (services.isNotEmpty)
                                  Column(
                                    children: services.map((service) {
                                      return Text(
                                        service,
                                        style: TextStyle(color: Colors.white),
                                      );
                                    }).toList(),
                                  ),
                                 Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                  children: List.generate(5, (index) {
                                    // Logic for full stars
                                    if (index < fullStars) {
                                      return Icon(
                                        Icons.star,
                                        color: Colors.yellow,
                                        size: 16,
                                      );
                                    }
                                    // Logic for half star
                                    if (index == fullStars && hasHalfStar) {
                                      return Icon(
                                        Icons.star_half,
                                        color: Colors.yellow,
                                        size: 16,
                                      );
                                    }
                                    // Logic for empty stars
                                    return Icon(
                                      Icons.star_border,
                                      color: Colors.yellow,
                                      size: 16,
                                    );
                                  }),
                                ),
                                
                              ],
                            ),
                           
                          
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => DetailsPage(item: item),
                                ),
                              );
                            },
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
