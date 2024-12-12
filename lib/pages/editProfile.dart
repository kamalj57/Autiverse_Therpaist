import 'dart:convert';
import 'dart:io';
import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:app/provider/provider.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({Key? key}) : super(key: key);

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _ageController;
  late TextEditingController _genderController;
  late TextEditingController _mobilenumberController;
  late TextEditingController _fatherNameController;
  late TextEditingController _motherNameController;

  final ImagePicker _picker = ImagePicker();
  XFile? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    final userDetails = authProvider.userData;

    _nameController = TextEditingController(text: userDetails?['name']);
    _ageController = TextEditingController(text: userDetails?['age']);
    _genderController = TextEditingController(text: userDetails?['gender']);
    _mobilenumberController =
        TextEditingController(text: userDetails?['mobile_number']);
    _fatherNameController = TextEditingController(
        text: userDetails?['parents_details']?['father_name']);
    _motherNameController = TextEditingController(
        text: userDetails?['parents_details']?['mother_name']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _genderController.dispose();
    _mobilenumberController.dispose();
    _fatherNameController.dispose();
    _motherNameController.dispose();
    super.dispose();
  }

  void _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _profileImage = pickedFile;
      });
    }
  }

  Future<void> _uploadImageToCloudinary() async {
    if (_profileImage != null) {
      final url = Uri.parse("https://api.cloudinary.com/v1_1/dyenglso8/upload");

      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = 'sihproject'
        ..files.add(await http.MultipartFile.fromPath(
          'file',
          _profileImage!.path,
        ));

      final response = await request.send();

      if (response.statusCode == 200) {
        final responseBody = await response.stream.bytesToString();
        final responseData = json.decode(responseBody);

        if (responseData['secure_url'] != null) {
          setState(() {
            _profileImageUrl = responseData['secure_url'];
          });
        } else {
          throw Exception("Failed to get image URL from Cloudinary response");
        }
      } else {
        throw Exception(
            "Failed to upload image to Cloudinary. Status code: ${response.statusCode}");
      }
    }
  }

  Future<void> _updateDetails() async {
    try {
      await _uploadImageToCloudinary();

      final updatedDetails = {
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'gender': _genderController.text.trim(),
        'mobile_number': _mobilenumberController.text.trim(),
        'parents_details': {
          'father_name': _fatherNameController.text.trim(),
          'mother_name': _motherNameController.text.trim(),
        },
        if (_profileImageUrl != null) 'profileImage': _profileImageUrl,
      };
      final authProvider = Provider.of<UserProvider>(context);
      final success = await authProvider.updateUserDetails(updatedDetails);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? "Details Updated Successfully"
              : "Failed to Update Details"),
          backgroundColor: success ? Colors.green : Colors.red,
        ),
      );

      if (success) {
        Navigator.pushReplacementNamed(context, '/mainScreen');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Error: ${e.toString()}"),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
          style: TextStyle(color: Color(0xFF757575)),
        ),
      ),
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey.shade300,
                  backgroundImage: _profileImage != null
                      ? FileImage(File(_profileImage!.path))
                      : (authProvider.userData?['profileImage'] != null &&
                              authProvider
                                  .userData?['profileImage']!.isNotEmpty)
                          ? NetworkImage(
                              authProvider.userData?['profileImage']!)
                          : null,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                "Edit Profile Details",
                style: Theme.of(context)
                    .textTheme
                    .headlineSmall!
                    .copyWith(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    ..._buildInputFields(),
                    const SizedBox(height: 16.0),
                    MyButtons(onTap: _updateDetails, text: 'Update Details'),
                    const SizedBox(height: 16.0),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildInputFields() {
    return [
      TextFieldInput(
        textEditingController: _nameController,
        hintText: "Name",
        icon: Icons.account_circle,
        textInputType: TextInputType.text,
        errorText: _nameController.text.isEmpty ? "Name is required" : null,
        onChanged: (value) {
          _nameController.text = value;
        },
      ),
      const SizedBox(height: 5),
      TextFieldInput(
        textEditingController: _ageController,
        hintText: "Age",
        icon: Icons.cake,
        textInputType: TextInputType.text,
        errorText: _nameController.text.isEmpty ? "Age is required" : null,
        onChanged: (value) {
          _ageController.text = value;
        },
      ),
      const SizedBox(height: 5),
      DropdownButtonFormField<String>(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 7),
        value:
            _genderController.text.isNotEmpty ? _genderController.text : null,
        decoration: InputDecoration(
          hintText: "Select Gender",
          hintStyle: const TextStyle(color: Colors.black45, fontSize: 16),
          prefixIcon: const Icon(Icons.person, color: Colors.black45),
          contentPadding:
              const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
          filled: true,
          fillColor: const Color(0xFFedf0f8),
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide.none,
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 2, color: Colors.blue),
            borderRadius: BorderRadius.circular(10),
          ),
          errorBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderSide: const BorderSide(width: 1.5, color: Colors.red),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        items: const [
          DropdownMenuItem(value: 'Male', child: Text('Male')),
          DropdownMenuItem(value: 'Female', child: Text('Female')),
        ],
        onChanged: (value) {
          if (value != null) {
            _genderController.text = value;
          }
        },
        validator: (value) =>
            value == null || value.isEmpty ? "Gender is required" : null,
      ),
      const SizedBox(height: 5),
      TextFieldInput(
        textEditingController: _mobilenumberController,
        hintText: "Mobile Number",
        icon: Icons.phone,
        textInputType: TextInputType.text,
        errorText:
            _nameController.text.isEmpty ? "Mobile Number is required" : null,
        onChanged: (value) {
          _mobilenumberController.text = value;
        },
      ),
      const SizedBox(height: 5),
      TextFieldInput(
        textEditingController: _fatherNameController,
        hintText: "Father Name",
        icon: Icons.person_4,
        textInputType: TextInputType.text,
        errorText:
            _nameController.text.isEmpty ? "Father Name is required" : null,
        onChanged: (value) {
          _fatherNameController.text = value;
        },
      ),
      const SizedBox(height: 5),
      TextFieldInput(
        textEditingController: _motherNameController,
        hintText: "Mother Name",
        icon: Icons.person_2,
        textInputType: TextInputType.text,
        errorText:
            _nameController.text.isEmpty ? "Mother Name is required" : null,
        onChanged: (value) {
          _motherNameController.text = value;
        },
      ),
    ];
  }
}
