import 'package:flutter/material.dart'; 
import 'package:flutter/cupertino.dart';
import 'package:medcare/homepage.dart';

class MultiPageForm extends StatefulWidget {
  @override
  _MultiPageFormState createState() => _MultiPageFormState();
}

class _MultiPageFormState extends State<MultiPageForm> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  // Define a list of titles for the 6 pages
  final List<String> _pageTitles = [
    "Diabetes", 
    "Tonsillitis",
    "Sinusitis",
    "Blood Pressure Measurement",
    "Pulmonology (chest)",
    "ECG Measurement"
  ];

  void _nextPage() {
    if (_currentPage < 5) {
      _pageController.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      setState(() {
        _currentPage++;
      });
    }
  }

  void _finish() {
    // Navigate to PatientHomePage when the user finishes the last page
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => PatientHomePage()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5D56AF),
        elevation: 0,
        title: Text('To Be Added' , style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Container(
        height: double.infinity,
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage("assets/images/bg2.png"), // Your background image
            fit: BoxFit.fill, // Ensures the image covers the entire screen
          ),
        ),
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            setState(() {
              _currentPage = index;
            });
          },
          children: List.generate(6, (index) {
            return _buildPage(index);
          }),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.tealAccent,
        child: Icon(
          _currentPage == 5 ? Icons.check : Icons.arrow_forward,
          color: Colors.black,
        ),
        onPressed: _currentPage == 5 ? _finish : _nextPage,
      ),
    );
  }

  // Custom buildPage method
  Widget _buildPage(int index) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Image.asset(
          'assets/images/page_image${index + 1}.png', // Replace with your images
          height: 200,
          width: 200,
        ),
        SizedBox(height: 20),
        Text(
          _pageTitles[index],  // Use the title from the list
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      ],
    );
  }
}
