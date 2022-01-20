import 'package:flutter/material.dart';
import 'package:lists/components/dialogs.dart';
import 'package:lists/data/bloc/bloc_provider.dart';
import 'package:lists/data/bloc/item_bloc.dart';
import 'package:lists/data/models/my_item.dart';

class MyItemSearchDelegate extends SearchDelegate {
  final List<MyItem> items;
  final ItemBloc? itemBloc;

  MyItemSearchDelegate(this.items, this.itemBloc);

  @override
  String get searchFieldLabel => 'O que está procurando?';

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    if (query.length < 3) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Center(
            child: Text(
              "Pesquisa precisa ter pelo menos 3 caracteres.",
              style: Theme.of(context).textTheme.bodyText1,
            ),
          )
        ],
      );
    }

    return _buildItem(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return Container();
    }

    return _buildItem(context);
  }

  Widget _buildItem(BuildContext context) {
    List<Widget> _childrens = [];

    List<dynamic> containQuery =
        items.where((element) => element.name.toLowerCase().contains(query.toLowerCase())).toList();
    containQuery.forEach((cq) {
      _childrens.add(MyItemContainerSearch(cq));
    });

    if (_childrens.isEmpty) {
      return Center(child: Text("Nenhum item encontrado."));
    }

    return ListView.separated(
      itemCount: _childrens.length,
      separatorBuilder: (BuildContext context, int index) => Divider(),
      itemBuilder: (context, index) {
        return _childrens[index];
      },
    );
  }
}

class MyItemContainerSearch extends StatefulWidget {
  @required
  final MyItem item;

  const MyItemContainerSearch(this.item, {Key? key}) : super(key: key);

  @override
  _MyItemContainerSearchState createState() => _MyItemContainerSearchState();
}

class _MyItemContainerSearchState extends State<MyItemContainerSearch> {
  @override
  Widget build(BuildContext context) {
    ItemBloc? itemBloc;
    itemBloc = BlocProvider.of(context)?.itemBloc;

    return ListTile(
      title: Text(widget.item.name),
      subtitle: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Valor: R\$ ${widget.item.value}"),
          Text("Quantidade: ${widget.item.quantity}"),
        ],
      ),
      leading: IconButton(
        icon: Icon(Icons.delete, color: Colors.red),
        onPressed: () async {
          final action =
              await Dialogs.yesAbortDialog(context, "Deletar?", "Você quer deletar o item ${widget.item.name} ?");
          if (action == DialogAction.yes) {
            itemBloc!.delete(widget.item.id!);
          }
        },
      ),
      trailing: Checkbox(
        value: widget.item.checked == 1 ? true : false,
        onChanged: (bool? value) {
          widget.item.checked = value! ? 1 : 0;
          itemBloc!.update(widget.item);
        },
      ),
      onTap: () {
        _itemDialog(widget.item);
      },
    );
  }

  _itemDialog(MyItem? item) async {
    TextEditingController nameController = TextEditingController();
    TextEditingController quantityController = TextEditingController();
    TextEditingController valueController = TextEditingController();
    String dialogTitle = "Editar Item";
    nameController.text = item!.name;
    quantityController.text = item.quantity.toString();
    valueController.text = item.value.toString();
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
                decoration: InputDecoration(labelText: "Nome"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: valueController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Valor"),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: "Quantidade"),
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
                item.name = nameController.text;
                item.quantity = int.parse(quantityController.text);
                item.value = double.parse(valueController.text);
                _updateItem(item);
              },
            ),
          ],
        );
      },
    );
  }

  _updateItem(MyItem item) {
    final itemBloc = BlocProvider.of(context)?.itemBloc;
    itemBloc!.update(item);
    Navigator.of(context).pop();
  }
}
