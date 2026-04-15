import 'package:flutter/material.dart';
import 'recipe_element.dart';

class Recipe {
  List<RecipeElement> recipes;
  int total;
  int skip;
  int limit;

  Recipe({
    required this.recipes,
    required this.total,
    required this.skip,
    required this.limit,
  });

  factory Recipe.fromJson(Map<String, dynamic> json) => Recipe(
    recipes: List<RecipeElement>.from(json["recipes"].map((x) => RecipeElement.fromJson(x))),
    total: json["total"],
    skip: json["skip"],
    limit: json["limit"],
  );

  Map<String, dynamic> toJson() => {
    "recipes": List<dynamic>.from(recipes.map((x) => x.toJson())),
    "total": total,
    "skip": skip,
    "limit": limit,
  };
}