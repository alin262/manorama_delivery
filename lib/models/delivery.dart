class Delivery {
  final String id;
  final String shopId;
  final String bookId;
  final String bookName;
  final String shopName;
  final DateTime issueDate;
  final DateTime deliveryDate;
  final int quantity;
  final String type;
  Delivery({
    required this.id,
    required this.shopId,
    required this.bookId,
    required this.bookName,
    required this.deliveryDate,
    required this.issueDate,
    required this.quantity,
    required this.shopName,
    required this.type,
  });
  factory Delivery.fromFirestore(Map<String, dynamic> data, String id) {
    return Delivery(
      id: id,
      shopId: data['shopId'] ?? '',
      bookId: data['bookId']??'',
      bookName: data['bookName'] ?? '',
      deliveryDate: data['deliveryDate']!=null?DateTime.parse(data['deliveryDate']):DateTime.now(),
      issueDate: DateTime.parse(data['issueDate']),
      quantity: data['quantity']??0,
      shopName: data['shopName']??'',
      type: data['type'] ?? 'delivery',
    );
  }
  Map<String,dynamic> toFirestore(){
    return{
      'shopId': shopId,
      'bookId': bookId,
      'bookName': bookName,
      'shopName': shopName,
      'issueDate': issueDate.toIso8601String(),
      'deliveryDate': deliveryDate.toIso8601String(),
      'quantity': quantity,
      'type': type,
    };
  }
}
