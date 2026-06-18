class Book {
  final String name;
  final String id;
  final double price;
  Book({required this.name, required this.id, required this.price});
  factory Book.fromFirestore(Map<String, dynamic> data, String id) {
    return Book(
      name: data['name'] ?? '',
      id: id,
      price:  (data['price'] ?? 0).toDouble(),
    );
  }
  Map<String,dynamic> toFirestore(){
    return{
      'name':name,
      'price':price
    };
  }
}
