import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import '../models/http_exception.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Auth with ChangeNotifier {
  String _token;
  DateTime _expiryDate;
  String _userId;
  //bool _isAuthen;
  Timer _authTimer;

  String get userID {
    return _userId;
  }

  bool get isAuth {
    return token != null;
  }

  String get token {
    if (_expiryDate != null &&
        _expiryDate.isAfter(DateTime.now()) &&
        _token != null) {
      return _token;
    }

    return null;
  }

  static const params = {'key': 'AIzaSyBMomHhQ7FzvDHXp5EUYoDF_hYbEoBY9EE'};

  Future<void> _authenticate(
      String email, String password, String urlSegment) async {
    final url = Uri.https(
        'identitytoolkit.googleapis.com', '/v1/accounts:$urlSegment', params);
    try {
      final response = await http.post(url,
          body: json.encode({
            'email': email,
            'password': password,
            'returnSecureToken': true,
          }));

      final responseData = json.decode(response.body);
      if (responseData['error'] != null) {
        throw HttpException(responseData['error']['message']);
      }

      _token = responseData['idToken'];
      _expiryDate = DateTime.now()
          .add(Duration(seconds: int.parse(responseData['expiresIn'])));
      _userId = responseData['localId'];
      autoLogOut();
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      final prefData = json.encode({
        'token': _token,
        'userId': _userId,
        'expiryDate': _expiryDate.toIso8601String()
      });
      prefs.setString('userData', prefData);
    } catch (error) {
      throw error;
    }
  }

  Future<void> signup(String email, String password) async {
    // final url = Uri.https(
    //     'identitytoolkit.googleapis.com', '/v1/accounts:signUp', params);

    return _authenticate(email, password, 'signUp');
  }

  Future<void> login(String email, String password) async {
    return _authenticate(email, password, 'signInWithPassword');
    // final loginUrl = Uri.https('identitytoolkit.googleapis.com',
    //     '/v1/accounts:signInWithPassword', params);

    // final response = await http.post(loginUrl,
    //     body: json.encode({
    //       'email': email,
    //       'password': password,
    //       'returnSecureToken':true,
    //     }));
  }

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();

    if (!prefs.containsKey('userData')) {
      return false;
    }
    final extractedUserData =
        json.decode(prefs.getString('userData')); //as Map<String,Object>;
    var expiryDate = DateTime.parse(extractedUserData['expiryDate']);
    if (expiryDate.isBefore(DateTime.now())) {
      return false;
    }
    _token = extractedUserData['token'];
    _expiryDate = expiryDate;
    _userId = extractedUserData['userId'];
    notifyListeners();
    autoLogOut();
    return true;
  }

  Future<void> logOut() async {
    _token = null;
    _expiryDate = null;
    _userId = null;
    if (_authTimer != null) {
      _authTimer.cancel();
      _authTimer = null;
    }
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    // prefs.remove('userData');  //if we want to remove specific stored data from device
    prefs
        .clear(); // removes all data stored via sharedPreferences on our local device storage
  }

  void autoLogOut() {
    if (_authTimer != null) {
      _authTimer.cancel();
    }
    final timeToExpiry = _expiryDate.difference(DateTime.now()).inSeconds;
    _authTimer = Timer(Duration(seconds: timeToExpiry), logOut);
  }
}
