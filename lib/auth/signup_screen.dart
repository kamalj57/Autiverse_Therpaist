import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:app/provider/provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});

  @override
  _SignUpScreenState createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final TextEditingController phoneNumberController = TextEditingController();
  final TextEditingController centerNameController = TextEditingController();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  String? _emailError;
  String? _nameError;
  String? _phoneError;
  String? _passwordError;
  String? _confirmPasswordError;
  String? _centerNameError;

  bool _emailStartedTyping = false;
  bool _nameStartedTyping = false;
  bool _phoneStartedTyping = false;
  bool _passwordStartedTyping = false;
  bool _confirmPasswordStartedTyping = false;
  bool _centerNameStartedTyping = false;

  void _validateEmail(String value) {
    if (_emailStartedTyping) {
      setState(() {
        _emailError = _isValidEmail(value) ? null : "Invalid email address";
      });
    }
  }

  void _validateName(String value) {
    if (_nameStartedTyping) {
      setState(() {
        _nameError = value.isNotEmpty ? null : "Name cannot be empty";
      });
    }
  }

  void _validatePhone(String value) {
    if (_phoneStartedTyping) {
      setState(() {
        _phoneError =
            _isValidPhoneNumber(value) ? null : "Invalid phone number";
      });
    }
  }

  void _validatePassword(String value) {
    if (_passwordStartedTyping) {
      setState(() {
        _passwordError = value.isNotEmpty ? null : "Password cannot be empty";
      });
      _validateConfirmPassword(confirmPasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    if (_confirmPasswordStartedTyping) {
      setState(() {
        _confirmPasswordError =
            value == passwordController.text ? null : "Passwords do not match";
      });
    }
  }

  void _validateCenterName(String value) {
    if (_centerNameStartedTyping) {
      setState(() {
        _centerNameError =
            value.isNotEmpty ? null : "Center name cannot be empty";
      });
    }
  }

  bool _isValidEmail(String email) {
    final emailRegex =
        RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,4}$");
    return emailRegex.hasMatch(email);
  }

  bool _isValidPhoneNumber(String phoneNumber) {
    final phoneRegex = RegExp(r"^\d{10}$");
    return phoneRegex.hasMatch(phoneNumber);
  }

  bool _isValidName(String name) {
    final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    return nameRegex.hasMatch(name);
  }

  Future<void> _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    if (_emailError == null &&
        _nameError == null &&
        _phoneError == null &&
        _passwordError == null &&
        _confirmPasswordError == null &&
        _centerNameError == null) {
      final authProvider = Provider.of<UserProvider>(context, listen: false);
      final result = await authProvider.signupTherapist(
          nameController.text.trim(),
          emailController.text.trim(),
          passwordController.text.trim(),
          phoneNumberController.text.trim(),
          centerNameController.text.trim());
      if (result == "Signup successful!") {
        _isLoading = false;
        Navigator.pushReplacementNamed(context, '/homescreen');
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Registration sucessfull")),
        );
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Please fix the errors and try again.")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    double height = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        title: Row(
          children: [
            Container(
              margin: const EdgeInsets.only(right: 10.0),
              child: Image.asset(
                'assets/images/decoration_images/vrlogo.jpg',
                height: 58,
                width: 58,
              ),
            ),
            Text.rich(
              TextSpan(
                text: 'Auti',
                style: const TextStyle(
                  fontSize: 24,
                  fontFamily: 'conf',
                  fontWeight: FontWeight.bold,
                  fontStyle: FontStyle.italic,
                  color: Color.fromARGB(255, 95, 103, 107),
                ),
                children: [
                  TextSpan(
                    text: 'Verse',
                    style: TextStyle(
                      fontSize: 24,
                      fontFamily: 'conf',
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                      fontStyle: FontStyle.italic,
                      shadows: [
                        Shadow(
                          offset: Offset(1.5, 1.5),
                          blurRadius: 3.0,
                          color: Colors.grey,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: height / 6.5,
                    child: Image.asset(
                        "assets/images/decoration_images/signup.jpg"),
                  ),
                  TextFieldInput(
                    textEditingController: nameController,
                    hintText: "Enter Your Name",
                    icon: Icons.person,
                    textInputType: TextInputType.text,
                    errorText: _nameError,
                    onChanged: (value) {
                      if (!_nameStartedTyping) {
                        setState(() {
                          _nameStartedTyping = true;
                        });
                      }
                      _validateName(value);
                    },
                  ),
                  TextFieldInput(
                    textEditingController: centerNameController,
                    hintText: "Enter Center Name",
                    icon: Icons.business,
                    textInputType: TextInputType.text,
                    errorText: _centerNameError,
                    onChanged: (value) {
                      if (!_centerNameStartedTyping) {
                        setState(() {
                          _centerNameStartedTyping = true;
                        });
                      }
                      _validateCenterName(value);
                    },
                  ),
                  TextFieldInput(
                    textEditingController: emailController,
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
                  TextFieldInput(
                    textEditingController: phoneNumberController,
                    hintText: "Enter Your Phone Number",
                    icon: Icons.phone,
                    textInputType: TextInputType.phone,
                    errorText: _phoneError,
                    onChanged: (value) {
                      if (!_phoneStartedTyping) {
                        setState(() {
                          _phoneStartedTyping = true;
                        });
                      }
                      _validatePhone(value);
                    },
                  ),
                  TextFieldInput(
                    textEditingController: passwordController,
                    hintText: "Enter Your Password",
                    icon: Icons.lock,
                    textInputType: TextInputType.text,
                    isPass: true,
                    obscureText: !_isPasswordVisible,
                    onIconPressed: () {
                      setState(() {
                        _isPasswordVisible = !_isPasswordVisible;
                      });
                    },
                    errorText: _passwordError,
                    onChanged: _validatePassword,
                  ),
                  TextFieldInput(
                    textEditingController: confirmPasswordController,
                    hintText: "Confirm Your Password",
                    icon: Icons.lock,
                    textInputType: TextInputType.text,
                    isPass: true,
                    obscureText: !_isConfirmPasswordVisible,
                    onIconPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                    errorText: _confirmPasswordError,
                    onChanged: (value) {
                      if (!_confirmPasswordStartedTyping) {
                        setState(() {
                          _confirmPasswordStartedTyping = true;
                        });
                      }
                      _validateConfirmPassword(value);
                    },
                  ),
                  SizedBox(height: 15),
                  MyButtons(
                    onTap: _registerUser,
                    text: "Register",
                  ),
                  SizedBox(height: 25),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Already have an accunt?",
                        style: TextStyle(fontSize: 12),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, '/login');
                        },
                        child: const Text(" Login",
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Colors.blue)),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (_isLoading)
              Container(
                color: Colors.black.withOpacity(0.5),
                child: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
          ],
        ),
      ),
    );
  }
}