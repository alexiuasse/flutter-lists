import 'package:flutter/material.dart';

//List Screen argument, the id of the list clicked
class ListScreenArguments {
  final int id;

  ListScreenArguments(this.id);
}

//Show a list with all items with a floating button to add new item
class ListScreen extends StatelessWidget {
  static String routeName = "/list";

  const ListScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as
    ListScreenArguments;

    return Center(
      child: Text(args.id.toString()),
    );
  }
}
