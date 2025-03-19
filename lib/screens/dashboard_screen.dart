// lib/screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class DashboardScreen extends StatefulWidget {
  final String user;
  final String designation;

  const DashboardScreen(
      {super.key, required this.user, required this.designation});

  @override
  _DashboardScreenState createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<dynamic> patients = [];
  String filter = 'All';
  bool dropdownVisible = false;
  bool loading = true;
  String error = '';
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    fetchPatients();
  }

  // Fetch patients from the API
  Future<void> fetchPatients() async {
    setState(() {
      loading = true;
    });
    try {
      final response = await http.get(
          Uri.parse('https://patientdbrepo.onrender.com/api/patient/fetch'));
      if (response.statusCode == 200) {
        setState(() {
          patients = json.decode(response.body);
          loading = false;
        });
      } else {
        throw Exception('Failed to load patients');
      }
    } catch (err) {
      setState(() {
        error = err.toString();
        loading = false;
      });
    }
  }

  // Filtered patients list (both filter and search)
  List<dynamic> get filteredPatients {
    return patients.where((patient) {
      final matchesFilter = filter == 'All' || patient['status'] == filter;
      final matchesSearch =
          patient['name'].toLowerCase().contains(searchQuery.toLowerCase());
      return matchesFilter && matchesSearch;
    }).toList();
  }

  // Handle patient press
  void handlePatientPress(dynamic patient) {
    Navigator.pushNamed(context, '/patientDetails',
        arguments: {'patientId': patient['_id']});
  }

  // Toggle dropdown visibility
  void toggleDropdown() {
    setState(() {
      dropdownVisible = !dropdownVisible;
    });
  }

  // Handle filter selection
  void handleFilterSelect(String selectedFilter) {
    setState(() {
      filter = selectedFilter;
      dropdownVisible = false;
    });
  }

  // Handle add patient navigation
  void handleAddPatient() async {
    // Wait for the result from AddPatientScreen
    final shouldRefresh = await Navigator.pushNamed(context, '/addPatient',
        arguments: {'user': widget.user, 'designation': widget.designation});

    // If returned with refresh flag, fetch patients again
    if (shouldRefresh == true) {
      fetchPatients();
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

    return Scaffold(
      appBar: AppBar(
        title: Text('Patient Details'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
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
                    'Welcome ${widget.user}',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily:
                          'FunnelDisplay', // Use FunnelDisplay for header
                    ),
                  ),
                  SizedBox(width: 10),
                  CircleAvatar(
                    backgroundImage: AssetImage(
                      widget.user == 'Divyanshoo'
                          ? 'assets/divyanshoo.jpg'
                          : 'assets/kashish.jpg',
                    ),
                    radius: 25,
                  ),
                ],
              ),
              SizedBox(height: 10),
              Text(
                widget.designation,
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.grey,
                  fontFamily:
                      'FunnelDisplay', // Use FunnelDisplay for designation
                ),
              ),
              SizedBox(height: 20),

              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search Patients',
                  hintStyle: TextStyle(
                    fontFamily:
                        'FunnelDisplay', // Use FunnelDisplay for hint text
                  ),
                  filled: true,
                  fillColor: Colors.grey[200],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(5),
                    borderSide: BorderSide.none,
                  ),
                ),
                style: TextStyle(
                  fontFamily:
                      'FunnelDisplay', // Use FunnelDisplay for input text
                ),
                onChanged: (value) {
                  setState(() {
                    searchQuery = value;
                  });
                },
              ),
              SizedBox(height: 20),

              // Filter Dropdown
              Column(
                children: [
                  GestureDetector(
                    onTap: toggleDropdown,
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Add Filters: $filter',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              fontFamily:
                                  'FunnelDisplay', // Use FunnelDisplay for dropdown text
                            ),
                          ),
                          Icon(dropdownVisible
                              ? Icons.arrow_drop_up
                              : Icons.arrow_drop_down),
                        ],
                      ),
                    ),
                  ),
                  if (dropdownVisible)
                    Column(
                      children: [
                        ListTile(
                          title: Text(
                            'Show All',
                            style: TextStyle(
                              fontFamily:
                                  'FunnelDisplay', // Use FunnelDisplay for menu items
                            ),
                          ),
                          onTap: () => handleFilterSelect('All'),
                        ),
                        ListTile(
                          title: Text(
                            'Show Critical',
                            style: TextStyle(
                              fontFamily:
                                  'FunnelDisplay', // Use FunnelDisplay for menu items
                            ),
                          ),
                          onTap: () => handleFilterSelect('Critical'),
                        ),
                        ListTile(
                          title: Text(
                            'Show Stable',
                            style: TextStyle(
                              fontFamily:
                                  'FunnelDisplay', // Use FunnelDisplay for menu items
                            ),
                          ),
                          onTap: () => handleFilterSelect('Stable'),
                        ),
                        ListTile(
                          title: Text(
                            'Show Medium',
                            style: TextStyle(
                              fontFamily:
                                  'FunnelDisplay', // Use FunnelDisplay for menu items
                            ),
                          ),
                          onTap: () => handleFilterSelect('Medium'),
                        ),
                      ],
                    ),
                ],
              ),
              SizedBox(height: 20),

              // Column Headers
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Patient Name:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontFamily:
                          'FunnelDisplay', // Use FunnelDisplay for column headers
                    ),
                  ),
                  Text(
                    'Patient Criticality:',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline,
                      fontFamily:
                          'FunnelDisplay', // Use FunnelDisplay for column headers
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),

              // Patient List
              Expanded(
                child: ListView.builder(
                  itemCount: filteredPatients.length,
                  itemBuilder: (context, index) {
                    final patient = filteredPatients[index];
                    return GestureDetector(
                      onTap: () => handlePatientPress(patient),
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
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily:
                                    'FunnelDisplay', // Use FunnelDisplay for patient names
                              ),
                            ),
                            Text(
                              patient['status'],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily:
                                    'FunnelDisplay', // Use FunnelDisplay for patient status
                                color: _getStatusColor(patient['status']),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              // Add Patient Button
              ElevatedButton(
                onPressed: handleAddPatient,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(5),
                  ),
                ),
                child: Text(
                  'Add Patient',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    fontFamily:
                        'FunnelDisplay', // Use FunnelDisplay for button text
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper function to get status color
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'stable':
        return Colors.green;
      case 'medium':
        return Colors.orange;
      default:
        return Colors.black;
    }
  }
}
