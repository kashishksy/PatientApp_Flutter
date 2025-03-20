// lib/screens/patient_details_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class PatientDetailsScreen extends StatefulWidget {
  final String patientId;

  const PatientDetailsScreen({super.key, required this.patientId});

  @override
  _PatientDetailsScreenState createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  Map<String, dynamic>? patient;
  bool loading = true;
  String error = '';

  @override
  void initState() {
    super.initState();
    fetchPatientDetails();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Check if we need to refresh data
    final arguments =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (arguments != null && arguments['refreshData'] == true) {
      fetchPatientDetails();
    }
  }

  // Fetch patient details from the API
  Future<void> fetchPatientDetails() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
        Uri.parse(
            'https://patientdbrepo.onrender.com/api/patient/fetch/${widget.patientId}'),
      );
      if (response.statusCode == 200) {
        setState(() {
          patient = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load patient details');
      }
    } catch (err) {
      setState(() {
        error = 'Failed to load patient details';
        loading = false;
      });
    }
  }

  // Navigate to EditPatientScreen
  void handleEditDetails() async {
    final result = await Navigator.pushNamed(context, '/editPatient',
        arguments: {'patient': patient});

    // If we got a result back (patient was edited or deleted)
    if (result == 'deleted') {
      // Go back to the dashboard if patient was deleted
      Navigator.pop(context, true); // true indicates dashboard should refresh
    } else if (result != null) {
      // Refresh patient details if patient was edited
      fetchPatientDetails();
    }
  }

  // Navigate to MedicalRecordsScreen
  void handleViewMedicalRecords() async {
    final result = await Navigator.pushNamed(
      context, 
      '/medicalRecords', 
      arguments: {'patient': patient}
    );
    
    // If we got a refresh signal (true), fetch updated patient details and pass refresh to dashboard
    if (result == true) {
      await fetchPatientDetails();
      // Pass the refresh signal back to dashboard
      Navigator.pop(context, true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return Center(
        child: CircularProgressIndicator(color: Colors.blue),
      );
    }

    if (error.isNotEmpty) {
      return Center(
        child: Text(
          'Error: $error',
          style: TextStyle(
            fontFamily: 'FunnelDisplay', // Use FunnelDisplay for error text
            fontSize: 16,
          ),
        ),
      );
    }

    if (patient == null) {
      return Center(
        child: Text(
          'No patient data available',
          style: TextStyle(
            fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
            fontSize: 16,
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Always pass refresh signal back to dashboard
            Navigator.pop(context, true);
          },
        ),
      ),
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Patient Image
            Center(
              child: CircleAvatar(
                backgroundImage: patient!['image'] != null
                    ? NetworkImage(patient!['image'])
                    : AssetImage('assets/defaultPatientImage.png')
                        as ImageProvider,
                radius: 50,
              ),
            ),
            SizedBox(height: 20),

            // Patient Details
            Text(
              'Name: ${patient!['name']}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
              ),
            ),
            SizedBox(height: 10),
            Text(
              'ID: ${patient!['_id']}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Department: ${patient!['department'] ?? 'General Ward'}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Gender: ${patient!['gender']}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
              ),
            ),
            SizedBox(height: 10),
            Text(
              'Admission Date: ${patient!['dateOfAdmission']}',
              style: TextStyle(
                fontSize: 18,
                fontFamily: 'FunnelDisplay', // Use FunnelDisplay for text
              ),
            ),
            SizedBox(height: 20),

            // View Medical Records Button
            Center(
              child: ElevatedButton(
                onPressed: handleViewMedicalRecords,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'View Medical Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FunnelDisplay', // Use FunnelDisplay for button text
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),

            // Edit Details Button
            Center(
              child: ElevatedButton(
                onPressed: handleEditDetails,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Edit Patient Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily: 'FunnelDisplay', // Use FunnelDisplay for button text
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
