import 'package:flutter/material.dart';
import 'package:medcare/your_heart/condition.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class MedicalTestPage extends StatefulWidget {
  @override
  _MedicalTestPageState createState() => _MedicalTestPageState();
}

class _MedicalTestPageState extends State<MedicalTestPage> {

 final Map<String, Map<String, String>> decisionTree = {
    'q1':  {'yes': 'q2', 'no': 'a14', 'con': 'CAD'},
    'q2':  {'yes': 'q3', 'no': 'a4', 'con': 'CAD'},
    'q3':  {'yes': 'q4', 'no': 'q4', 'con': 'CAD'},
    'q4':  {'yes': 'q5', 'no': 'b5', 'con': 'CAD'},
    'a4':  {'yes': 'a5', 'no': 'a5', 'con': 'HF'},
    'q5':  {'yes': 'q6', 'no': 'a10', 'con': 'CAD'},
    'a5':  {'yes': 'a6', 'no': 'a6', 'con': 'HF'},
    'b5':  {'yes': 'q10', 'no': 'q10', 'con': 'HT'},
    'q6':  {'yes': 'q7', 'no': 'q7', 'con': 'CAD'},
    'a6':  {'yes': 'q12', 'no': 'q12', 'con': 'HF'},
    'q7':  {'yes': 'q8', 'no': 'q8', 'con': 'CAD'},
    'q8':  {'yes': 'end', 'no': 'end', 'con': 'CAD'},
    'q10': {'yes': 'q18', 'no': 'q18', 'con': 'HT'},
    'a10': {'yes': 'q11', 'no': 'a11', 'con': 'HA'},
    'q11': {'yes': 'end', 'no': 'end', 'con': 'HA'},
    'a11': {'yes': 'a12', 'no': 'a12', 'con': 'HVD'},
    'q12': {'yes': 'q13', 'no': 'q13', 'con': 'HF'},
    'a12': {'yes': 'end', 'no': 'end', 'con': 'HVD'},
    'q13': {'yes': 'q14', 'no': 'q14', 'con': 'HF'},
    'q14': {'yes': 'q15', 'no': 'q15', 'con': 'HF'},
    'a14': {'yes': 'q16', 'no': 'q16', 'con': 'P'},
    'q15': {'yes': 'end', 'no': 'end', 'con': 'HF'},
    'q16': {'yes': 'q17', 'no': 'q17', 'con': 'P'},
    'q17': {'yes': 'end', 'no': 'end', 'con': 'P'},
    'q18': {'yes': 'q19', 'no': 'q19', 'con': 'HT'},
    'q19': {'yes': 'q20', 'no': 'q20', 'con': 'HT'},
    'q20': {'yes': 'q21', 'no': 'q21', 'con': 'HT'},
    'q21': {'yes': 'q22', 'no': 'q22', 'con': 'HT'},
    'q22': {'yes': 'q23', 'no': 'q23', 'con': 'HT'},
    'q23': {'yes': 'q24', 'no': 'q24', 'con': 'HT'},
    'q24': {'yes': 'end', 'no': 'end', 'con': 'HT'},
  }; 
  // List of questions
final List<String> questions = [
  "Do you suffer from Shortness of Breath?",
  "Do you experience Angina (Chest Pain)?",
  "Do you often feel Dizziness?",
  "Do you feel Weak or Fatigued?",
  "Do you experience Nausea?",
  "Do you often feel Lightheaded?",
  "Do you experience Cold Sweats?",
  "Do you have Neck Pain?",
  "silent",
  "Do you experience Flip-Flops in your Heartbeats?",
  "Do you experience a Pounding Chest?",
  "Do you have Swollen Ankles or Legs?",
  "Do you experience Coughing?",
  "Do you have an Increased Heartbeat?",
  "Do you have a Lack of Appetite?",
  "Do you feel Sharp Chest Pain that differs from Angina?",
  "Do you have a Low-Grade Fever?",
  "Do you often have Headaches?",
  "Do you feel Nauseous or Vomit frequently?",
  "Do you experience Blurred Vision?",
  "Do you often feel Anxious?",
  "Do you feel Confused sometimes?",
  "Do you hear Buzzing in your Ears?",
  "Do you experience Nosebleeds?",
];
final List<String> symptoms = [
  "Shortness of Breath",
  "Angina (Chest Pain)",
  "Dizziness",
  "Fatigued",
  "Nausea",
  "Lightheaded",
  "Cold Sweats",
  "Neck Pain",
  "",
  "Flip-Flops in your Heartbeats",
  "Pounding Chest",
  "Swollen Ankles or Legs",
  "Coughing",
  "Increased Heartbeat",
  "Lack of Appetite",
  "Sharp Chest Pain",
  "Low-Grade Fever",
  "Headaches",
  "Vomiting",
  "Blurred Vision",
  "Anxious",
  "Confusion",
  "Buzzing in Ears",
  "Nosebleed",
  "",
];

