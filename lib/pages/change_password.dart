import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:app/provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:getwidget/getwidget.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  _ChangePasswordScreenState createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _repasswordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  String? _passwordError;
  String? _confirmPasswordError;
  bool _passwordStartedTyping = false;
  bool _confirmPasswordStartedTyping = false;
  void _validatePassword(String value) {
    if (_passwordStartedTyping) {
      setState(() {
        _passwordError = value.isNotEmpty ? null : "Password cannot be empty";
      });
      _validateConfirmPassword(_repasswordController.text);
    }
  }

  void _validateConfirmPassword(String value) {
    if (_confirmPasswordStartedTyping) {
      setState(() {
        _confirmPasswordError =
            value == _passwordController.text ? null : "Passwords do not match";
      });
    }
  }

  Future<void> _updatePassword() async {
    final String password = _passwordController.text.trim();
    final String rpassword = _repasswordController.text.trim();

    if (password != rpassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Password don\'t match',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 229, 34, 44),
        ),
      );
      return;
    }
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    final success = await authProvider.updatePassword(password);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Password Updated Successfully',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: Colors.green,
        ),
      );

      Future.delayed(const Duration(seconds: 3), () {
        Navigator.pushNamed(context, '/settings');
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'An Error occurred! Please try again after sometimes',
                  style: TextStyle(fontSize: 16),
                ),
              ),
            ],
          ),
          backgroundColor: const Color.fromARGB(255, 229, 34, 44),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Change Password",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: LogoWithTitle(
        title: "Change Password",
        children: [
          TextFieldInput(
            textEditingController: _passwordController,
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
            textEditingController: _repasswordController,
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
          SizedBox(
            height: 10,
          ),
          MyButtons(onTap: _updatePassword, text: 'Update Password')
        ],
      ),
    );
  }
}

class LogoWithTitle extends StatelessWidget {
  final String title, subText;
  final List<Widget> children;

  const LogoWithTitle(
      {Key? key,
      required this.title,
      this.subText = '',
      required this.children})
      : super(key: key);
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(builder: (context, constraints) {
        return SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              SizedBox(height: 10),
              SizedBox(
                height: constraints.maxHeight * 0.1,
                width: double.infinity,
              ),
              Text(
                title,
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  subText,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    height: 1.5,
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.64),
                  ),
                ),
              ),
              ...children,
            ],
          ),
        );
      }),
    );
  }
}
