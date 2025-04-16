import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class TestOption {
  final String type;
  final List<String> results;
  final bool isNumeric;
  final double? minValue;
  final double? maxValue;
  final String? unit;

  TestOption({
    required this.type,
    required this.results,
    this.isNumeric = false,
    this.minValue,
    this.maxValue,
    this.unit,
  });
}

class MedicalReport {
  final String type;
  final String date;
  final String result;

  MedicalReport({required this.type, required this.date, required this.result});

  Map<String, dynamic> toJson() {
    return {'type': type, 'date': date, 'result': result, 'attachments': []};
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
  final TextEditingController _numericValueController = TextEditingController();

  final List<TestOption> testOptions = [
    TestOption(
      type: 'Blood Sugar Level',
      results: ['Normal', 'High', 'Low'],
      isNumeric: true,
      minValue: 70,
      maxValue: 200,
      unit: 'mg/dL',
    ),
    TestOption(
      type: 'Psychiatric Evaluation',
      results: ['Stable', 'Unstable', 'Needs Attention'],
    ),
    TestOption(
      type: 'Cholesterol Level',
      results: ['Normal', 'Borderline', 'High'],
      isNumeric: true,
      minValue: 125,
      maxValue: 200,
      unit: 'mg/dL',
    ),
    TestOption(
      type: 'ECG',
      results: ['Normal', 'Irregular', 'Critical'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    initializeMedicalReports();
    selectedTest = testOptions[0];
    selectedResult = testOptions[0].results[0];
  }

  @override
  void dispose() {
    _numericValueController.dispose();
    super.dispose();
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

    // Extract the interpretation part from numeric results
    String interpretation = result;
    if (result.contains('(') && result.contains(')')) {
      // Extract interpretation from format like "120 mg/dL (Normal)"
      interpretation = result.substring(result.lastIndexOf('(') + 1, result.lastIndexOf(')'));
    }

    switch (type) {
      case 'Blood Sugar Level':
        if (interpretation.contains('Critical')) return 'Critical';
        if (interpretation.contains('High')) return 'Critical';
        if (interpretation.contains('Low')) return 'Medium';
        return 'Stable';
      case 'Psychiatric Evaluation':
        if (interpretation.contains('Unstable')) return 'Critical';
        if (interpretation.contains('Needs Attention')) return 'Medium';
        return 'Stable';
      case 'Cholesterol Level':
        if (interpretation.contains('Critical')) return 'Critical';
        if (interpretation.contains('High')) return 'Critical';
        if (interpretation.contains('Low')) return 'Medium';
        return 'Stable';
      case 'ECG':
        if (interpretation.contains('Critical')) return 'Critical';
        if (interpretation.contains('Irregular')) return 'Medium';
        return 'Stable';
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

  String calculateResultFromNumericValue(double value, TestOption test) {
    if (test.type == 'Blood Sugar Level') {
      if (value < 70) return 'Critical';  // Hypoglycemia
      if (value < 90) return 'Low';
      if (value > 180) return 'Critical'; // Hyperglycemia
      if (value > 140) return 'High';
      return 'Normal';
    } else if (test.type == 'Cholesterol Level') {
      if (value < 100) return 'Critical'; // Very low cholesterol
      if (value < 125) return 'Low';
      if (value > 240) return 'Critical'; // Very high cholesterol
      if (value > 200) return 'High';
      return 'Normal';
    }
    return 'Normal';
  }

  bool validateNumericInput(String input, TestOption test) {
    if (!test.isNumeric) return true;
    if (input.isEmpty) return false;
    return double.tryParse(input) != null;
  }

  String getValidationMessage(String input, TestOption test) {
    if (!test.isNumeric) return '';
    if (input.isEmpty) return 'Please enter a value';
    if (double.tryParse(input) == null) return 'Please enter a valid number';
    return '';
  }

  Future<void> handleAddRecord() async {
    if (selectedTest.isNumeric) {
      if (_numericValueController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Please enter a numeric value')),
        );
        return;
      }
      
      final validationMessage = getValidationMessage(_numericValueController.text, selectedTest);
      if (validationMessage.isNotEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(validationMessage)),
        );
        return;
      }
      
      final numericValue = double.parse(_numericValueController.text);
      selectedResult = calculateResultFromNumericValue(numericValue, selectedTest);
    }

    setState(() {
      isLoading = true;
    });

    try {
      final newReport = MedicalReport(
        type: selectedTest.type,
        date: DateTime.now().toString().split(' ')[0],
        result: selectedTest.isNumeric 
            ? '${_numericValueController.text} ${selectedTest.unit} (${selectedResult})'
            : selectedResult,
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
      final List<Map<String, dynamic>> updatedReports = medicalReports
          .map((report) => {
                'type': report.type,
                'date': report.date,
                'result': report.result,
                'attachments': []
              })
          .toList();

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

      print(
          'Updating patient with data: ${json.encode(updateData)}'); // Debug print

      // Make API call to update
      final response = await http.put(
        Uri.parse(
            'https://patientdbrepo.onrender.com/api/patient/update/${widget.patient!['_id']}'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(updateData),
      );

      print('API Response: ${response.body}'); // Debug print

      if (response.statusCode != 200 && response.statusCode != 201) {
        print('Error response: ${response.body}'); // For debugging
        throw Exception(
            'Failed to update medical records: ${response.statusCode}');
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
      Navigator.pop(context, 'recordsViewed');
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
      _numericValueController.clear();
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

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'critical':
        return Colors.red;
      case 'high':
        return Colors.orange;
      case 'low':
        return Colors.amber;
      case 'normal':
        return Colors.green;
      case 'stable':
        return Colors.green;
      case 'unstable':
        return Colors.red;
      case 'needs attention':
        return Colors.orange;
      case 'irregular':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    final condition = calculateCondition();

    return Scaffold(
      appBar: AppBar(
        title: Text(
            'Medical Records for ${widget.patient?['name'] ?? 'Unknown Patient'}'),
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () {
            // Only pass refresh signal if we actually added records
            // Otherwise just go back without causing further navigation
            if (medicalReports.isNotEmpty) {
              Navigator.pop(context,
                  'recordsViewed'); // Use a different signal than 'true'
            } else {
              Navigator.pop(context); // Just go back without refresh
            }
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
                            selectedTest = testOptions.firstWhere((test) => test.type == value);
                            if (!selectedTest.isNumeric) {
                              selectedResult = selectedTest.results[0];
                            }
                            _numericValueController.clear();
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
                    if (selectedTest.isNumeric) ...[
                      Text(
                        'Value (${selectedTest.unit})',
                        style: const TextStyle(fontSize: 16),
                      ),
                      TextField(
                        controller: _numericValueController,
                        keyboardType: TextInputType.number,
                        decoration: InputDecoration(
                          hintText: 'Enter value (${selectedTest.unit})',
                          errorText: getValidationMessage(_numericValueController.text, selectedTest),
                        ),
                        onChanged: (value) {
                          if (value.isNotEmpty && validateNumericInput(value, selectedTest)) {
                            final numericValue = double.parse(value);
                            setState(() {
                              selectedResult = calculateResultFromNumericValue(numericValue, selectedTest);
                            });
                          }
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Interpretation: $selectedResult',
                        style: TextStyle(
                          fontSize: 16,
                          color: _getStatusColor(selectedResult),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ] else ...[
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
                    ],
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
                          onPressed: () {
                            _numericValueController.clear();
                            setState(() => isModalVisible = false);
                          },
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
