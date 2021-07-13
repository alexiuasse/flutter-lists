import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/models/my_list.dart';
import 'package:lists/screens/list/list_screen.dart';

/// HomeScreen will show all lists saved and have a floating button that can
/// add a new one. When click on a list it goes to a details screen. To
/// delete or edit a list it must go to details screen.
class HomeScreen extends StatefulWidget {
  static String routeName = "/home";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final listBloc = BlocProvider.of(context)?.listBloc;

    return WillPopScope(
      onWillPop: () async {
        final action = await Dialogs.yesAbortDialog(
            context, "Sair?", "Você quer sair do aplicativo?");
        return action == DialogAction.yes;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Minhas Listas"),
            actions: [
              IconButton(onPressed: _newListDialog, icon: Icon(Icons.add))
            ],
          ),
          body: StreamBuilder<List<MyList>>(
            stream: listBloc?.lists,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                if (!snapshot.hasError) {
                  if (snapshot.data?.length == 0) {
                    return Center(
                      child: Container(
                        child: Text(
                          "Nenhuma Lista Encontrada",
                          style: Theme.of(context).textTheme.subtitle1,
                        ),
                      ),
                    );
                  }
                  return ListView.separated(
                    separatorBuilder: (context, index) => Divider(),
                    itemCount: snapshot.data!.length,
                    physics: BouncingScrollPhysics(
                      parent: AlwaysScrollableScrollPhysics(),
                    ),
                    itemBuilder: (context, index) {
                      MyList item = snapshot.data![index];
                      return _buildList(item);
                    },
                  );
                }
              }
              return _buildLoading();
            },
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: _newListDialog,
          ),
        ),
      ),
    );
  }

  _buildList(MyList list) {
    return ListTile(
      title: Text(list.title),
      subtitle: Text(list.description),
      trailing: Icon(Icons.list),
      onTap: () {
        Navigator.pushNamed(
          context,
          ListScreen.routeName,
          arguments: ListScreenArguments(list),
        );
      },
    );
  }

  _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Carregando Listas",
          style: Theme.of(context).textTheme.subtitle1,
        ),
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            Theme.of(context).primaryColor,
          ),
        ),
      ],
    );
  }

  _newListDialog() {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text("Nova Lista"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: titleController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Título",
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: descController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Descrição",
                ),
              ),
            ],
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Salvar"),
              onPressed: () => _saveList(
                titleController.text,
                descController.text,
              ),
            ),
          ],
        );
      },
    );
  }

  _saveList(title, description) {
    final listBloc = BlocProvider.of(context)?.listBloc;
    listBloc!.add(MyList(title: title, description: description));
    Navigator.of(context).pop();
  }
}
