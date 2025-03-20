import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestOption {
  final String type;
  final List<String> results;

  TestOption({required this.type, required this.results});
}

class MedicalReport {
  final String type;
  final String date;
  final String result;

  MedicalReport({required this.type, required this.date, required this.result});

  Map<String, dynamic> toJson() {
    return {
      'type': type,
      'date': date,
      'result': result,
      'attachments': []
    };
  }
}

class Patient {
  final String id;
  final String name;
  final List<MedicalReport> medicalReports;

  Patient({required this.id, required this.name, required this.medicalReports});
}

class MedicalRecordsScreen extends StatefulWidget {
  final Map<String, dynamic>? patient;

  const MedicalRecordsScreen({super.key, this.patient});

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late List<MedicalReport> medicalReports;
  bool isModalVisible = false;
  late TestOption selectedTest;
  late String selectedResult;
  bool isLoading = false;

  final List<TestOption> testOptions = [
    TestOption(type: 'Blood Sugar Level', results: ['Normal', 'High', 'Low']),
    TestOption(
        type: 'Psychiatric Evaluation',
        results: ['Stable', 'Unstable', 'Needs Attention']),
    TestOption(
        type: 'Cholesterol Level', results: ['Normal', 'Borderline', 'High']),
    TestOption(type: 'ECG', results: ['Normal', 'Irregular', 'Critical']),
  ];

  @override
  void initState() {
    super.initState();
    initializeMedicalReports();
    selectedTest = testOptions[0];
    selectedResult = testOptions[0].results[0];
  }

  void initializeMedicalReports() {
    if (widget.patient != null && widget.patient!['medicalReports'] != null) {
      medicalReports = List<MedicalReport>.from(
        widget.patient!['medicalReports'].map(
          (report) => MedicalReport(
            type: report['type'],
            date: report['date'],
            result: report['result'],
          ),
        ),
      );
    } else {
      medicalReports = [];
    }
  }

  String calculateCondition() {
    if (medicalReports.isEmpty) return 'No Records';
    
    // Get the latest medical report
    final latestReport = medicalReports.last;
    final type = latestReport.type;
    final result = latestReport.result;

    switch (type) {
      case 'Blood Sugar Level':
        return result == 'High' ? 'Critical' : result == 'Low' ? 'Medium' : 'Stable';
      case 'Psychiatric Evaluation':
        return result == 'Unstable' ? 'Critical' : result == 'Needs Attention' ? 'Medium' : 'Stable';
      case 'Cholesterol Level':
        return result == 'High' ? 'Critical' : result == 'Borderline' ? 'Medium' : 'Stable';
      case 'ECG':
        return result == 'Critical' ? 'Critical' : result == 'Irregular' ? 'Medium' : 'Stable';
      default:
        return 'Stable';
    }
  }

  Color getConditionColor(String condition) {
    switch (condition) {
      case 'Critical':
        return Colors.red;
      case 'Medium':
        return Colors.amber;
      case 'Stable':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  Future<void> handleAddRecord() async {
    setState(() {
      isLoading = true;
    });

    try {
      final newReport = MedicalReport(
        type: selectedTest.type,
        date: DateTime.now().toString().split(' ')[0],
        result: selectedResult,
      );

      // Add to local state first
      setState(() {
        medicalReports.add(newReport);
      });

      // Calculate new status based on the latest record
      final newStatus = calculateCondition();

      // Prepare the updated patient data
      final updatedPatient = Map<String, dynamic>.from(widget.patient!);
      
      // Update medical reports in the patient data
      final List<Map<String, dynamic>> updatedReports = medicalReports.map((report) => {
        'type': report.type,
        'date': report.date,
        'result': report.result,
        'attachments': []
      }).toList();
      
      // Update both medical reports and status
      final Map<String, dynamic> updateData = {
        'medicalReports': updatedReports,
        'status': newStatus,
        'name': updatedPatient['name'],
        'department': updatedPatient['department'],
        'gender': updatedPatient['gender'],
        'dateOfAdmission': updatedPatient['dateOfAdmission'],
        'dateOfDischarge': updatedPatient['dateOfDischarge'],
      };

      print('Updating patient with data: ${json.encode(updateData)}'); // Debug print

      // Make API call to update
      final response = await http.put(
        Uri.parse('https://patientdbrepo.onrender.com/api/patient/update/${widget.patient!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      print('API Response: ${response.body}'); // Debug print

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Error response: ${response.body}'); // For debugging
        throw Exception('Failed to update medical records: ${response.statusCode}');
      }

      // Update the local patient data with new status
      widget.patient!['status'] = newStatus;
      widget.patient!['medicalReports'] = updatedReports;

      setState(() {
        isModalVisible = false;
      });

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Medical record added and patient status updated'),
          backgroundColor: Colors.green,
        ),
      );

      // Pop back to patient details with refresh signal
      Navigator.pop(context, true);

    } catch (error) {
      print('Error details: $error'); // For debugging
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error adding medical record: $error'),
          backgroundColor: Colors.red,
        ),
      );
      // Rollback the local state change
      setState(() {
        medicalReports.removeLast();
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Widget _buildRecordCard(MedicalReport report) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              report.type,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 5),
            Text('Date: ${report.date}'),
            Text('Result: ${report.result}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final condition = calculateCondition();
    
    return Scaffold(
      appBar: AppBar(
        title: Text('Medical Records for ${widget.patient?['name'] ?? 'Unknown Patient'}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Pop with true to indicate data was changed and dashboard should refresh
            Navigator.pop(context, true);
          },
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              decoration: BoxDecoration(
                color: getConditionColor(condition).withOpacity(0.1),
                border: Border.all(color: getConditionColor(condition)),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.medical_information,
                    color: getConditionColor(condition),
                  ),
                  SizedBox(width: 10),
                  Text(
                    'Overall Condition: $condition',
                    style: TextStyle(
                      fontSize: 18,
                      color: getConditionColor(condition),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: medicalReports.length,
                itemBuilder: (context, index) =>
                    _buildRecordCard(medicalReports[index]),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.green,
        onPressed: () => setState(() => isModalVisible = true),
        child: const Icon(Icons.add),
      ),
      // Modal dialog
      bottomSheet: isModalVisible
          ? Container(
              color: Colors.black54,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Add Medical Record',
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const Text('Test Type', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedTest.type,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedTest = testOptions
                                .firstWhere((test) => test.type == value);
                            selectedResult = selectedTest.results[0];
                          });
                        }
                      },
                      items: testOptions.map((test) {
                        return DropdownMenuItem<String>(
                          value: test.type,
                          child: Text(test.type),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 10),
                    const Text('Result', style: TextStyle(fontSize: 16)),
                    DropdownButton<String>(
                      isExpanded: true,
                      value: selectedResult,
                      onChanged: (value) {
                        if (value != null) {
                          setState(() {
                            selectedResult = value;
                          });
                        }
                      },
                      items: selectedTest.results.map((result) {
                        return DropdownMenuItem<String>(
                          value: result,
                          child: Text(result),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        ElevatedButton(
                          onPressed: isLoading ? null : handleAddRecord,
                          child: isLoading
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Add Record'),
                        ),
                        TextButton(
                          onPressed: () =>
                              setState(() => isModalVisible = false),
                          child: const Text('Cancel'),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            )
          : null,
    );
  }
}
