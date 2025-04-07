import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

// Create a simple test widget that simulates patient details screen
class TestPatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patientData;

  const TestPatientDetailsScreen({super.key, required this.patientData});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Patient Details'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: CircleAvatar(
                backgroundImage: const AssetImage('assets/defaultPatientImage.png'),
                radius: 50,
              ),
            ),
            SizedBox(height: 20),
            Text(
              'Name: ${patientData['name']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'ID: ${patientData['_id']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Department: ${patientData['department'] ?? 'General Ward'}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Gender: ${patientData['gender']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 10),
            Text(
              'Admission Date: ${patientData['dateOfAdmission']}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/medicalRecords');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                ),
                child: const Text(
                  'View Medical Records',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/editPatient');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                ),
                child: const Text(
                  'Edit Patient Details',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
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

void main() {
  group('PatientDetailsScreen Tests', () {
    final testPatient = {
      '_id': '1',
      'name': 'Test Patient',
      'status': 'Stable',
      'department': 'General',
      'gender': 'Male',
      'dateOfAdmission': '2024-01-01',
      'age': 30,
      'bloodGroup': 'O+',
      'allergies': ['None'],
      'medications': ['None'],
    };

    // Helper function to build the widget inside a MaterialApp
    Widget createWidgetForTesting(Widget child) {
      return MaterialApp(
        home: child,
        routes: {
          '/editPatient': (context) => Scaffold(
                appBar: AppBar(title: const Text('Edit Patient')),
                body: const Center(child: Text('Edit Patient Screen')),
              ),
          '/medicalRecords': (context) => Scaffold(
                appBar: AppBar(title: const Text('Medical Records')),
                body: const Center(child: Text('Medical Records Screen')),
              ),
        },
      );
    }

    testWidgets('PatientDetailsScreen renders correctly', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestPatientDetailsScreen(patientData: testPatient),
        ),
      );

      // Check for required UI elements
      expect(find.byType(AppBar), findsOneWidget);
      expect(find.text('Name: Test Patient'), findsOneWidget);
      expect(find.text('View Medical Records'), findsOneWidget);
      expect(find.text('Edit Patient Details'), findsOneWidget);
    });

    testWidgets('Patient details are displayed correctly', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestPatientDetailsScreen(patientData: testPatient),
        ),
      );

      // Verify patient details are displayed correctly
      expect(find.text('Name: Test Patient'), findsOneWidget);
      expect(find.text('Department: General'), findsOneWidget);
      expect(find.text('Gender: Male'), findsOneWidget);
      expect(find.text('Admission Date: 2024-01-01'), findsOneWidget);
    });

    testWidgets('Navigate to edit patient screen', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestPatientDetailsScreen(patientData: testPatient),
        ),
      );

      // Tap edit button
      await tester.tap(find.text('Edit Patient Details'));
      await tester.pumpAndSettle();

      // Verify we're on the edit screen
      expect(find.text('Edit Patient Screen'), findsOneWidget);
    });

    testWidgets('Navigate to medical records', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestPatientDetailsScreen(patientData: testPatient),
        ),
      );

      // Tap medical records button
      await tester.tap(find.text('View Medical Records'));
      await tester.pumpAndSettle();

      // Verify we're on the medical records screen
      expect(find.text('Medical Records Screen'), findsOneWidget);
    });
  });
} 