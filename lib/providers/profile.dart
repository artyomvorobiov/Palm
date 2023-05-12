import 'package:flutter/material.dart';

class Profile {
  final String id;
  final String firstName;
  final String lastName;
  final String username;
  final String description;
  final String email;
  final String age;
  final String male;
  static int countOfEvents = 0;

  Profile({
    @required this.id,
    @required this.firstName,
    @required this.lastName,
    @required this.username,
    @required this.description,
    @required this.email,
    @required this.age,
    @required this.male,
  });
}
