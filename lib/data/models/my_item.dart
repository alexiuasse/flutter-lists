class MyItem {
  final int? id;
  final int listId;
  String name;
  int quantity;
  int checked;

  MyItem({
    this.id,
    required this.listId,
    required this.name,
    this.quantity = 0,
    this.checked = 0,
  });

  // Convert a Item into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'listId': listId,
      'name': name,
      'quantity': quantity,
      'checked': checked,
    };
  }

  // Implement toString to make it easier to see information about
  // each item when using the print statement.
  @override
  String toString() {
    return 'Item{id: $id, listId: $listId, name: $name, quantity: $quantity, '
        'checked: $checked}';
  }
}
