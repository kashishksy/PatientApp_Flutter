import 'package:flutter/material.dart';
import 'screens/login_screen.dart';
import 'screens/dashboard_screen.dart';
import 'screens/signup_screen.dart';
import 'screens/add_patient_screen.dart';
import 'screens/patient_details_screen.dart';
import 'screens/edit_patient_screen.dart';
import 'screens/medical_records_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Patient Management',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/',
      onGenerateRoute: (settings) {
        // Handle route generation based on route name and arguments
        switch (settings.name) {
          case '/':
            return MaterialPageRoute(builder: (_) => const LoginScreen());

          case '/dashboard':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => DashboardScreen(
                user: args['user'],
                designation: args['designation'],
              ),
            );

          case '/signup':
            return MaterialPageRoute(builder: (_) => const SignUpScreen());

          case '/addPatient':
            final args = settings.arguments as Map<String, dynamic>?;
            return MaterialPageRoute(
              builder: (_) => const AddPatientScreen(),
            );

          case '/patientDetails':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => PatientDetailsScreen(
                patientId: args['patientId'],
              ),
            );

          case '/editPatient':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => EditPatientScreen(
                patient: args['patient'],
              ),
            );

          case '/medicalRecords':
            final args = settings.arguments as Map<String, dynamic>;
            return MaterialPageRoute(
              builder: (_) => MedicalRecordsScreen(
                patient: args['patient'],
              ),
            );

          default:
            return MaterialPageRoute(
              builder: (_) => Scaffold(
                body: Center(
                  child: Text('No route defined for ${settings.name}'),
                ),
              ),
            );
        }
      },
    );
  }
}
