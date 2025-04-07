import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:convert';

// Create a test widget that simulates dashboard
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
        title: Text('Patient Details'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {},
          ),
        ],
      ),
      backgroundColor: Colors.white,
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
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    radius: 25,
                    child: Icon(Icons.person),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                designation,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                ),
              ),
              SizedBox(height: 20),

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
                          arguments: {'patientId': patient['_id']},
                        );
                      },
                      child: Container(
                        padding: EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          border: Border(
                              bottom: BorderSide(color: Colors.grey[300]!)),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              patient['name'],
                              style: TextStyle(fontSize: 18),
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
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/addPatient');
        },
        child: Icon(Icons.add),
      ),
    );
  }
}

void main() {
  group('DashboardScreen Tests', () {
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

    Widget createWidgetForTesting(Widget child) {
      return MaterialApp(
        home: child,
        routes: {
          '/patientDetails': (context) => Scaffold(
                appBar: AppBar(title: Text('Patient Details')),
                body: Center(child: Text('Patient Details Screen')),
              ),
          '/addPatient': (context) => Scaffold(
                appBar: AppBar(title: Text('Add Patient')),
                body: Center(child: Text('Add Patient Screen')),
              ),
        },
      );
    }

    testWidgets('DashboardScreen renders correctly', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestDashboardScreen(
            username: 'Test User',
            designation: 'Doctor',
            patients: testPatients,
          ),
        ),
      );

      // Verify the dashboard components
      expect(find.text('Welcome Test User'), findsOneWidget);
      expect(find.text('Doctor'), findsOneWidget);
    });

    testWidgets('Dashboard shows patient list', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestDashboardScreen(
            username: 'Test User',
            designation: 'Doctor',
            patients: testPatients,
          ),
        ),
      );

      // Verify patient list is displayed
      expect(find.text('Test Patient'), findsOneWidget);
      expect(find.text('Stable'), findsOneWidget);
    });

    testWidgets('Patient tap navigates to detail screen', (WidgetTester tester) async {
      // Build our test widget
      await tester.pumpWidget(
        createWidgetForTesting(
          TestDashboardScreen(
            username: 'Test User',
            designation: 'Doctor',
            patients: testPatients,
          ),
        ),
      );

      // Tap on a patient
      await tester.tap(find.text('Test Patient'));
      await tester.pumpAndSettle();

      // Verify we're on the patient details screen
      expect(find.text('Patient Details Screen'), findsOneWidget);
    });
  });
} 