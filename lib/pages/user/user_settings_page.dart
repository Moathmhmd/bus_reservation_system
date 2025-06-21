import 'package:bus_reservation_system/Services/user_profile_service.dart';
import 'package:bus_reservation_system/pages/user/user_profile_model.dart';
import 'package:bus_reservation_system/widgets/custom_bottom_navbar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class UserSettingsPage extends StatefulWidget {
  const UserSettingsPage({Key? key}) : super(key: key);

  @override
  State<UserSettingsPage> createState() => _UserSettingsPageState();
}

class _UserSettingsPageState extends State<UserSettingsPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _idController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    final profile = await UserProfileService.loadUserProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _genderController.text = profile.gender;
      _dobController.text = profile.dob;
      _idController.text = profile.idNumber;
      _mobileController.text = profile.mobile;
      _emailController.text = profile.email;
    }
    setState(() => _isLoading = false);
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime(2000),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      _dobController.text = DateFormat('yyyy-MM-dd').format(picked);
    }
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    final profile = UserProfile(
      name: _nameController.text.trim(),
      gender: _genderController.text.trim(),
      dob: _dobController.text.trim(),
      idNumber: _idController.text.trim(),
      mobile: _mobileController.text.trim(),
      email: _emailController.text.trim(),
    );

    setState(() => _isLoading = true);
    await UserProfileService.saveUserProfile(profile);
    setState(() => _isLoading = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Profile saved successfully")),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          centerTitle: true,
          title: const Text("Settings"),
          backgroundColor: Colors.amber,
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : Center(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      children: [
                        _buildField(_nameController, "Full Name"),
                        _buildField(_genderController, "Gender"),
                        _buildField(
                          _dobController,
                          "Date of Birth (YYYY-MM-DD)",
                          readOnly: true,
                          onTap: _selectDate,
                        ),
                        _buildField(_idController, "ID Number"),
                        _buildField(_mobileController, "Mobile",
                            keyboardType: TextInputType.phone),
                        _buildField(_emailController, "Email",
                            readOnly: true,
                            keyboardType: TextInputType.emailAddress),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.amber,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          child: const Text(
                            "Save Profile",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
        bottomNavigationBar: const CustomNavBar(currentIndex: 3));
  }

  Widget _buildField(
    TextEditingController controller,
    String label, {
    bool readOnly = false,
    TextInputType keyboardType = TextInputType.text,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
        validator: (value) => value == null || value.trim().isEmpty
            ? 'Please enter $label'
            : null,
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
      ),
    );
  }
}
