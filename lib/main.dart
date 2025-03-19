import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/patient_details_screen.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter App',
      initialRoute: '/login', // Initial route
      routes: {
        '/login': (context) => LoginScreen(),
        '/dashboard': (context) {
          // Retrieve arguments passed from the login screen
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return DashboardScreen(
            user: args['user'], // Pass the user argument
            designation: args['designation'], // Pass the designation argument
          );
        },
        '/signup': (context) => SignUpScreen(), // Added SignUpScreen to routes
        '/addPatient': (context) => AddPatientScreen(),
        '/patientDetails': (context) {
          final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
          return PatientDetailsScreen(
            patientId: args['patientId'], // Pass the patientId
          );
        },
      //  '/medicalRecords': (context) => MedicalRecordsScreen(),
       // '/editPatient': (context) => EditPatientScreen(),
      },
    );
  }
}
