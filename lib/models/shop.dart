class Shop {
  final String id;
  final String name;

  Shop({
    required this.id,
    required this.name,
  });

  factory Shop.fromFirestore(Map<String, dynamic> data, String id) {
    return Shop(
      id: id,
      name: data['name'] ?? '',
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
    };
  }
}