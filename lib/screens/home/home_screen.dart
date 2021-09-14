import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/bloc/list_bloc.dart';
import 'package:lists/data/models/my_item.dart';
import 'package:lists/data/models/my_list.dart';
import 'package:lists/screens/list/list_screen.dart';
import 'package:lists/utils/utils.dart';

/// HomeScreen will show all lists saved and have a floating button that can
/// add a new one. When click on a list it goes to a details screen. To
/// delete or edit a list it must go to details screen.
class HomeScreen extends StatefulWidget {
  static String routeName = "/";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final listBloc = BlocProvider.of(context)?.listBloc;

    return WillPopScope(
      onWillPop: () async {
        final action = await Dialogs.yesAbortDialog(context, "Sair?", "Você quer sair do aplicativo?");
        return action == DialogAction.yes;
      },
      child: SafeArea(
        child: Scaffold(
          appBar: AppBar(
            title: Text("Minhas Listas"),
            actions: [
              IconButton(
                onPressed: () => _listDialog(null),
                icon: Icon(Icons.add),
              ),
              IconButton(
                onPressed: () => _addListFromString(),
                icon: Icon(Icons.list),
              ),
            ],
          ),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Para editar uma lista basta manter pressionado sobre a "
                  "lista desejada",
                  style: Theme.of(context).textTheme.bodyText1!.copyWith(color: Colors.grey),
                ),
              ),
              Expanded(
                child: StreamBuilder<List<MyList>>(
                  stream: listBloc?.lists,
                  builder: (context, snapshot) {
                    if (snapshot.hasData) {
                      if (!snapshot.hasError) {
                        if (snapshot.data?.length == 0) {
                          return Center(
                            child: Container(
                              child: Text(
                                "Nenhuma Lista Encontrada",
                                style: Theme.of(context).textTheme.headline6,
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
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton(
            child: Icon(Icons.add),
            onPressed: () {
              _listDialog(null);
            },
          ),
        ),
      ),
    );
  }

  _buildList(MyList list) {
    String description = "Sem Descrição";
    if (list.description.isNotEmpty) {
      description = list.description;
    }
    return ListTile(
      title: Text(list.title),
      subtitle: Text(description),
      trailing: Icon(Icons.list),
      onTap: () {
        Navigator.pushNamed(
          context,
          ListScreen.routeName,
          arguments: ListScreenArguments(list),
        );
      },
      onLongPress: () {
        _listDialog(list);
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

  _listDialog(MyList? list) {
    TextEditingController titleController = TextEditingController();
    TextEditingController descController = TextEditingController();
    String dialogTitle = "Nova Lista";
    if (list != null) {
      titleController.text = list.title;
      descController.text = list.description;
      dialogTitle = "Editar Lista";
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: titleController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Título",
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              TextField(
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
              onPressed: () {
                if (list == null) {
                  _saveList(
                    titleController.text,
                    descController.text,
                  );
                } else {
                  list.title = titleController.text;
                  list.description = descController.text;
                  _updateList(list);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _addListFromString() {
    TextEditingController listStringController = TextEditingController();
    String dialogTitle = "Nova Lista";
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(dialogTitle),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  autofocus: true,
                  controller: listStringController,
                  autocorrect: false,
                  maxLines: null,
                  keyboardType: TextInputType.multiline,
                  decoration: InputDecoration(
                    labelText: "Lista",
                    fillColor: Colors.white,
                    helperMaxLines: 2,
                    helperText: "Cole aqui uma lista que foi gerada pelo aplicativo, na ação de compartilhar!",
                  ),
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text("Fechar"),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text("Salvar"),
              onPressed: () => _createList(listStringController.text),
            ),
          ],
        );
      },
    );
  }

  _createList(String list) {
    if (list.length > 0) {
      final listBloc = BlocProvider.of(context)?.listBloc;
      final itemBloc = BlocProvider.of(context)?.itemBloc;
      Map<String, dynamic> listMap = json.decode(list);
      listBloc!.add(MyList(title: listMap['title'], description: listMap['description']));
      listBloc.getLatestList().then((listObj) {
        if (listObj != null) {
          listMap['items'].forEach((item) {
            itemBloc!.add(
              MyItem(
                name: item['name'],
                quantity: item['quantity'],
                checked: item['checked'],
                value: item['value'] == null ? 0.0 : item['value'].toDouble(),
                listId: listObj.id!,
              ),
            );
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: const Text('Lista criada com sucesso!')),
          );
        }
        Navigator.of(context).pop();
      });
    }
  }

  _saveList(title, description) {
    final listBloc = BlocProvider.of(context)?.listBloc;
    listBloc!.add(MyList(title: title, description: description));
    Navigator.of(context).pop();
  }

  _updateList(MyList list) {
    final listBloc = BlocProvider.of(context)?.listBloc;
    listBloc!.update(list);
    Navigator.of(context).pop();
  }
}
