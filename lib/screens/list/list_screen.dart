import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/models/my_item.dart';
import 'package:lists/data/models/my_list.dart';
import 'package:lists/screens/home/home_screen.dart';
import 'package:lists/screens/list/search_delegate.dart';

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
  List<MyItem>? items;
  ItemBloc? itemBloc;

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)!.settings.arguments as ListScreenArguments;
    list = args.list;
    itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.setListId(list!.id!);

    return SafeArea(
      child: Scaffold(
        appBar: AppBar(
          title: Text(list!.title),
          actions: [
            IconButton(
              icon: Icon(Icons.search, color: Colors.white),
              onPressed: () {
                showSearch(
                  context: context,
                  delegate: MyItemSearchDelegate(items!, itemBloc),
                );
              },
            ),
            IconButton(
              icon: Icon(Icons.more_vert),
              onPressed: () {
                _bottomSheet();
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
                list!.description.isNotEmpty ? list!.description : "Lista Sem Descrição",
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            StreamBuilder<List<MyItem>>(
              stream: itemBloc!.items,
              builder: (context, snapshot) {
                if (snapshot.hasData) {
                  if (snapshot.data!.length == 0) {
                    return Center(
                      child: Container(
                        child: Text(
                          "Lista Vazia!",
                          style: Theme.of(context).textTheme.headline6,
                        ),
                      ),
                    );
                  }
                  int totalItems = 0;
                  double totalValue = 0;
                  items = snapshot.data;
                  snapshot.data!.forEach((element) {
                    totalItems += element.quantity;
                    totalValue += element.value * element.quantity;
                  });
                  return Expanded(
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Text("Valor", textAlign: TextAlign.left),
                              Text("R\$ $totalValue", textAlign: TextAlign.right),
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
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Oops, aconteceu um erro ao carregar lista",
                      style: Theme.of(context).textTheme.headline6,
                    ),
                  );
                } else {
                  return _buildLoading();
                }
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
            _actionCopy(),
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

  _actionCopy() {
    return ListTile(
      title: const Text("Copiar Lista"),
      leading: const Icon(Icons.copy),
      onTap: () async {
        String itemsText = await itemBloc!.getItemsToCopy();
        String shareText = "${list!.title}\n${list!.description}\n$itemsText";
        Clipboard.setData(ClipboardData(text: shareText));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Lista copiada para o clipboard!')),
        );
        Navigator.pop(context);
      },
    );
  }

  _actionShare() {
    return ListTile(
      title: const Text("Compartilhar Lista"),
      leading: const Icon(Icons.share),
      onTap: () async {
        List<Map<String, dynamic>> items = await itemBloc!.getItemsToShare();
        Map<String, dynamic> listMap = {'title': list!.title, 'description': list!.description, 'items': items};
        Clipboard.setData(ClipboardData(text: json.encode(listMap)));
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: const Text('Lista pronta para ser compartilhada, copiada para Clipboard!')),
        );
        Navigator.pop(context);
      },
    );
  }

  _buildItem(MyItem item) {
    return ListTile(
      title: Text(item.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Valor: R\$ ${item.value}"),
          Text("Quantidade: ${item.quantity}"),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final action = await Dialogs.yesAbortDialog(context, "Deletar?", "Você quer deletar o item ${item.name} ?");
          if (action == DialogAction.yes) {
            itemBloc!.delete(item.id!);
          }
        },
      ),
      trailing: Checkbox(
        value: item.checked == 1 ? true : false,
        onChanged: (bool? value) {
          item.checked = value! ? 1 : 0;
          itemBloc!.update(item);
        },
      ),
      onTap: () {
        _itemDialog(item);
      },
    );
  }

  _buildLoading() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.only(bottom: 16.0),
            child: Text(
              "Carregando Items",
              style: Theme.of(context).textTheme.subtitle1,
            ),
          ),
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).primaryColor,
            ),
          ),
        ],
      ),
    );
  }

  _itemDialog(MyItem? item) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController valueController = TextEditingController();
    String dialogTitle = "Novo Item";
    if (item != null) {
      nameController.text = item.name;
      quantityController.text = item.quantity.toString();
      valueController.text = item.value.toString();
      dialogTitle = "Editar Item";
    } else {
      quantityController.text = "1";
      valueController.text = "0";
    }
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          elevation: 24.0,
          shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20.0))),
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
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Valor",
                ),
              ),
              const SizedBox(height: 8),
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
                    valueController.text,
                  );
                } else {
                  item.name = nameController.text;
                  item.quantity = int.parse(quantityController.text);
                  item.value = double.parse(valueController.text);
                  _updateItem(item);
                }
              },
            ),
          ],
        );
      },
    );
  }

  _saveItem(name, quantity, value) {
    final itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.add(
      MyItem(
        name: name,
        quantity: int.parse(quantity),
        value: double.parse(value),
        listId: list!.id!,
      ),
    );
    Navigator.of(context).pop();
  }

  _updateItem(MyItem item) {
    final itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.update(item);
    Navigator.of(context).pop();
  }
}
