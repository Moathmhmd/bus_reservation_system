import 'package:bus_reservation_system/Services/user_profile_service.dart';
import 'package:bus_reservation_system/pages/user/payment_method_selection_page.dart';
import 'package:bus_reservation_system/pages/user/payment_page.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class PassengerFormPage extends StatefulWidget {
  final String scheduleId;
  final int seatNumber;

  const PassengerFormPage({
    required this.scheduleId,
    required this.seatNumber,
    Key? key,
  }) : super(key: key);

  @override
  State<PassengerFormPage> createState() => _PassengerFormPageState();
}

class _PassengerFormPageState extends State<PassengerFormPage> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _genderController = TextEditingController();
  final _dobController = TextEditingController();
  final _idController = TextEditingController();
  final _mobileController = TextEditingController();
  final _emailController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  void _selectDate() async {
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

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      final passengerInfo = {
        'name': _nameController.text.trim(),
        'gender': _genderController.text.trim(),
        'dob': _dobController.text.trim(),
        'idNumber': _idController.text.trim(),
        'mobile': _mobileController.text.trim(),
        'email': _emailController.text.trim(),
      };

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PaymentMethodSelectionPage(
            scheduleId: widget.scheduleId,
            seatNumber: widget.seatNumber,
            passengerInfo: passengerInfo,
          ),
        ),
      );
    }
  }

  Future<void> _loadUserProfile() async {
    final profile = await UserProfileService.loadUserProfile();
    if (profile != null) {
      _nameController.text = profile.name;
      _genderController.text = profile.gender;
      _dobController.text = profile.dob;
      _idController.text = profile.idNumber;
      _mobileController.text = profile.mobile;
      _emailController.text = profile.email;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text("Passenger Information"),
        backgroundColor: Colors.amber,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              _buildTextField(_nameController, "Full Name"),
              _buildTextField(_genderController, "Gender"),
              _buildTextField(
                _dobController,
                "Date of Birth (YYYY-MM-DD)",
                readOnly: true,
                onTap: _selectDate,
              ),
              _buildTextField(_idController, "ID Number"),
              _buildTextField(
                _mobileController,
                "Mobile Number",
                keyboardType: TextInputType.phone,
              ),
              _buildTextField(
                readOnly: true,
                _emailController,
                "Email",
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitForm,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.amber,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
                child: const Text(
                  "Continue to Payment",
                  style: TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
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
        decoration: InputDecoration(
          labelText: label,
          border: const OutlineInputBorder(),
        ),
        validator: (value) =>
            value == null || value.isEmpty ? 'Please enter $label' : null,
        readOnly: readOnly,
        onTap: onTap,
        keyboardType: keyboardType,
      ),
    );
  }
}
