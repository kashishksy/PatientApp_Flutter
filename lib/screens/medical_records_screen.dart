import 'package:flutter/material.dart';

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
}

class Patient {
  final String name;
  final List<MedicalReport> medicalReports;

  Patient({required this.name, required this.medicalReports});
}

class MedicalRecordsScreen extends StatefulWidget {
  final Patient? patient;

  const MedicalRecordsScreen({super.key, this.patient});

  @override
  _MedicalRecordsScreenState createState() => _MedicalRecordsScreenState();
}

class _MedicalRecordsScreenState extends State<MedicalRecordsScreen> {
  late List<MedicalReport> medicalReports;
  bool isModalVisible = false;
  late TestOption selectedTest;
  late String selectedResult;

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
    // Default to an empty patient if none provided
    Patient defaultPatient = Patient(name: 'John Doe', medicalReports: []);
    medicalReports =
        (widget.patient?.medicalReports ?? defaultPatient.medicalReports);
    selectedTest = testOptions[0];
    selectedResult = testOptions[0].results[0];

    // Equivalent to useEffect
    print(
        'Loaded medical records for: ${widget.patient?.name ?? defaultPatient.name}');
  }

  String calculateCondition() {
    int conditionScore = 0;

    for (var report in medicalReports) {
      final type = report.type;
      final result = report.result;

      switch (type) {
        case 'Blood Sugar Level':
          conditionScore += result == 'High'
              ? 2
              : result == 'Low'
                  ? 1
                  : 0;
          break;
        case 'Psychiatric Evaluation':
          conditionScore += result == 'Unstable'
              ? 3
              : result == 'Needs Attention'
                  ? 2
                  : 0;
          break;
        case 'Cholesterol Level':
          conditionScore += result == 'High'
              ? 2
              : result == 'Borderline'
                  ? 1
                  : 0;
          break;
        case 'ECG':
          conditionScore += result == 'Critical'
              ? 3
              : result == 'Irregular'
                  ? 2
                  : 0;
          break;
        default:
          break;
      }
    }

    if (conditionScore > 6) return 'Critical';
    if (conditionScore > 3) return 'Medium';
    return 'Stable';
  }

  void handleAddRecord() {
    final newRecord = MedicalReport(
      type: selectedTest.type,
      date: DateTime.now().toString().split(' ')[0],
      result: selectedResult,
    );

    setState(() {
      medicalReports.add(newRecord);
      isModalVisible = false;
    });
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
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Medical Records for ${widget.patient?.name ?? 'John Doe'}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Text(
              'Overall Condition: ${calculateCondition()}',
              style: const TextStyle(fontSize: 18),
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
                      style:
                          TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
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
                          onPressed: handleAddRecord,
                          child: const Text('Add Record'),
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
