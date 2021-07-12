import 'package:flutter/material.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/models/my_list.dart';

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
    final args =
        ModalRoute.of(context)!.settings.arguments as ListScreenArguments;

    var bloc = BlocProvider.of(context)?.listBloc;

    return SafeArea(
      child: Scaffold(
        body: Center(
          child: StreamBuilder<List<MyList>>(
            stream: bloc?.lists,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (!snapshot.hasError) {
                  return ListView.builder(
                    itemCount: snapshot.data?.length,
                    itemBuilder: (context, index) {
                      MyList item = snapshot.data![index];
                      return Text(item.toString());
                    },
                  );
                }
              }
              return Container();
            },
          )
        ),
      ),
    );
  }
}
