import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:app/pages/change_password.dart';
import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangePasswordEmailScreen extends StatefulWidget {
  const ChangePasswordEmailScreen({Key? key}) : super(key: key);

  @override
  State<ChangePasswordEmailScreen> createState() =>
      _ChangePasswordEmailScreenState();
}

class _ChangePasswordEmailScreenState extends State<ChangePasswordEmailScreen> {
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

  Future<void> _sendEmail() async {
    final String email = _emailController.text.trim();
    final authProvider = Provider.of<UserProvider>(context,listen: false);
    final success = await authProvider.getUserEmail(email);
    if (success) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChangePasswordScreen(),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              SizedBox(width: 10),
              Text("Email not found"),
            ],
          ),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          margin: EdgeInsets.only(top: 20, left: 10, right: 10),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: SizedBox(
          width: double.infinity,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: SingleChildScrollView(
                child: Column(
              children: [
                SizedBox(height: 20),
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
                  "Please enter your email address for verification \n and to reset your password",
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF757575)),
                ),
                // const SizedBox(height: 16),
                SizedBox(height: 20),
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

                SizedBox(height: 20),
                MyButtons(onTap: _sendEmail, text: 'Send Email')
              ],
            )),
          ),
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);
