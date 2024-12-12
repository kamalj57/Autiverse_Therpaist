import 'dart:convert';
import 'dart:io';
import 'package:app/auth/widgets/my_buttons.dart';
import 'package:app/auth/widgets/text_field.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:app/provider/provider.dart';
import 'package:permission_handler/permission_handler.dart';

class TherapistProfilePage extends StatefulWidget {
  const TherapistProfilePage({Key? key}) : super(key: key);

  @override
  _TherapistProfilePageState createState() => _TherapistProfilePageState();
}

class _TherapistProfilePageState extends State<TherapistProfilePage> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _mobilenumberController;
  late TextEditingController _locationController;

  XFile? _profileImage;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    final userDetails = authProvider.userData;

    _nameController = TextEditingController(text: userDetails?['name']);
    _mobilenumberController =
        TextEditingController(text: userDetails?['mobile_number']);
    _locationController =
        TextEditingController(text: userDetails?['TherapistCenter']);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _mobilenumberController.dispose();
    _locationController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    try {
      await Permission.locationWhenInUse.isDenied.then((value) {
        if (value) {
          Permission.locationWhenInUse.request();
        }
      });
      LocationPermission permission = await Geolocator.requestPermission();

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Location permission denied')),
        );
        return;
      }

      Position position = await Geolocator.getCurrentPosition();

      String currentLocation = '${position.latitude}, ${position.longitude}';
      setState(() {
        _locationController.text = currentLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to fetch location: $e')),
      );
    }
  }

  void _pickImage() async {
    showDialog(
      context: context,
      builder: (context) {
        return SafeArea(
          child: AlertDialog(
            title: const Text("Choose Image Source"),
            backgroundColor: Colors.white,
            content: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.camera_alt),
                  title: const Text('Take Photo'),
                  onTap: () async {
                    Navigator.pop(context);
                    final pickedFile = await _picker.pickImage(
                      source: ImageSource.camera,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = pickedFile;
                      });
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library),
                  title: const Text('Choose from Gallery'),
                  onTap: () async {
                    Navigator.pop(context); // Close dialog
                    final pickedFile = await _picker.pickImage(
                      source: ImageSource.gallery,
                    );
                    if (pickedFile != null) {
                      setState(() {
                        _profileImage = pickedFile;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<String> _uploadImageToCloudinary(File image) async {
    final url = Uri.parse("https://api.cloudinary.com/v1_1/dyenglso8/upload");

    final request = http.MultipartRequest('POST', url)
      ..fields['upload_preset'] = 'sihproject'
      ..files.add(await http.MultipartFile.fromPath('file', image.path));

    final response = await request.send();

    if (response.statusCode == 200) {
      final responseBody = await response.stream.bytesToString();
      final responseData = json.decode(responseBody);

      if (responseData['secure_url'] != null) {
        return responseData['secure_url'];
      } else {
        throw Exception("Failed to get image URL from Cloudinary response");
      }
    } else {
      throw Exception(
          "Failed to upload image to Cloudinary. Status code: ${response.statusCode}");
    }
  }

  void _updateProfile() async {
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    String? profileImageUrl;

    if (_profileImage != null) {
      // Upload the image to Cloudinary
      try {
        profileImageUrl =
            await _uploadImageToCloudinary(File(_profileImage!.path));
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to upload image: $e')));
        return;
      }
    }

    final Map<String, dynamic> updatedDetails = {
      'name': _nameController.text.trim(),
      'mobile_number': _mobilenumberController.text.trim(),
      'TherapistCenter': _locationController.text.trim(),
      'profileImage': profileImageUrl,
    };

    final success = await authProvider.updateTherapistDetails(updatedDetails);
    if (success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Profile updated successfully!')),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Error occurred!')),
      );
    }

    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<UserProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: const Text(
          "Edit Profile",
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
                  const SizedBox(height: 20),
                  Text(
                    "Update Profile Details",
                    style: Theme.of(context)
                        .textTheme
                        .headlineSmall!
                        .copyWith(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: constraints.maxHeight * 0.05),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Profile Picture
                        GestureDetector(
                          onTap: _pickImage,
                          child: CircleAvatar(
                            radius: 50,
                            backgroundColor: Colors.grey.shade300,
                            backgroundImage: _profileImage != null
                                ? FileImage(File(_profileImage!.path))
                                : (authProvider.userData?['profileImage'] !=
                                            null &&
                                        authProvider.userData?['profileImage']!
                                            .isNotEmpty)
                                    ? NetworkImage(
                                        authProvider.userData?['profileImage']!)
                                    : null, // Handle null or empty URL gracefully
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Name Field
                        TextFieldInput(
                          textEditingController: _nameController,
                          hintText: "Name",
                          icon: Icons.account_circle,
                          textInputType: TextInputType.text,
                          errorText: _nameController.text.isEmpty
                              ? "Name is required"
                              : null,
                          onChanged: (value) {
                            _nameController.text = value;
                          },
                        ),
                        const SizedBox(height: 10),
                        TextFieldInput(
                          textEditingController: _mobilenumberController,
                          hintText: "Mobile Number",
                          icon: Icons.phone,
                          textInputType: TextInputType.text,
                          errorText: _nameController.text.isEmpty
                              ? "Mobile Number is required"
                              : null,
                          onChanged: (value) {
                            _nameController.text = value;
                          },
                        ),

                        const SizedBox(height: 10),
                        TextFieldInput(
                          textEditingController: _locationController,
                          hintText: "Center Name",
                          icon: Icons.location_city,
                          textInputType: TextInputType.text,
                          errorText: _locationController.text.isEmpty
                              ? "Center Name is required"
                              : null,
                          onChanged: (value) {
                            _nameController.text = value;
                          },
                        ),
                        // TextFormField(
                        //   controller: _locationController,
                        //   decoration: InputDecoration(
                        //     hintText: "Current Location",
                        //     hintStyle:
                        //         const TextStyle(color: Color(0xFF757575)),
                        //     contentPadding: const EdgeInsets.symmetric(
                        //         horizontal: 24, vertical: 16),
                        //     border: authOutlineInputBorder,
                        //     enabledBorder: authOutlineInputBorder,
                        //     focusedBorder: authOutlineInputBorder.copyWith(
                        //       borderSide:
                        //           const BorderSide(color: Color(0xFF00BF6D)),
                        //     ),
                        //     prefixIcon: IconButton(
                        //       icon: const Icon(Icons.location_on),
                        //       onPressed: _getCurrentLocation,
                        //     ),
                        //   ),
                        //   validator: (value) {
                        //     if (value == null || value.isEmpty) {
                        //       return "Location is required";
                        //     }
                        //     return null;
                        //   },
                        // ),
                        const SizedBox(height: 20),
                        MyButtons(onTap: _updateProfile, text: 'UpdateProfile')
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
