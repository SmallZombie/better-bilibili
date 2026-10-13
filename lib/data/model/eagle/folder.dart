class Folder {
  final String id;
  final String name;
  final String description;
  final List<Folder> children;
  final String parent;
  final String pinyin;

  const Folder({
    required this.id,
    required this.name,
    required this.description,
    required this.children,
    required this.parent,
    required this.pinyin,
  });

  factory Folder.fromJson(Map<String, dynamic> obj) {
    return Folder(
      id: obj['id'],
      name: obj['name'],
      description: obj['description'],
      children: obj['children'],
      parent: obj['parent'],
      pinyin: obj['pinyin'],
    );
  }
}
