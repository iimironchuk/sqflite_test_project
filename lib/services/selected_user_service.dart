import 'package:flutter/material.dart';

class AppNotifier with ChangeNotifier{
  int? _selectedUser;

  void setUser(int userId){
    _selectedUser = userId;
    notifyListeners();
  }

  int? getUser(){
    return _selectedUser;
  }

  void logOut(){
    _selectedUser = null;
  }
}