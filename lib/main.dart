import 'package:flutter/widgets.dart';

import 'package:flutter/material.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/bloc/list_bloc.dart';
import 'package:lists/routes.dart';
import 'package:lists/screens/home/home_screen.dart';
import 'package:google_fonts/google_fonts.dart';

import 'data/bloc/bloc_provider.dart';

void main() {
  // Avoid errors caused by flutter upgrade.
  // Importing 'package:flutter/widgets.dart' is required.
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    BlocProvider(
      listBloc: ListBloc(),
      itemBloc: ItemBloc(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Minhas Listas',
      theme: ThemeData(
        textTheme: GoogleFonts.montserratTextTheme(Theme.of(context).textTheme),
        primarySwatch: Colors.blue,
      ),
      routes: routes,
    );
  }
}
