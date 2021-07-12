import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';

// Navigator.pushNamed(
// context,
// ExtractArgumentsScreen.routeName,
// arguments: ScreenArguments(
// 'Extract Arguments Screen',
// 'This message is extracted in the build method.',
// ),
// );

class HomeScreen extends StatelessWidget {
  static String routeName = "/home";

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final action = await Dialogs.yesAbortDialog(
            context, "Sair?", "Você quer sair do aplicativo?");
        return action == DialogAction.yes;
      },
      child: SafeArea(
        child: Container(),
      ),
    );
  }
}
