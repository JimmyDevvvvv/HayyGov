import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

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

  Future<String> login({required String email, required String password}) async {
    final apiKey = dotenv.env['FIREBASE_API_KEY'];
    final url = Uri.parse('https://identitytoolkit.googleapis.com/v1/accounts:signInWithPassword?key=$apiKey');
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

  void logout() {
    _authenticated = false;
    _token = "";
    _userId = "";
    _expiryDate = null;
    notifyListeners();
  }
}
