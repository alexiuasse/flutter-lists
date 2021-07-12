import 'dart:async';

import 'package:lists/data/models/my_list.dart';

import '../database.dart';

class ListBloc {
  ListBloc() {
    getLists();
  }

  final _controller = StreamController<List<MyList>>.broadcast();

  get lists => _controller.stream;

  dispose() {
    _controller.close();
  }

  getLists() async {
    _controller.sink.add(await DBProvider.db.getAllLists());
  }

  delete(int id) {
    DBProvider.db.deleteList(id);
    getLists();
  }

  update(MyList list) {
    DBProvider.db.updateList(list);
    getLists();
  }

  add(MyList list) {
    DBProvider.db.insertList(list);
    getLists();
  }
}