  var result = <String>[];
  

  @override
  void initState() {
    super.initState();
  }

 String currentQuestion = 'q1'; // Start from question q1

  void _handleAnswer(bool answer) {
    String ans;
    setState(() {

      if(answer){
        ans = "yes";
        result.add(symptoms[int.parse(currentQuestion.substring(1)) - 1]);
      } else{
        ans = "no";
      }

      // Transition to next question based on the answer
      if (decisionTree.containsKey(currentQuestion)) {
        String nextQuestion = decisionTree[currentQuestion]![ans]!;
        if (nextQuestion == 'end') {
          String con = decisionTree[currentQuestion]!['con']!;
          _finishTest(con);
        } else {
          currentQuestion = nextQuestion;
        }
      }
    });
  }
  

  // Finish test and show result
  void _finishTest(con) {
    print("User answers: $result");
    // Navigate to a result page or perform further actions
    double riskScore = 0;
   String condition = "";

if (con == 'CAD') {
  // Minimum length for CAD is 4
  int minLength = 4;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for CAD
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 5; // 5% per extra symptom
    condition = 'Coronary Artery Disease';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
} else if (con == 'HF') {
  // Minimum length for HF is 4
  int minLength = 4;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for HF
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 5; // 5% per extra symptom
    condition = 'Heart Failure';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
} else if (con == 'HT') {
  // Minimum length for HT is 6
  int minLength = 6;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for HT
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 3.33; // 3.33% per extra symptom
    condition = 'Hypertension';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
} else if (con == 'HA') {
  // Minimum length for HA is 4
  int minLength = 4;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for HA
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 10; // 10% per extra symptom
    condition = 'Heart Arrhythmia';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
} else if (con == 'HVD') {
  // Minimum length for HVD is 3
  int minLength = 3;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for HVD
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 6.66; // 6.66% per extra symptom
    condition = 'Heart Valve Disease';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
} else {
  // For P, minimum length is 2
  int minLength = 2;
  if (result.length >= minLength) {
    riskScore = 50; // Starting risk score for P
    int extraSymptoms = result.length - minLength;
    riskScore += extraSymptoms * 20; // 20% per extra symptom
    condition = 'Pericarditis';
  } else {
    riskScore = 10; // Set to 10% if below minimum
    condition = 'Healthy';
  }
}

print("Condition: $condition, Risk Score: $riskScore");

updateUserRecord(condition, riskScore);


   Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (context) => ConditionPage(riskScore: riskScore, condition: condition,), // Pass the riskScore
    ),
  );

  
  }



