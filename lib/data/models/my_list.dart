class MyList {
  final int? id;
  String title;
  String description;

  MyList({
    this.id,
    required this.title,
    this.description = '',
  });

  // Convert a List into a Map. The keys must correspond to the names of the
  // columns in the database.
  Map<String, dynamic> toMap() => {
        'id': id,
        'title': title,
        'description': description,
      };

  MyList.fromMap(Map<String, dynamic> map)
      : id = map['id'],
        title = map['title'],
        description = map['description'];

  // Implement toString to make it easier to see information about
  // each list when using the print statement.
  @override
  String toString() {
    return 'List{id: $id, title: $title, description: $description}';
  }
}
