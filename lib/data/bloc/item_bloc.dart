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
