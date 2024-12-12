import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class UserProvider extends ChangeNotifier {
  final FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  bool _isLoggedIn = false;
  bool get isLoggedIn => _isLoggedIn;

  Map<String, dynamic>? _userData;
  Map<String, dynamic>? get userData => _userData;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  String? _userRole;
  String? _userEmail;

  String? get userRole => _userRole;
  String? get userEmail => _userEmail;

  List<Map<String, dynamic>> childrenDetails = [];

  Map<String, dynamic>? therapistDetails;

  List<String> availableSlots = [];
  List<String> userBookings = [];

  get bookingStatus => null;

  get user => null;

  void setUserRole(String role) {
    _userRole = role;
    notifyListeners();
  }

  void clearUserData() {
    _userRole = null;
    _userEmail = null;
    notifyListeners();
  }

  Future<void> saveUserToPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userRole', _userRole ?? '');
    await prefs.setString('userEmail', _userEmail ?? '');
    await prefs.setBool('isLoggedIn', _isLoggedIn);
  }

  Future<void> loadUserFromPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _userRole = prefs.getString('userRole');
    _userEmail = prefs.getString('userEmail');
    _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
    notifyListeners();
  }

  Future<void> clearPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userRole');
    await prefs.remove('userEmail');
    await prefs.remove('isLoggedIn');
  }

  Future<void> initializeUser() async {
    await loadUserFromPreferences();
    await fetchUserDetails();
    print('UserData => $userData');
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();
    try {
      final UserCredential userCredential =
          await firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      final collectionName = 'therapist_users';
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _errorMessage = "User not found in Firestore";
        notifyListeners();
        return false;
      }

      final userDoc = querySnapshot.docs.first;
      _userEmail = email;
      _userData = userDoc.data();
      _errorMessage = null;
      _isLoggedIn = true;
      print('UserData => $userData');
      await saveUserToPreferences();
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = "Login failed: ${e.toString()}";
      notifyListeners();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<String> signupTherapist(String name, String email, String password,
      String phoneNumber, String TherapistCenter) async {
    try {
      final querySnapshot = await _firestore
          .collection('therapist_users')
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        return "Email already exists in Firestore";
      }

      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      String profileImageUrl = generateProfileImageUrl(name);
      await _firestore.collection('therapist_users').add({
        '_id': firebaseAuth.currentUser?.uid,
        'name': name,
        'email': email,
        'phoneNumber': phoneNumber,
        'TherapistCenter': TherapistCenter,
        'profileImage': profileImageUrl,
      });
      _isLoggedIn = true;
      await saveUserToPreferences();
      return "Signup successful!";
    } catch (e) {
      return "Signup failed: ${e.toString()}";
    }
  }

  String generateProfileImageUrl(String name) {
    String initial = name.isNotEmpty ? name[0].toUpperCase() : 'A';
    String imageUrl =
        "https://ui-avatars.com/api/?name=$initial&background=random&color=fff&length=1";
    return imageUrl;
  }

  Future<void> signout() async {
    clearUserData();
    clearPreferences();
    _userRole = null;
    _userEmail = null;
    _isLoggedIn = false;
    await firebaseAuth.signOut();
  }

  Future<bool> fetchUserDetails() async {
    try {
      final collectionName = 'therapist_users';
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: _userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        _userData = querySnapshot.docs.first.data();
        notifyListeners();
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error fetching user details: ${e.toString()}");
      return false;
    }
  }

  Future<bool> addChilrenDetails(
      String name,
      String age,
      String gender,
      String email,
      String mobile,
      String fatherName,
      String motherName,
      XFile? profileImage) async {
    try {
      await firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: mobile,
      );
      String? profileImageUrl;

      if (profileImage != null) {
        final url =
            Uri.parse("https://api.cloudinary.com/v1_1/dyenglso8/upload");

        final request = http.MultipartRequest('POST', url)
          ..fields['upload_preset'] = 'sihproject'
          ..files.add(await http.MultipartFile.fromPath(
            'file',
            profileImage.path,
          ));

        final response = await request.send();

        if (response.statusCode == 200) {
          final responseBody = await response.stream.bytesToString();
          final responseData = json.decode(responseBody);

          if (responseData['secure_url'] != null) {
            profileImageUrl = responseData['secure_url'];
          } else {
            throw Exception("Failed to get image URL from Cloudinary response");
          }
        } else {
          throw Exception(
              "Failed to upload image to Cloudinary. Status code: ${response.statusCode}");
        }
      }
      await _firestore.collection('children_details').add({
        'name': name,
        'age': age,
        'gender': gender,
        'email': email,
        'mobile_number': mobile,
        'parents_details': {
          'father_name': fatherName,
          'mother_name': motherName
        },
        'profileImage': profileImageUrl,
        'doctor_id': firebaseAuth.currentUser?.uid,
      });
       notifyListeners();
      return true;
     
    } catch (e) {
      _errorMessage = "Something went wrong: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateUserDetails(Map<String, dynamic> updatedDetails) async {
    try {
      final collectionName = 'therapist_users';
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: _userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection(collectionName)
            .doc(docId)
            .update(updatedDetails);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error updating user details: ${e.toString()}");
      return false;
    }
  }

  Future<bool> getUserEmail(String email) async {
    final collectionName = 'therapist_users';
    try {
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: email)
          .limit(1)
          .get();

      if (querySnapshot.docs.isEmpty) {
        _errorMessage = "User not found in Firestore";
        notifyListeners();
        return false;
      }

      return true;
    } catch (e) {
      _errorMessage = "Something went wrong: ${e.toString()}";
      notifyListeners();
      return false;
    }
  }

  Future<bool> updatePassword(String newPassword) async {
    try {
      await firebaseAuth.currentUser!.updatePassword(newPassword);
      final collectionName = 'therapist_users';

      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: _userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final userDoc = querySnapshot.docs.first.reference;
        await userDoc.update({
          'password_last_updated': DateTime.now().toIso8601String(),
        });
      }

      return true;
    } catch (e) {
      debugPrint("Error updating password: ${e.toString()}");
      return false;
    }
  }

  Future<bool> sendPasswordResentLink(String email) async {
    try {
      await firebaseAuth.sendPasswordResetEmail(email: email);
      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> sendEmailResentLink(String newEmail) async {
    try {
      if (_userEmail == newEmail) {
        debugPrint("The new email is the same as the current email.");
        return false;
      }
      await firebaseAuth.currentUser?.verifyBeforeUpdateEmail(newEmail);
      debugPrint("A verification email has been sent to $newEmail.");
      final collectionName = 'therapist_users';
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: _userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore.collection(collectionName).doc(docId).update({
          'email': newEmail,
        });
        _userEmail = newEmail;

        debugPrint("Firestore and local user email updated successfully.");
        notifyListeners();
        return true;
      } else {
        debugPrint("No Firestore record found for the current email.");
        return false;
      }
    } catch (e) {
      debugPrint("Error updating email: ${e.toString()}");
      return false;
    }
  }

  Future<bool> updateTherapistDetails(
      Map<String, dynamic> updatedDetails) async {
    try {
      final collectionName = 'therapist_users';
      final querySnapshot = await _firestore
          .collection(collectionName)
          .where('email', isEqualTo: _userEmail)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final docId = querySnapshot.docs.first.id;
        await _firestore
            .collection(collectionName)
            .doc(docId)
            .update(updatedDetails);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("Error updating user details: ${e.toString()}");
      return false;
    }
  }

  Future<void> getChildrenDetails() async {
    try {
      final childrenCollection = _firestore.collection('children_details');

      final querySnapshot = await childrenCollection
          .where('doctor_id', isEqualTo: firebaseAuth.currentUser?.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        childrenDetails.clear();
        for (var doc in querySnapshot.docs) {
          var childDetails = {
            "id": doc.id,
            "name": doc.data()['name'] ?? '',
            "age": doc.data()['age'] ?? '',
            "doctor_id": doc.data()['doctor_id'] ?? '',
            "email": doc.data()['email'] ?? '',
            "gender": doc.data()['gender'] ?? '',
            "mobile_number": doc.data()['mobile_number'] ?? '',
            "parents_details": doc.data()['parents_details'] ?? {},
            "profileImage": doc.data()['profileImage'] ?? '',
          };
          var recentActivities = doc.data()['recentactivities'];
          if (recentActivities != null && recentActivities is List) {
            childrenDetails.add({
              "childDetails": childDetails,
              "recentActivities": recentActivities,
            });
          } else {
            childrenDetails.add({
              "childDetails": childDetails,
              "recentActivities": [],
            });
          }
        }
        print('Children Details: $childrenDetails');
      } else {
        print("No children found for this doctor.");
        childrenDetails = [];
      }
      notifyListeners();
    } catch (e) {
      print("Error fetching children details: $e");
      childrenDetails = [];
      notifyListeners();
    }
  }

  Future<void> fetchTherapistDetails() async {
    try {
      final querySnapshot = await _firestore
          .collection('therapist_users')
          .where('_id', isEqualTo: firebaseAuth.currentUser!.uid)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        therapistDetails = querySnapshot.docs.first.data();
      }
    } catch (e) {
      debugPrint("Error fetching user details: ${e.toString()}");
    }
    notifyListeners();
  }

  Future<bool> storeSchedule(Map<String, dynamic> scheduleDetails) async {
    try {
      var querySnapshot = await _firestore
          .collection('therapist_appointments')
          .where('_id', isEqualTo: 'im5qKNrw9IS863C4CVfYRGAmM5e2')
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        var document = querySnapshot.docs.first;
        await document.reference
            .set({'schedule': scheduleDetails}, SetOptions(merge: true));
        notifyListeners();
        return true;
      } else {
        print('No document found with id:');
        return false;
      }
    } catch (e) {
      print('Error storing schedule: $e');
      return false;
    }
  }

  Future<List<String>> getAvailableSlots(String date) async {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;
    final String? therapistId = userData?['doctor_id'];

    if (therapistId == null) {
      print('Therapist ID is missing.');
      return [];
    }

    try {
      var docSnapshot = await _firestore
          .collection('therapist_appointments')
          .where('_id', isEqualTo: therapistId)
          .get();

      if (docSnapshot.docs.isNotEmpty) {
        var data = docSnapshot.docs.first.data();
        String dayOfWeek = DateFormat('EEEE').format(DateTime.parse(date));

        List<String> schedule =
            List<String>.from(data['schedule'][dayOfWeek] ?? []);

        List<String> bookedSlots = List<String>.from(
          (data['appointments'] as List<dynamic>? ?? [])
                  .where((appointment) => appointment['date'] == date)
                  .map((appointment) => appointment['time'].toString()) ??
              [],
        );

        availableSlots = schedule.where((slot) {
          return !bookedSlots.contains(slot);
        }).toList();

        userBookings = (data['appointments'] as List<dynamic>? ?? [])
            .where((appointment) => appointment['parent_id'] == parentId)
            .map((appointment) => appointment['time'].toString())
            .toList();

        notifyListeners();
        return availableSlots;
      }

      return [];
    } catch (e) {
      print('Error fetching availability: $e');
      return [];
    }
  }

  Future<bool> bookAppointment({
    required String time,
    required String date,
  }) async {
    final String parentId = FirebaseAuth.instance.currentUser!.uid;
    final String? therapistId = userData?['doctor_id'];

    print('tHERPAISTiD ${therapistId}');
    print('time : ${time}');
    if (therapistId == null) {
      print('Therapist ID is missing.');
      return false;
    }

    try {
      var therapistQuery = await _firestore
          .collection('therapist_appointments')
          .where('_id', isEqualTo: therapistId)
          .get();

      if (therapistQuery.docs.isEmpty) {
        print('Therapist not found with the provided ID.');
        return false;
      }

      var therapistDoc = therapistQuery.docs.first;
      var therapistData = therapistDoc.data();
      List<String> bookedSlots =
          (therapistData['appointments'] as List<dynamic>?)
                  ?.where((appointment) => appointment['date'] == date)
                  ?.map((appointment) => appointment['time'] as String)
                  ?.toList() ??
              [];

      if (bookedSlots.contains(time)) {
        print('Time slot is already booked.');
        return false;
      }

      await _firestore
          .collection('therapist_appointments')
          .doc(therapistDoc.id)
          .update({
        'appointments': FieldValue.arrayUnion([
          {
            'parent_id': parentId,
            'date': date,
            'time': time,
            'status': 'pending',
          }
        ])
      });

      await _firestore.collection('children_appointments').doc(parentId).set({
        'appointments': FieldValue.arrayUnion([
          {
            'therapist_id': therapistId,
            'date': date,
            'time': time,
            'status': 'pending',
          }
        ])
      }, SetOptions(merge: true));

      print('Appointment booked successfully.');
      return true;
    } catch (e) {
      print('Error booking appointment: $e');
      return false;
    }
  }

  Future<bool> cancelAppointment({
    required String time,
    required String date,
  }) async {
    try {
      final String parentId = FirebaseAuth.instance.currentUser!.uid;
      final String? therapistId = userData?['doctor_id'];

      var therapistQuery = await _firestore
          .collection('therapist_appointments')
          .where('_id', isEqualTo: therapistId)
          .get();

      if (therapistQuery.docs.isEmpty) {
        print('Therapist not found.');
        return false;
      }
      var therapistDoc = therapistQuery.docs.first;
      var therapistData = therapistDoc.data();
      List<dynamic> appointments = therapistData['appointments'];
      var appointmentToCancel = appointments.firstWhere(
        (appointment) =>
            appointment['parent_id'] == parentId &&
            appointment['date'] == date &&
            appointment['time'] == time,
        orElse: () => null,
      );

      if (appointmentToCancel == null) {
        print('Appointment not found.');
        return false;
      }
      await _firestore
          .collection('therapist_appointments')
          .doc(therapistDoc.id)
          .update({
        'appointments': FieldValue.arrayRemove([appointmentToCancel]),
      });

      var parentDoc = await _firestore
          .collection('children_appointments')
          .doc(parentId)
          .get();

      if (parentDoc.exists) {
        List<dynamic> parentAppointments =
            parentDoc.data()?['appointments'] ?? [];
        var parentAppointmentToCancel = parentAppointments.firstWhere(
          (appointment) =>
              appointment['therapist_id'] == therapistId &&
              appointment['date'] == date &&
              appointment['time'] == time,
          orElse: () => null,
        );

        if (parentAppointmentToCancel != null) {
          await _firestore
              .collection('children_appointments')
              .doc(parentId)
              .update({
            'appointments': FieldValue.arrayRemove([parentAppointmentToCancel]),
          });
        }
      }

      print('Appointment canceled successfully.');
      return true;
    } catch (e) {
      print('Error canceling appointment: $e');
      return false;
    }
  }

  String getAppointmentDate(Map<String, dynamic> appointment) {
    try {
      if (appointment.containsKey('date')) {
        if (appointment['date'] is String) {
          return appointment['date'];
        }
        if (appointment['date'] is int) {
          final dateTime =
              DateTime.fromMillisecondsSinceEpoch(appointment['date']);
          return DateFormat('yyyy-MM-dd').format(dateTime);
        }
      }
      return 'Invalid Date';
    } catch (e) {
      return 'Error parsing date';
    }
  }
}
