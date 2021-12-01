import 'dart:async';

import 'package:lists/data/models/my_item.dart';

import '../database.dart';

class ItemBloc {
  int _listId = 0;

  final _controller = StreamController<List<MyItem>>.broadcast();

  get items => _controller.stream;

  dispose() {
    _controller.close();
  }

  setListId(int listId) {
    _listId = listId;
    getItems();
  }

  getItems() async {
    if (_listId == 0) {
      print('listId is zero, please pass the listId parameter using setListId');
    } else {
      _controller.sink.add(await DBProvider.db.getAllItems(_listId));
    }
  }

  Future<String> getItemsToCopy() async {
    String text = "";
    List<MyItem> items = await DBProvider.db.getAllItems(_listId);
    items.forEach((element) {
      text += "${element.quantity}x ${element.name} R\$ ${element.value * element.quantity}\n";
    });
    return text;
  }

  Future<List<Map<String, dynamic>>> getItemsToShare() async {
    List<Map<String, dynamic>> itemsMap = await DBProvider.db.getAllItemsAsMap(_listId);
    return itemsMap;
  }

  delete(int id) {
    DBProvider.db.deleteItem(id);
    getItems();
  }

  update(MyItem item) {
    DBProvider.db.updateItem(item);
    getItems();
  }

  add(MyItem item) {
    DBProvider.db.insertItem(item);
    getItems();
  }
}
