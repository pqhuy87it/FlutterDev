import 'package:flutter/material.dart';
import '../json/model/recipe.dart';
import 'package:flutter/services.dart';
import 'dart:convert';

Future<List<Recipe>> readJsonListData() async {
  final String jsonString = await rootBundle.loadString('assets/users_data.json');

  // Parse chuỗi JSON thành một List<dynamic>
  final List<dynamic> data = jsonDecode(jsonString);

  // Dùng map để chuyển đổi từng item trong list thành một đối tượng User
  return data.map((json) => Recipe.fromJson(json)).toList();
}