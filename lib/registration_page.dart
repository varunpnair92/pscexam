import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'app_config.dart';
import 'auth_controller.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  final _formKey = GlobalKey<FormState>();
  final AuthController auth = Get.find();

  // Controllers
  final TextEditingController _fullNameController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();

  String? _selectedQualification;
  List<int> _selectedCourses = [];

  List<dynamic> _qualifications = [];
  List<dynamic> _courses = [];
  bool _isLoadingData = true;
  bool _isSaving = false;

  late String _email;

  @override
  void initState() {
    super.initState();
    _email = Get.arguments['email'] ?? "";
    _fullNameController.text = Get.arguments['name'] ?? "";
    _fetchMasterData();
  }

  Future<void> _fetchMasterData() async {
    try {
      final qRes = await http.get(Uri.parse(AppConfig.qualifications));
      final cRes = await http.get(Uri.parse(AppConfig.courses));

      if (qRes.statusCode == 200 && cRes.statusCode == 200) {
        setState(() {
          _qualifications = jsonDecode(qRes.body);
          _courses = jsonDecode(cRes.body);
          _isLoadingData = false;
        });
      }
    } catch (e) {
      Get.snackbar("Error", "Failed to load registration data");
      setState(() => _isLoadingData = false);
    }
  }

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    final payload = {
      "fullname": _fullNameController.text,
      "username": _email,
      "qualification": _selectedQualification != null 
          ? _qualifications.firstWhere((q) => q['id'].toString() == _selectedQualification)['name']
          : "N/A",
      "userType": "trial", 
      "profile": {
        "phone_number": _phoneController.text,
        "place": _placeController.text,
        "qualification_ref": _selectedQualification != null ? int.parse(_selectedQualification!) : null,
        "courses": _selectedCourses,
      }
    };

    try {
      final response = await http.post(
        Uri.parse("${AppConfig.getUserDetails}$_email/"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(payload),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        final userData = data['user'] ?? data;
        
        // Save session after successful registration
        await auth.saveSession(
          userData['userid'] ?? 1,
          userData['username'] ?? _email,
          userData['fullname'] ?? _fullNameController.text,
          userData['userType'] ?? "trial",
        );

        Get.offAllNamed('/home');
        Get.snackbar("Welcome!", "Registration successful!");
      } else {
        Get.snackbar("Error", "Registration failed. Try again.");
      }
    } catch (e) {
      Get.snackbar("Error", "Server error. Please check your connection.");
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Complete Your Profile"),
        backgroundColor: Color(0xFF1B8A4E),
        elevation: 0,
      ),
      body: _isLoadingData
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Setup your account for $_email",
                      style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 25),

                    _buildTextField("Full Name", _fullNameController, Icons.person, "Enter your full name"),
                    SizedBox(height: 15),

                    _buildTextField("Phone Number", _phoneController, Icons.phone, "Enter phone number", keyboardType: TextInputType.phone),
                    SizedBox(height: 15),

                    _buildTextField("Place", _placeController, Icons.location_on, "Enter your city/place"),
                    SizedBox(height: 20),

                    _buildDropdownLabel("Highest Qualification"),
                    DropdownButtonFormField<String>(
                      value: _selectedQualification,
                      items: _qualifications.map<DropdownMenuItem<String>>((q) {
                        return DropdownMenuItem<String>(
                          value: q['id'].toString(),
                          child: Text(q['name']),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedQualification = val),
                      decoration: _inputDecoration(Icons.school),
                      validator: (val) => val == null ? "Please select qualification" : null,
                    ),
                    SizedBox(height: 20),

                    _buildDropdownLabel("Select Courses"),
                    Container(
                      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade400),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Column(
                        children: _courses.map((c) {
                          return CheckboxListTile(
                            title: Text(c['name']),
                            subtitle: Text(c['course_type'] ?? "free"),
                            value: _selectedCourses.contains(c['id']),
                            activeColor: Color(0xFF1B8A4E),
                            onChanged: (bool? value) {
                              setState(() {
                                if (value == true) {
                                  _selectedCourses.add(c['id']);
                                } else {
                                  _selectedCourses.remove(c['id']);
                                }
                              });
                            },
                          );
                        }).toList(),
                      ),
                    ),
                    
                    SizedBox(height: 40),

                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: _isSaving ? null : _submitForm,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Color(0xFF1B8A4E),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        ),
                        child: _isSaving 
                          ? CircularProgressIndicator(color: Colors.white)
                          : Text("Start Learning", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller, IconData icon, String hint, {TextInputType keyboardType = TextInputType.text}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
        ),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          decoration: _inputDecoration(icon, hint: hint),
          validator: (val) => val == null || val.isEmpty ? "Required field" : null,
        ),
      ],
    );
  }

  Widget _buildDropdownLabel(String label) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(label, style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey[700])),
    );
  }

  InputDecoration _inputDecoration(IconData icon, {String? hint}) {
    return InputDecoration(
      prefixIcon: Icon(icon, color: Color(0xFF1B8A4E)),
      hintText: hint,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Color(0xFF1B8A4E), width: 2),
      ),
      filled: true,
      fillColor: Colors.grey[50],
    );
  }
}
