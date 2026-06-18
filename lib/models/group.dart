class ShopGroup {
  final String id;
  final String name;
  final List<String> shopIds;

  ShopGroup({required this.id, required this.name, required this.shopIds});
  factory ShopGroup.fromFirestore(Map<String, dynamic> data, String id) {
    return ShopGroup(
      id: id,
      name: data['name'] ?? '',
      shopIds: List<String>.from(data['shopIds'] ?? []),
    );
  }
  Map<String, dynamic> toFirestore() {
    return {'name': name, 'shopIds': shopIds};
  }
}
