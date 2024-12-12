import 'package:app/provider/provider.dart';
import 'package:bot_toast/bot_toast.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ChangeEmailScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();
   final TextEditingController _emailController = TextEditingController();
  ChangeEmailScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    final role =authProvider.userRole;
    final Color bgColor =
        role == "therapist" ? Color(0xFF00BF6D) : Color(0xFFFE9901);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Change Email",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      backgroundColor: Colors.white,
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
                    "Change Email Address",
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Please enter your new email and we will send \nyou a link to verify it",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Color(0xFF757575)),
                  ),
                  // const SizedBox(height: 16),
                  SizedBox(height: MediaQuery.of(context).size.height * 0.15),
                  Form(
                  key: _formKey,
                  child: Column(
                  children: [
                    TextFormField(
            controller: _emailController,
            decoration: InputDecoration(
                hintText: "Enter your email",
                labelText: "Email",
                floatingLabelBehavior: FloatingLabelBehavior.always,
                hintStyle: const TextStyle(color: Color(0xFF757575)),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                suffix:Icon(Icons.email,
                color: Colors.grey,
                ),
                border: authOutlineInputBorder,
                enabledBorder: authOutlineInputBorder,
                focusedBorder: authOutlineInputBorder.copyWith(
                    borderSide: BorderSide(color: bgColor))),
            keyboardType: TextInputType.emailAddress,
            validator: (value) {
              if (value == null || value.isEmpty) {
                return "Email is required";
              }
              return null;
            },
          ),
          SizedBox(height: MediaQuery.of(context).size.height * 0.1),
          ElevatedButton(
            onPressed: () async {
              if (_formKey.currentState!.validate()) {
                final String email = _emailController.text.trim();
                final success = await authProvider.sendEmailResentLink(email);
                if (success) {
                    BotToast.showSimpleNotification(
                    title: "Email sent successfully!",
                    titleStyle:
                        const TextStyle(color: Colors.white, fontSize: 16),
                    duration: const Duration(seconds: 3),
                    align: const Alignment(0, -0.8),
                    backgroundColor: bgColor,
                    borderRadius: 8.0,
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
                          SizedBox(width: 10),
                          Text("An Error Ocuured Please try again later"),
                        ],
                      ),
                      backgroundColor: Colors.red,
                      behavior: SnackBarBehavior.floating,
                      margin: EdgeInsets.only(top: 20, left: 10, right: 10),
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
                borderRadius: BorderRadius.all(Radius.circular(16)),
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

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);

