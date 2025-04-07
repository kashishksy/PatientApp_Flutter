import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'dart:convert';

// Patient dashboard screen widget for testing
class TestDashboardScreen extends StatelessWidget {
  final String username;
  final String designation;
  final List<Map<String, dynamic>> patients;

  const TestDashboardScreen({
    super.key,
    required this.username,
    required this.designation,
    required this.patients,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Text(
                    'Welcome $username',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              Text(
                designation,
                style: const TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 20),

              // Patient List
              Expanded(
                child: ListView.builder(
                  itemCount: patients.length,
                  itemBuilder: (context, index) {
                    final patient = patients[index];
                    return GestureDetector(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/patientDetails',
                          arguments: {'patient': patient},
                        );
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              patient['name'],
                              style: const TextStyle(fontSize: 18),
                            ),
                            Text(
                              patient['status'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: patient['status'] == 'Stable'
                                    ? Colors.green
                                    : Colors.red,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Patient details screen widget for testing
class TestPatientDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const TestPatientDetailsScreen({super.key, required this.patient});

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
            const SizedBox(height: 20),
            Text(
              'Name: ${patient['name']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'ID: ${patient['_id']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              'Department: ${patient['department']}',
              style: const TextStyle(fontSize: 18),
            ),
            const SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/viewMedicalRecords', 
                    arguments: {'patient': patient}
                  );
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
            const SizedBox(height: 10),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/editPatient', 
                    arguments: {'patient': patient}
                  );
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

// Medical records screen widget for testing
class TestMedicalRecordsScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const TestMedicalRecordsScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records for ${patient['name']}'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text('Medical Records Content'),
        ),
      ),
    );
  }
}

// Edit patient screen widget for testing
class TestEditPatientScreen extends StatelessWidget {
  final Map<String, dynamic> patient;

  const TestEditPatientScreen({super.key, required this.patient});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Patient'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(20.0),
        child: Center(
          child: Text('Edit Patient Screen Content'),
        ),
      ),
    );
  }
}

// Test app that handles routing
class TestPatientApp extends StatelessWidget {
  final List<Map<String, dynamic>> patients;
  
  const TestPatientApp({super.key, required this.patients});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Management Test App',
      home: TestDashboardScreen(
        username: 'Test User',
        designation: 'Doctor',
        patients: patients,
      ),
      routes: {
        '/patientDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TestPatientDetailsScreen(patient: args['patient']);
        },
        '/editPatient': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TestEditPatientScreen(patient: args['patient']);
        },
        '/viewMedicalRecords': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return TestMedicalRecordsScreen(patient: args['patient']);
        },
      },
    );
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Patient Management Flow Test', () {
    final testPatients = [
      {
        '_id': '1',
        'name': 'Test Patient',
        'status': 'Stable',
        'department': 'General',
        'gender': 'Male',
        'dateOfAdmission': '2024-01-01',
      }
    ];

    testWidgets('Patient management flow', (WidgetTester tester) async {
      // Start with our test app (skipping login)
      await tester.pumpWidget(TestPatientApp(patients: testPatients));

      // Verify we're on the dashboard
      expect(find.text('Welcome Test User'), findsOneWidget);

      // Verify patient list is loaded
      expect(find.text('Test Patient'), findsOneWidget);

      // Tap on a patient
      await tester.tap(find.text('Test Patient'));
      await tester.pumpAndSettle();

      // Verify we're on patient details screen
      expect(find.text('Name: Test Patient'), findsOneWidget);

      // Tap edit button
      await tester.tap(find.text('Edit Patient Details'));
      await tester.pumpAndSettle();

      // Verify we're on edit screen
      expect(find.text('Edit Patient Screen Content'), findsOneWidget);

      // Go back to patient details
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Tap medical records button
      await tester.tap(find.text('View Medical Records'));
      await tester.pumpAndSettle();

      // Verify we're on medical records screen
      expect(find.text('Medical Records Content'), findsOneWidget);

      // Go back to patient details
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Go back to dashboard
      await tester.tap(find.byType(BackButton));
      await tester.pumpAndSettle();

      // Verify we're back on dashboard
      expect(find.text('Welcome Test User'), findsOneWidget);
    });
  });
} 