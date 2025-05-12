import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthProvider with ChangeNotifier {
  String _token = "";
  String _userId = "";
  bool _authenticated = false;
  DateTime? _expiryDate;

  bool get isAuthenticated => _authenticated;

  String get token {
    if (_expiryDate != null && _expiryDate!.isAfter(DateTime.now()) && _token.isNotEmpty) {
      return _token;
    }
    return "";
  }

  String get userId => _userId;

  Future<String> signup({required String email, required String password}) async {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');
    try {
      final response = await http.post(url, body: json.encode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }));
      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        return responseData['error']['message'];
      }
      _authenticated = true;
      _token = responseData['idToken'];
      _userId = responseData['localId'];
      _expiryDate = DateTime.now().add(Duration(seconds: int.parse(responseData['expiresIn'])));
      notifyListeners();
      return "success";
    } catch (err) {
      return err.toString();
    }
  }

  Future<void> signUpCitizen(String email, String password) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Ensure Firestore is initialized before adding data
      FirebaseFirestore firestore = FirebaseFirestore.instance;

      print("Storing user data in Firestore with role: citizen");
      await firestore.collection('users').doc(uid).set({
        'email': email,
        'role': 'citizen',
        'createdAt': FieldValue.serverTimestamp(),
      }).then((_) {
        print("Citizen data successfully added to Firestore.");
      }).catchError((error) {
        print("Failed to add citizen data to Firestore: $error");
      });

      print("Citizen account created!");
    } catch (e) {
      print("Error signing up: $e");
    }
  }

  Future<String> signUpWithRole({required String email, required String password, required String role}) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .createUserWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      // Store user with selected role
      await FirebaseFirestore.instance.collection('users').doc(uid).set({
        'email': email,
        'role': role,
        'createdAt': FieldValue.serverTimestamp(),
      });

      print("User with role $role successfully added to Firestore.");
      return "success";
    } catch (e) {
      print("Error signing up with role: $e");
      return e.toString();
    }
  }

  Future<void> login(String email, String password, BuildContext context) async {
    try {
      UserCredential userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      String uid = userCredential.user!.uid;

      print("Fetching user role from Firestore for UID: $uid");
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        print("User record not found in Firestore. Adding default citizen record.");
        await FirebaseFirestore.instance.collection('users').doc(uid).set({
          'email': email,
          'role': 'citizen', // Default role
          'createdAt': FieldValue.serverTimestamp(),
        });
      }

      userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get()
          .catchError((error) {
            print("Failed to fetch user role: $error");
            return FirebaseFirestore.instance.collection('users').doc(uid).get();
          });

      if (userDoc.exists) {
        String role = userDoc['role'];
        print("User role fetched: $role");

        if (role == 'citizen') {
          Navigator.pushReplacementNamed(context, '/citizenHome');
        } else if (role == 'government') {
          Navigator.pushReplacementNamed(context, '/govDashboard');
        } else if (role == 'advertiser') {
          Navigator.pushReplacementNamed(context, '/advertiserDashboard');
        } else {
          print("Unknown role.");
        }
      } else {
        print("User record not found in Firestore.");
      }
    } catch (e) {
      print("Login failed: $e");
    }
  }

  void logout() {
    _authenticated = false;
    _token = "";
    _userId = "";
    _expiryDate = null;
    notifyListeners();
  }
}
