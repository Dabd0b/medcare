import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:medcare/your_heart/condition.dart';
import 'dart:convert';
import 'package:medcare/your_heart/final_condition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PredictionForm extends StatefulWidget {
  @override
  _PredictionFormState createState() => _PredictionFormState();
}

class _PredictionFormState extends State<PredictionForm> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for the 13 inputs
   // Create controllers for text fields
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _numberOfVesselsController = TextEditingController();
  final TextEditingController _restingBPController = TextEditingController();
  final TextEditingController _serumCholesterolController = TextEditingController();
  final TextEditingController _maxHeartRateController = TextEditingController();
  final TextEditingController _stDepressionController = TextEditingController();

  // Create dropdown controllers
  String _gender = '0'; // Male = 0, Female = 1
  String _chestPainType = '0'; // Typical Angina = 0, Atypical Angina = 1, etc.
  String _fastingBloodSugar = '0'; // Above 120 = 1, Below 120 = 0
  String _restingECG = '0'; // Normal = 0, Abnormal = 1
  String _exerciseInducedAngina = '0'; // Yes = 1, No = 0
  String _slope = '0'; // Upsloping = 0, Flat = 1, Downsloping = 2
  String _thaliumStressTest = '0'; // Normal = 0, Fixed defect = 1, etc.

  // ignore: unused_field
  String? _predictionResult;
  bool _isLoading = false;



