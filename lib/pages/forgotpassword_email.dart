import 'package:app/auth/widgets/text_field.dart';
import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ForgotPasswordEmailScreen extends StatefulWidget {
  const ForgotPasswordEmailScreen({super.key});

  @override
  _ForgotPasswordEmailScreenState createState() =>
      _ForgotPasswordEmailScreenState();
}

class _ForgotPasswordEmailScreenState extends State<ForgotPasswordEmailScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  String? _emailError;

  bool _emailStartedTyping = false;

  void _validateEmail(String value) {
    if (_emailStartedTyping) {
      setState(() {
        _emailError = _isValidEmail(value) ? null : "Invalid email address";
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    final Color bgColor = Colors.blue;
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  const Text(
                    "Change Password",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your email and we will send \nyou a link to return to your account",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          TextFieldInput(
                            textEditingController: _emailController,
                            hintText: "Enter Your Email",
                            icon: Icons.email,
                            textInputType: TextInputType.emailAddress,
                            errorText: _emailError,
                            onChanged: (value) {
                              if (!_emailStartedTyping) {
                                setState(() {
                                  _emailStartedTyping = true;
                                });
                              }
                              _validateEmail(value);
                            },
                          ),
                          SizedBox(
                              height: MediaQuery.of(context).size.height * 0.1),
                          ElevatedButton(
                            onPressed: () async {
                              if (_formKey.currentState!.validate()) {
                                final String email =
                                    _emailController.text.trim();
                                final success = await authProvider
                                    .sendPasswordResentLink(email);
                                if (success) {
                                 ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 10),
                                          Text("Email sent sucessfully"),
                                        ],
                                      ),
                                      backgroundColor: Color(0xFF00BF6D),
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          top: 20, left: 10, right: 10),
                                    ),
                                  );
                                  Future.delayed(const Duration(seconds: 3),
                                      () {
                                    Navigator.pushNamed(context, '/login');
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Row(
                                        children: [
                                          Icon(Icons.error,
                                              color: Colors.white),
                                          SizedBox(width: 10),
                                          Text("Email not found"),
                                        ],
                                      ),
                                      backgroundColor: Colors.red,
                                      behavior: SnackBarBehavior.floating,
                                      margin: EdgeInsets.only(
                                          top: 20, left: 10, right: 10),
                                    ),
                                  );
                                }
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              elevation: 0,
                              backgroundColor: bgColor,
                              foregroundColor: Colors.white,
                              minimumSize: const Size(double.infinity, 48),
                              shape: const RoundedRectangleBorder(
                                borderRadius:
                                    BorderRadius.all(Radius.circular(16)),
                              ),
                            ),
                            child: const Text("Send Email"),
                          )
                        ],
                      )),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.2),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

