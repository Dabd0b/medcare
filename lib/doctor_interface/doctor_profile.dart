import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class DoctorProfilePage extends StatefulWidget {
  final String doctorId;

  DoctorProfilePage({required this.doctorId});

  @override
  _DoctorProfilePageState createState() => _DoctorProfilePageState();
}

class _DoctorProfilePageState extends State<DoctorProfilePage> {
  final _formKey = GlobalKey<FormState>();

  TextEditingController _nameController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _contactController = TextEditingController();
  TextEditingController _emailController = TextEditingController();
  TextEditingController _locationController = TextEditingController();
  TextEditingController _ratingController = TextEditingController();
  TextEditingController _servicesController = TextEditingController();
  TextEditingController _timingSaturdayController = TextEditingController();
  TextEditingController _timingSundayController = TextEditingController();
  TextEditingController _timingMondayController = TextEditingController();
  TextEditingController _timingTuesdayController = TextEditingController();
  TextEditingController _timingWednesdayController = TextEditingController();
  TextEditingController _timingThursdayController = TextEditingController();
  TextEditingController _timingFridayController = TextEditingController();
  TextEditingController _imageController = TextEditingController();

  bool _consultation = false;

  @override
  void initState() {
    super.initState();
    _fetchDoctorProfile();
  }

  Future<void> _fetchDoctorProfile() async {
    try {
      DocumentSnapshot doctorDoc = await FirebaseFirestore.instance
          .collection('doctors')
          .doc(widget.doctorId)
          .get();

      if (doctorDoc.exists) {
        Map<String, dynamic> data = doctorDoc.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = data['name'] ?? '';
          _descriptionController.text = data['description'] ?? '';
          _contactController.text = data['contact'] ?? '';
          _emailController.text = data['email'] ?? '';
          _locationController.text = data['location'] ?? '';
          _ratingController.text = data['rating'] ?? '';
          _consultation = data['consultation'] ?? false;
          _imageController.text = data['image'] ?? '';
          _servicesController.text =
              (data['services'] as List<dynamic>?)?.join(', ') ?? '';
          _timingSaturdayController.text =
              (data['timings']?['Saturday'] ?? '') as String;
          _timingSundayController.text =
              (data['timings']?['Sunday'] ?? '') as String;
          _timingMondayController.text =
              (data['timings']?['Monday'] ?? '') as String;
          _timingTuesdayController.text =
              (data['timings']?['Tuesday'] ?? '') as String;
          _timingWednesdayController.text =
              (data['timings']?['Wednesday'] ?? '') as String;
          _timingThursdayController.text =
              (data['timings']?['Thursday'] ?? '') as String;
          _timingFridayController.text =
              (data['timings']?['Friday'] ?? '') as String;    
        });
      }
    } catch (e) {
      print("Error fetching doctor profile: $e");
    }
  }

  Future<void> _updateDoctorProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        await FirebaseFirestore.instance
            .collection('doctors')
            .doc(widget.doctorId)
            .set({
          'name': _nameController.text.trim(),
          'description': _descriptionController.text.trim(),
          'contact': _contactController.text.trim(),
          'email': _emailController.text.trim(),
          'location': _locationController.text.trim(),
          'rating': _ratingController.text.trim(),
          'consultation': _consultation,
          'image': _imageController.text.trim(),
          'services': _servicesController.text.split(',').map((s) => s.trim()).toList(),
          'timings': {
            'Saturday': _timingSaturdayController.text.trim(),
            'Sunday': _timingSundayController.text.trim(),
            'Monday': _timingMondayController.text.trim(),
            'Tuesday': _timingTuesdayController.text.trim(),
            'Wednesday': _timingWednesdayController.text.trim(),
            'Thursday': _timingThursdayController.text.trim(),
            'Friday': _timingFridayController.text.trim(),
          },
        }, SetOptions(merge: true));

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
      } catch (e) {
        print("Error updating doctor profile: $e");
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5D56AF),
        title: Text("Doctor Profile",style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Name"),
                validator: (value) => value == null || value.isEmpty ? 'Please enter a name' : null,
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: "Description"),
              ),
              TextFormField(
                controller: _contactController,
                decoration: InputDecoration(labelText: "Contact"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _locationController,
                decoration: InputDecoration(labelText: "Location"),
              ),
              TextFormField(
                controller: _ratingController,
                decoration: InputDecoration(labelText: "Rating"),
              ),
              TextFormField(
                controller: _servicesController,
                decoration: InputDecoration(labelText: "Services"),
              ),
               TextFormField(
                controller: _timingSaturdayController,
                decoration: InputDecoration(labelText: "Saturday Timing"),
              ),
               TextFormField(
                controller: _timingSundayController,
                decoration: InputDecoration(labelText: "Sunday Timing"),
              ),
               TextFormField(
                controller: _timingMondayController,
                decoration: InputDecoration(labelText: "Monday Timing"),
              ),
              TextFormField(
                controller: _timingTuesdayController,
                decoration: InputDecoration(labelText: "Tuesday Timing"),
              ),
              TextFormField(
                controller: _timingWednesdayController,
                decoration: InputDecoration(labelText: "Wednesday Timing"),
              ),
               TextFormField(
                controller: _timingThursdayController,
                decoration: InputDecoration(labelText: "Thursday Timing"),
              ),
               TextFormField(
                controller: _timingFridayController,
                decoration: InputDecoration(labelText: "Friday Timing"),
              ),
              SwitchListTile(
                title: Text("Consultation Available"),
                value: _consultation,
                onChanged: (value) {
                  setState(() {
                    _consultation = value;
                  });
                },
              ),
              ElevatedButton(
                onPressed: _updateDoctorProfile,
                child: Text("Update Profile", style: TextStyle(
                          color: Colors.black,
                          fontSize: 18,
                        ),),
                style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
