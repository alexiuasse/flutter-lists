import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/models/my_item.dart';
import 'package:lists/data/models/my_list.dart';
import 'package:flutter/services.dart';
import 'package:lists/screens/home/home_screen.dart';

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
  ItemBloc? itemBloc;

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)!.settings.arguments as ListScreenArguments;
    list = args.list;
    itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.setListId(list!.id!);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(list!.title),
          actions: [
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _bottomSheet();
              },
            )
          ],
        ),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                list!.description.isNotEmpty
                    ? list!.description
                    : "Sem Descrição",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            StreamBuilder<List<MyItem>>(
              stream: itemBloc!.items,
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
                    int totalItems = 0;
                    snapshot.data!.forEach((element) {
                      totalItems += element.quantity;
                    });
                    return Expanded(
                      child: Column(
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Text("Quantidade", textAlign: TextAlign.left),
                                Text("$totalItems", textAlign: TextAlign.right)
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.separated(
                              separatorBuilder: (context, index) => Divider(),
                              itemCount: snapshot.data!.length,
                              itemBuilder: (context, index) {
                                MyItem item = snapshot.data![index];
                                return _buildItem(item);
                              },
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                }
                return _buildLoading();
              },
            ),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          child: Icon(Icons.add),
          onPressed: () {
            _itemDialog(null);
          },
        ),
      ),
    );
  }

  _bottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _actionDelete(),
            _actionShare(),
          ],
        );
      },
    );
  }

  _actionDelete() {
    return ListTile(
      title: const Text("Deletar Lista"),
      leading: const Icon(Icons.delete),
      onTap: () async {
        final action = await Dialogs.yesAbortDialog(
          context,
          "Deletar?",
          "Você quer deletar a lista ${list!.title}?",
        );
        if (action == DialogAction.yes) {
          BlocProvider.of(context)?.listBloc!.delete(list!.id!);
          Navigator.popUntil(
            context,
            ModalRoute.withName(HomeScreen.routeName),
          );
        }
      },
    );
  }

  _actionShare() {
    return ListTile(
      title: const Text("Copiar Lista"),
      leading: const Icon(Icons.copy),
      onTap: () async {
        String itemsText = await itemBloc!.getItemsAsText();
        String shareText = "${list!.title} - ${list!.description}\n$itemsText";
        Clipboard.setData(ClipboardData(text: shareText));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Lista copiada para o clipboard!')),
        );
        Navigator.pop(context);
      },
    );
  }

  _buildItem(MyItem item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Text("Quantidade: ${item.quantity}"),
      leading: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final action = await Dialogs.yesAbortDialog(
              context, "Deletar?", "Você quer deletar o item ${item.name} ?");
          if (action == DialogAction.yes) {
            itemBloc!.delete(item.id!);
          }
        },
      ),
      trailing: Checkbox(
        value: item.checked == 1 ? true : false,
        onChanged: (bool? value) {
          item.checked = value! ? 1 : 0;
          print(item.checked);
          itemBloc!.update(item);
        },
      ),
      onTap: () {
        _itemDialog(item);
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

  _itemDialog(MyItem? item) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    String dialogTitle = "Novo Item";
    if (item != null) {
      nameController.text = item.name;
      quantityController.text = item.quantity.toString();
      dialogTitle = "Editar Item";
    } else {
      quantityController.text = "1";
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(20.0))),
          title: Text(dialogTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                autofocus: true,
                controller: nameController,
                keyboardType: TextInputType.text,
                decoration: InputDecoration(
                  labelText: "Nome",
                  fillColor: Colors.white,
                ),
              ),
              SizedBox(height: 8),
              TextField(
                controller: quantityController,
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
                onPressed: () {
                  if (item == null) {
                    _saveItem(
                      nameController.text,
                      quantityController.text,
                    );
                  } else {
                    item.name = nameController.text;
                    item.quantity = int.parse(quantityController.text);
                    _updateItem(item);
                  }
                }),
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

  _updateItem(MyItem item) {
    final itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.update(item);
    Navigator.of(context).pop();
  }
}