void updateUserRecord(String condition, double riskScore) async {
  try {
    User? currentUser = FirebaseAuth.instance.currentUser;
    if (currentUser != null) {
      String uid = currentUser.uid;

      // Get the current user document from Firestore
      DocumentSnapshot userDoc = await FirebaseFirestore.instance.collection('users').doc(uid).get();

      if (userDoc.exists) {
        // Get the current 'record' map from Firestore
        Map<String, dynamic> userData = userDoc.data() as Map<String, dynamic>;
        Map<String, dynamic> record = userData['record'] ?? {};

        // Calculate the next record number (t1, t2, etc.)
        String recordKey = 't${record.length + 1}';

        // Set the status as "complete" if the condition is healthy, else "incomplete"
        String status = condition == "Healthy" ? "complete" : "incomplete";

        // Create the new record data
        Map<String, dynamic> newRecord = {
          'condition': condition,
          'date': DateTime.now().toString(), // Current date and time
          'riskScore': riskScore,
          'status': status,
        };

        // Add the new record to the 'record' map
        record[recordKey] = newRecord;

        // If the condition is healthy and the test is complete, update the health status to "Healthy"
        String healthStatus = "unknown"; // Only set to Healthy if condition is healthy and test is complete
        if (condition == "Healthy" && status == "complete") {
          healthStatus = "Healthy"; // Keep current health status if not healthy or incomplete
        }

        // Update the user document in Firestore with the updated record and health status
        await FirebaseFirestore.instance.collection('users').doc(uid).update({
          'record': record, // Update 'record' as a map with the new record
          'healthStatus': healthStatus, // Update health status based on condition
        });

        // Optional: Confirmation message
        print("Record added successfully. Health status updated to $healthStatus");
      }
    }
  } catch (e) {
    print("Error updating record: $e");
  }
}

@override
Widget build(BuildContext context) {
  return Scaffold(
    backgroundColor: Colors.white,
    appBar: AppBar(
      backgroundColor: Color(0xFF5D56AF),
      title: Text("Medical Tests", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),),
      leading: IconButton(
        icon: Icon(Icons.arrow_back, color: Colors.white,),
        onPressed: () => Navigator.pop(context),
      ),
    ),
    body: Container(
      decoration: BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/images/bg2.png"), // Your background image
          fit: BoxFit.fill, // Ensures full coverage
        ),
      ),
      child: Column(
      children: [
        // Question Display with Rounded Border
        SizedBox(height: 140,),
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              color: Color(0xFF5D56AF).withOpacity(0.1), // Set a light color
              borderRadius: BorderRadius.circular(50), // Rounded corners
              border: Border.all(
                color: Color(0xFF5D56AF), // Border color
                width: 2, // Border width
              ),
            ),
            child: Text(
              questions[int.parse(currentQuestion.substring(1)) - 1],
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black, // Text color
              ),
              textAlign: TextAlign.center,
            ),
          ),
        ),

        // Answer Options with Icon Buttons
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    icon: Icon(Icons.check_circle, color: Colors.green, size: 80),
                    onPressed: () => _handleAnswer(true),
                  ),
                  SizedBox(width: 20),
                  IconButton(
                    icon: Icon(Icons.cancel, color: Colors.red, size: 80),
                    onPressed: () => _handleAnswer(false),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Continue or Finish Button
        Padding(
  padding: const EdgeInsets.all(16.0),
  child: ElevatedButton(
    onPressed: () {
  if ((int.parse(currentQuestion.substring(1)) - 1) < questions.length) {
    _handleAnswer(false); // Continue to the next question
  } else {
    String con = decisionTree[currentQuestion]!['con']!;
    _finishTest(con); // Finish the test
  }
},
    style: ElevatedButton.styleFrom(
      backgroundColor: Colors.tealAccent, // Background color
      foregroundColor: Colors.black, // Text color
      padding: EdgeInsets.symmetric(horizontal: 32, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30), // Rounded corners
      ),
    ),
    child: Text(
      decisionTree[currentQuestion]!["yes"]! == 'end'
          ? "Finish"
          : "Continue",
      style: TextStyle(fontSize: 18),
    ),
  ),
),

      ],
    ),
    ),
  );
}

}