Future<void> _submitForm() async {
  if (!_formKey.currentState!.validate()) return;

  // Prepare the features array from individual input controllers
  final features = [
    int.tryParse(_ageController.text) ?? 0,                           
    int.tryParse(_gender) ?? 0,                     
    int.tryParse(_chestPainType) ?? 0,                 
    int.tryParse(_restingBPController.text) ?? 0,                     
    int.tryParse(_serumCholesterolController.text) ?? 0,              
    int.tryParse(_fastingBloodSugar) ?? 0,       
    int.tryParse(_restingECG) ?? 0,                     
    int.tryParse(_maxHeartRateController.text) ?? 0,                   
    int.tryParse(_exerciseInducedAngina) ?? 0,                  
    double.tryParse(_stDepressionController.text) ?? 0,                   
    int.tryParse(_slope) ?? 0,                         
    int.tryParse(_numberOfVesselsController.text) ?? 0,                       
    int.tryParse(_thaliumStressTest) ?? 0,                                                      
  ];

  print("$features");

  final url = Uri.parse('http://172.20.10.8:5000/predict'); // Update to your Flask API URL

  try {
    setState(() {
      _isLoading = true;
      _predictionResult = null;
    });

    // Send POST request to Flask API
    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'features': features}),
    );

    if (response.statusCode == 200) {
      final result = jsonDecode(response.body);
      final prediction = result['prediction'];

      // Get current user's ID
      String userId = FirebaseAuth.instance.currentUser!.uid;
      DocumentReference userDocRef = FirebaseFirestore.instance.collection('users').doc(userId);

      // Fetch the user's record map to get the latest test
      DocumentSnapshot userDoc = await userDocRef.get();
      Map<String, dynamic> recordMap = userDoc['record'] ?? {};
      String lastTestKey = recordMap.isNotEmpty
          ? 't${recordMap.length}' // Get the last test key
          : 't1'; // Default to 't1' if no tests exist
      // If prediction is 1 (Disease Detected)
      print("$recordMap");
      print("$lastTestKey");
      print("$prediction");
      if (prediction == 1) {
  // Fetch existing risk score from Firestore
  double existingRiskScore = userDoc['record'][lastTestKey]['riskScore'] ?? 0.0;
  double newRiskScore = (existingRiskScore + 91) / 200 * 100;

  // Update the Firebase record with "Unhealthy" status
  await userDocRef.update({
    'record.$lastTestKey.status': 'complete',  // Set status to 'Unhealthy'
    'record.$lastTestKey.riskScore': newRiskScore,
    'healthStatus': 'UnHealthy',  // Update health status to 'Unhealthy'
  });

  // Navigate to the FinalConditionPage with a risk score of 91
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => FinalConditionPage(),
    ),
  );
} else {
  // Update Firebase status and risk score to Healthy and 10
  await userDocRef.update({
    'record.$lastTestKey.status': 'complete',  // Set status to 'Healthy'
    'record.$lastTestKey.riskScore': 10.0,
    'record.$lastTestKey.condition': 'Healthy',
    'healthStatus': 'Healthy',  // Update health status to 'Healthy'
  });

  // If prediction is 0 (No Disease Detected), navigate to ConditionPage
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => ConditionPage(riskScore: 10, condition: 'Healthy',), // Navigate to ConditionPage with a risk score of 10
    ),
  );
}

} else {
      setState(() {
        _predictionResult = 'Error: ${response.body}';
      });
    }
  } catch (e) {
    setState(() {
      _predictionResult = 'Error: $e';
    });
  } finally {
    setState(() {
      _isLoading = false;
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF5D56AF),
        title: Text('MEDCARE-AI-Test', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 16),
                // 1. Age
                TextFormField(
                  controller: _ageController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Age',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 2. Gender (Dropdown)
                DropdownButtonFormField<String>(
                  value: _gender,
                  onChanged: (value) {
                    setState(() {
                      _gender = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Male')),
                    DropdownMenuItem(value: '1', child: Text('Female')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Gender',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 3. Chest Pain Type (Dropdown)
                DropdownButtonFormField<String>(
                  value: _chestPainType,
                  onChanged: (value) {
                    setState(() {
                      _chestPainType = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Typical Angina')),
                    DropdownMenuItem(value: '1', child: Text('Atypical Angina')),
                    DropdownMenuItem(value: '2', child: Text('Non-anginal Pain')),
                    DropdownMenuItem(value: '3', child: Text('Asymptomatic')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Chest Pain Type',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 4. Resting Blood Pressure
                TextFormField(
                  controller: _restingBPController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Resting BP (mm Hg)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 5. Serum Cholesterol (mg/dl)
                TextFormField(
                  controller: _serumCholesterolController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Serum Cholesterol (mg/dl)',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 6. Fasting Blood Sugar (Dropdown)
                DropdownButtonFormField<String>(
                  value: _fastingBloodSugar,
                  onChanged: (value) {
                    setState(() {
                      _fastingBloodSugar = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Below 120 mg/dl')),
                    DropdownMenuItem(value: '1', child: Text('Above 120 mg/dl')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Fasting Blood Sugar',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 7. Resting Electrocardiographic (Dropdown)
                DropdownButtonFormField<String>(
                  value: _restingECG,
                  onChanged: (value) {
                    setState(() {
                      _restingECG = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Normal')),
                    DropdownMenuItem(value: '1', child: Text('ST-T Wave Abnormality')),
                    DropdownMenuItem(value: '2', child: Text('Left Ventricular Hypertrophy')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Resting ECG',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 8. Max Heart Rate Achieved
                TextFormField(
                  controller: _maxHeartRateController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Max Heart Rate Achieved',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 9. Exercise-induced Angina (Dropdown)
                DropdownButtonFormField<String>(
                  value: _exerciseInducedAngina,
                  onChanged: (value) {
                    setState(() {
                      _exerciseInducedAngina = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('No')),
                    DropdownMenuItem(value: '1', child: Text('Yes')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Exercise-induced Angina',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 10. ST Depression
                TextFormField(
                  controller: _stDepressionController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'ST Depression',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 11. Slope of Peak Exercise ST Segment (Dropdown)
                DropdownButtonFormField<String>(
                  value: _slope,
                  onChanged: (value) {
                    setState(() {
                      _slope = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Upsloping')),
                    DropdownMenuItem(value: '1', child: Text('Flat')),
                    DropdownMenuItem(value: '2', child: Text('Downsloping')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Slope of Peak Exercise ST Segment',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),

                // 12. Number of Major Vessels Colored by Fluoroscopy
                TextFormField(
                  controller: _numberOfVesselsController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Number of Major Vessels Colored by Fluoroscopy',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a value';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),

                // 13. Thalium Stress Test (Dropdown)
                DropdownButtonFormField<String>(
                  value: _thaliumStressTest,
                  onChanged: (value) {
                    setState(() {
                      _thaliumStressTest = value!;
                    });
                  },
                  items: [
                    DropdownMenuItem(value: '0', child: Text('Normal')),
                    DropdownMenuItem(value: '1', child: Text('Fixed Defect')),
                    DropdownMenuItem(value: '2', child: Text('Reversible Defect')),
                    DropdownMenuItem(value: '3', child: Text('Not Described')),
                  ],
                  decoration: InputDecoration(
                    labelText: 'Thalium Stress Test',
                    border: OutlineInputBorder(),
                  ),
                ),
                SizedBox(height: 16),
                // Submit Button
                _isLoading
                    ? CircularProgressIndicator()
                    : ElevatedButton(
                        onPressed: _submitForm,
                        child: Text('Submit',style:TextStyle(fontSize: 16, fontWeight: FontWeight.bold) ,),
                        style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.tealAccent,
                        foregroundColor: Color(0xFF5D56AF),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                ),
              ),
                      ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
