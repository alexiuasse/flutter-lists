import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/screens/list/list_screen.dart';

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

    final bloc = BlocProvider.of(context);
    final listBloc = bloc?.listBloc;
    print("Bloc: $bloc, ListBloc: $listBloc, Lists: ${listBloc?.lists}");

    return WillPopScope(
      onWillPop: () async {
        final action = await Dialogs.yesAbortDialog(
            context, "Sair?", "Você quer sair do aplicativo?");
        return action == DialogAction.yes;
      },
      child: SafeArea(
        child: Scaffold(
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.list),
            onPressed: () {
              Navigator.pushNamed(
                context,
                ListScreen.routeName,
                arguments: ListScreenArguments(0),
              );
            },
          ),
        ),
      ),
    );
  }
}
