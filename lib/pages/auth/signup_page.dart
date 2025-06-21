import 'package:flutter/material.dart';
import 'package:bus_reservation_system/widgets/custom_elevated_button.dart';
import 'package:bus_reservation_system/widgets/custom_text_field.dart';
import 'package:bus_reservation_system/Services/auth_service.dart'; // Import AuthService
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Cloud Firestore

class SignUpPage extends StatefulWidget {
  final String role;
  const SignUpPage({super.key, required this.role});

  @override
  State<SignUpPage> createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _emailCon = TextEditingController();
  final TextEditingController _passwordCon = TextEditingController();
  final TextEditingController _nameCon = TextEditingController();
  final TextEditingController _phoneCon = TextEditingController();
  final TextEditingController _companyCon =
      TextEditingController(); // Company or License

  // To hold the list of companies for driver role
  List<String> _companyList = [];
  String? _selectedCompany;

  // Create an instance of AuthService
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    if (widget.role == 'driver') {
      _fetchAdminCompanies();
    }
  }

  // Fetch the list of companies from Firestore
  Future<void> _fetchAdminCompanies() async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('users')
          .where('role', isEqualTo: 'admin') // Fetch only admins
          .get();

      setState(() {
        _companyList = snapshot.docs
            .map((doc) => doc['company'] as String) // Extract company name
            .toList();
      });
    } catch (e) {
      print("Error fetching admin companies: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        minimum: EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.role == 'driver') ...[
                Image.asset('assets/driver.jpg', fit: BoxFit.contain),
              ],
              if (widget.role == 'admin') ...[
                Image.asset('assets/admin.jpg', fit: BoxFit.contain),
              ],
              if (widget.role == 'user') ...[
                Image.asset('assets/signup.jpg', fit: BoxFit.contain),
              ],
              SizedBox(height: 30),
              Text(
                "Sign Up as ${widget.role.toUpperCase()}",
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: Colors.amber,
                ),
              ),
              SizedBox(height: 25),
              // General User Information
              CustomTextField(
                controller: _nameCon,
                hintText: "Full Name",
                icon: Icons.person,
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: _emailCon,
                hintText: "Email",
                icon: Icons.email,
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: _phoneCon,
                hintText: "Phone",
                icon: Icons.phone,
              ),
              SizedBox(height: 15),
              CustomTextField(
                controller: _passwordCon,
                hintText: "Password",
                icon: Icons.lock,
                isPassword: true,
              ),
              SizedBox(height: 20),

              // Role-Specific Input Fields (Company)
              if (widget.role == 'driver') ...[
                // Dropdown for selecting company
                DropdownButtonFormField<String>(
                  value: _selectedCompany,
                  hint: Text('Select Company'),
                  onChanged: (value) {
                    setState(() {
                      _selectedCompany = value;
                    });
                  },
                  items: _companyList
                      .map((company) => DropdownMenuItem<String>(
                            value: company,
                            child: Text(company),
                          ))
                      .toList(),
                  decoration: InputDecoration(
                    labelText: 'Company',
                    prefixIcon: Icon(
                      Icons.business,
                      color: Colors.grey,
                    ),
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
              if (widget.role == 'admin') ...[
                // Text field for company name (admin role)
                CustomTextField(
                  controller: _companyCon,
                  hintText: "Company Name",
                  icon: Icons.business,
                ),
              ],
              SizedBox(height: 50),

              // Sign Up Button
              CustomElevatedButton(
                text: "Sign Up",
                color: Colors.amber,
                onPressed: () {
                  // Validate the form and call the signUp method from AuthService
                  if (widget.role == 'driver' && _selectedCompany == null) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Please Select the Company you work for'),
                      backgroundColor: Colors.red,
                    ));
                    return;
                  }

                  // Call the signUp method from the AuthService
                  _authService.signUp(
                    emailController: _emailCon,
                    passwordController: _passwordCon,
                    nameController: _nameCon,
                    phoneController: _phoneCon,
                    companyController: widget.role == 'admin'
                        ? _companyCon // Admin uses manual input for company
                        : TextEditingController(
                            text:
                                _selectedCompany), // Driver uses selected company
                    role: widget.role,
                    context: context,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
