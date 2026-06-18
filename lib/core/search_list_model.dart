import 'package:flutter/material.dart';

class SearchListModel<T> extends ChangeNotifier {
  List<T> data = [];

  SearchListModel();

  void setData(List<T> dt) {
    data = dt;
    notifyListeners();
  }

  List<T> getData() {
    return data;
  }
  
  void updateList() {
    notifyListeners();
  }
}