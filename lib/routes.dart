import 'package:flutter/material.dart';
import 'package:lists/screens/home/home_screen.dart';
import 'package:lists/screens/list/list_screen.dart';

final Map<String, WidgetBuilder> routes = {
  HomeScreen.routeName: (context) => HomeScreen(),
  ListScreen.routeName: (context) => ListScreen(),
};