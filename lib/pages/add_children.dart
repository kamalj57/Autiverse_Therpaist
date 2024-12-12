import 'dart:io';
import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:app/provider/provider.dart';

class AddChildren extends StatefulWidget {
  const AddChildren({Key? key}) : super(key: key);

  @override
  _AddChildrenState createState() => _AddChildrenState();
}

class _AddChildrenState extends State<AddChildren> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _genderController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _mobilenumberController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  bool _isLoading = false;

  String? _nameError;
  String? _ageError;
  String? _emailError;
  String? _phoneNumberError;
  String? _fatherNameError;
  String? _motherNameError;

  bool _nameStartedTyping = false;
  bool _ageStartedTyping = false;
  bool _emailStartedTyping = false;
  bool _phonenumberStartedTyping = false;
  bool _fatherNameStartedTyping = false;
  bool _motherNameStartedTyping = false;

  bool _isValidName(String name) {
    final nameRegex = RegExp(r"^[a-zA-Z\s]+$");
    return nameRegex.hasMatch(name);
  }

  void _validateName(String value) {
    if (_nameStartedTyping) {
      setState(() {
        _nameError = value.isNotEmpty ? null : "Name cannot be empty";
      });
    }
  }

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

  void _showImageSourceDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Choose Image Source"),
        backgroundColor: Colors.white,
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: Icon(Icons.photo),
              title: Text("Gallery"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.gallery);
              },
            ),
            ListTile(
              leading: Icon(Icons.camera),
              title: Text("Camera"),
              onTap: () {
                Navigator.of(ctx).pop();
                _pickImage(ImageSource.camera);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _addChildren() async {
    final String name = _nameController.text.trim();
    final String age = _ageController.text.trim();
    final String gender = _genderController.text.trim();
    final String email = _emailController.text.trim();
    final String mobile = _mobilenumberController.text.trim();
    final String fatherName = _fatherNameController.text.trim();
    final String motherName = _motherNameController.text.trim();
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    final result = await authProvider.addChilrenDetails(name, age, gender,
        email, mobile, fatherName, motherName, _profileImage);
    if (result) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Details added successfully!"),
          backgroundColor: Colors.green,
          duration: const Duration(seconds: 2),
        ),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pop(context);
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text("Details Failed successfully!"),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 2),
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
          "Add Children",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  SizedBox(height: 10),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Picture
                        GestureDetector(
                          onTap: () => _showImageSourceDialog(context),
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _profileImage != null
                                ? FileImage(File(_profileImage!.path))
                                : null,
                            child: _profileImage == null
                                ? Icon(Icons.camera_alt,
                                    size: 50, color: Colors.grey.shade800)
                                : null,
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Name Field
                        TextFieldInput(
                          textEditingController: _nameController,
                          hintText: "Enter Children Name",
                          icon: Icons.account_circle,
                          textInputType: TextInputType.emailAddress,
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

                        const SizedBox(height: 10),

                        TextFieldInput(
                          textEditingController: _nameController,
                          hintText: "Enter Children Age",
                          icon: Icons.cake,
                          textInputType: TextInputType.text,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (!_nameStartedTyping) {
                              setState(() {
                                _ageStartedTyping = true;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 10),
                        DropdownButtonFormField<String>(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 15, vertical: 7),
                          decoration: InputDecoration(
                            hintText: "Gender",
                            hintStyle: const TextStyle(
                                color: Colors.black45, fontSize: 16),
                            prefixIcon:
                                const Icon(Icons.person, color: Colors.black45),
                            contentPadding: const EdgeInsets.symmetric(
                                vertical: 16, horizontal: 20),
                            filled: true,
                            fillColor: const Color(0xFFedf0f8),
                            enabledBorder: OutlineInputBorder(
                              borderSide: BorderSide.none,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 2, color: Colors.blue),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            errorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            focusedErrorBorder: OutlineInputBorder(
                              borderSide: const BorderSide(
                                  width: 1.5, color: Colors.red),
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: const [
                            DropdownMenuItem(
                                value: 'Male', child: Text('Male')),
                            DropdownMenuItem(
                                value: 'Female', child: Text('Female')),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              _genderController.text = value;
                            }
                          },
                          validator: (value) => value == null || value.isEmpty
                              ? "Preferred Interest is required"
                              : null,
                        ),
                        const SizedBox(height: 10),

                        // Email Field
                        TextFieldInput(
                          textEditingController: _emailController,
                          hintText: "Enter Email",
                          icon: Icons.email,
                          textInputType: TextInputType.emailAddress,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (!_nameStartedTyping) {
                              setState(() {
                                _emailStartedTyping = true;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFieldInput(
                          textEditingController: _mobilenumberController,
                          hintText: "Enter Mobile Number",
                          icon: Icons.phone,
                          textInputType: TextInputType.text,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (!_nameStartedTyping) {
                              setState(() {
                                _phonenumberStartedTyping = true;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFieldInput(
                          textEditingController: _fatherNameController,
                          hintText: "Enter Children Father Name",
                          icon: Icons.person_4,
                          textInputType: TextInputType.text,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (!_nameStartedTyping) {
                              setState(() {
                                _fatherNameStartedTyping = true;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFieldInput(
                          textEditingController: _motherNameController,
                          hintText: "Enter Children Mother Name",
                          icon: Icons.person_3,
                          textInputType: TextInputType.text,
                          errorText: _nameError,
                          onChanged: (value) {
                            if (!_nameStartedTyping) {
                              setState(() {
                                _motherNameStartedTyping = true;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 10),

                        MyButtons(onTap: _addChildren, text: 'Add Detail')
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

const authOutlineInputBorder = OutlineInputBorder(
  borderSide: BorderSide(color: Color(0xFF757575)),
  borderRadius: BorderRadius.all(Radius.circular(100)),
);
