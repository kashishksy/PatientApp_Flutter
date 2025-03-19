import 'dart:io';
import 'package:flutter/material.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;

class AddPatientScreen extends StatefulWidget {
  const AddPatientScreen({super.key});

  @override
  _AddPatientScreenState createState() => _AddPatientScreenState();
}

class _AddPatientScreenState extends State<AddPatientScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _admissionDateController =
      TextEditingController();
  final TextEditingController _dischargeDateController =
      TextEditingController();
  final TextEditingController _departmentController = TextEditingController();
  final TextEditingController _statusController = TextEditingController();

  String? _gender;
  File? _photo;

  // Function to handle photo selection
  Future<void> _pickPhoto() async {
    final ImagePicker picker = ImagePicker();
    final File? pickedFile =
        await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _photo = File(pickedFile.path);
      });
    }
  }

  // Function to handle form submission
  Future<void> _submitPatient() async {
    if (_nameController.text.isEmpty || _ageController.text.isEmpty) {
      // Show alert if required fields are empty
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Please fill all fields")));
      return;
    }

    try {
      final uri =
          Uri.parse('https://patientdbrepo.onrender.com/api/patient/create');
      var request = http.MultipartRequest('POST', uri)
        ..fields['name'] = _nameController.text
        ..fields['age'] = _ageController.text
        ..fields['dateOfAdmission'] = _admissionDateController.text
        ..fields['dateOfDischarge'] = _dischargeDateController.text
        ..fields['department'] = _departmentController.text
        ..fields['status'] = _statusController.text
        ..fields['gender'] = _gender ?? ''
        // Add photo if available
        ..files.add(await http.MultipartFile.fromPath('photo', _photo!.path));

      var response = await request.send();

      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Patient added successfully")));
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text("Failed to add patient")));
      }
    } catch (e) {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Patient"),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              // Photo Picker
              GestureDetector(
                onTap: _pickPhoto,
                child: Container(
                  width: 120,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(60),
                    image: _photo != null
                        ? DecorationImage(
                            image: FileImage(_photo!), fit: BoxFit.cover)
                        : null,
                  ),
                  child: _photo == null
                      ? Center(
                          child: Text("Tap to add photo",
                              style: TextStyle(color: Colors.black45)))
                      : null,
                ),
              ),
              SizedBox(height: 20),

              // Text Inputs
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: "Full Name"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _admissionDateController,
                decoration: InputDecoration(labelText: "Admission Date"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _dischargeDateController,
                decoration: InputDecoration(labelText: "Date of Discharge"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _ageController,
                decoration: InputDecoration(labelText: "Age"),
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 10),
              TextField(
                controller: _departmentController,
                decoration: InputDecoration(labelText: "Department"),
              ),
              SizedBox(height: 10),
              TextField(
                controller: _statusController,
                decoration: InputDecoration(labelText: "Status"),
              ),
              SizedBox(height: 10),

              // Gender Selection (Radio Buttons)
              Row(
                children: [
                  Text("Gender: "),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Male',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                      Text("Male"),
                    ],
                  ),
                  Row(
                    children: [
                      Radio<String>(
                        value: 'Female',
                        groupValue: _gender,
                        onChanged: (value) {
                          setState(() {
                            _gender = value;
                          });
                        },
                      ),
                      Text("Female"),
                    ],
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Submit Button
              ElevatedButton(
                onPressed: _submitPatient,
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  backgroundColor: Colors.blue,
                ),
                child: Text('Submit'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ImageSource {
  static var gallery;
}

class ImagePicker {
  pickImage({required source}) {}
}
