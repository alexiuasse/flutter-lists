import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/models/my_item.dart';
import 'package:lists/data/models/my_list.dart';

//List Screen argument, the id of the list clicked
class ListScreenArguments {
  final MyList list;

  ListScreenArguments(this.list);
}

//Show a list with all items with a floating button to add new item
class ListScreen extends StatefulWidget {
  static String routeName = "/list";

  const ListScreen({Key? key}) : super(key: key);

  @override
  _ListScreenState createState() => _ListScreenState();
}

class _ListScreenState extends State<ListScreen> {
  MyList? list;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ListScreenArguments;
    list = args.list;
    var itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.setListId(list!.id!);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(list!.title),
          actions: [
            IconButton(
              icon: Icon(Icons.delete),
              onPressed: () async {
                final action = await Dialogs.yesAbortDialog(context, "Deletar?",
                    "Você quer deletar a lista ${list!.title}?");
                if (action == DialogAction.yes) {
                  BlocProvider.of(context)?.listBloc!.delete(list!.id!);
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                list!.description,
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Expanded(
              child: StreamBuilder<List<MyItem>>(
                stream: itemBloc.items,
                builder: (context, snapshot) {
                  if (snapshot.hasData) {
                    if (!snapshot.hasError) {
                      if (snapshot.data!.length == 0) {
                        return Center(
                          child: Container(
                            child: Text(
                              "Lista Vazia!",
                              style: Theme.of(context).textTheme.subtitle1,
                            ),
                          ),
                        );
                      }
                      return ListView.separated(
                        separatorBuilder: (context, index) => Divider(),
                        itemCount: snapshot.data!.length,
                        itemBuilder: (context, index) {
                          MyItem item = snapshot.data![index];
                          return _buildItem(item, itemBloc);
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
          onPressed: _newItemDialog,
        ),
      ),
    );
  }

  _buildItem(MyItem item, ItemBloc? itemBloc) {
    return CheckboxListTile(
      value: item.checked == 1 ? true : false,
      title: Text(item.name),
      subtitle: Text("Quantidade: ${item.quantity}"),
      secondary: IconButton(
        icon: Icon(Icons.delete),
        onPressed: () async {
          final action = await Dialogs.yesAbortDialog(
              context, "Deletar?", "Você quer deletar o item ${item.name} ?");
          if (action == DialogAction.yes) {
            itemBloc!.delete(item.id!);
          }
        },
      ),
      onChanged: (bool? value) {
        item.checked = value! ? 1 : 0;
        print(item.checked);
        itemBloc!.update(item);
      },
    );
  }

  _buildLoading() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Carregando Items",
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

  _newItemDialog() async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantController = TextEditingController();
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text("Novo Item"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              TextFormField(
                controller: quantController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Quantidade",
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
              onPressed: () => _saveItem(
                nameController.text,
                quantController.text,
              ),
            ),
          ],
        );
      },
    );
  }

  _saveItem(name, quantity) {
    final itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.add(MyItem(
      name: name,
      quantity: int.parse(quantity),
      listId: list!.id!,
    ));
    Navigator.of(context).pop();
  }
}
