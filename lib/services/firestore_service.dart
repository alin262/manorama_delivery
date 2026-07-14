import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:manorama_delivery/models/book.dart';
import 'package:manorama_delivery/models/delivery.dart';
import 'package:manorama_delivery/models/shop.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;


Stream<List<Delivery>> getDeliveriesByDate(String date, String type) {
  return _db
      .collection('deliveries')
      .where('type', isEqualTo: type)
      .where('deliveryDate', isGreaterThanOrEqualTo: date)
      .where('deliveryDate', isLessThanOrEqualTo: date + 'z')
      .snapshots()
      .map((snaps) => snaps.docs
          .map((e) => Delivery.fromFirestore(e.data(), e.id))
          .toList());
}

  Stream<List<Shop>> getShops() {
    return _db
        .collection('shops')
        .snapshots()
        .map(
          (snap) => snap.docs
              .map((docs) => Shop.fromFirestore(docs.data(), docs.id))
              .toList(),
        );
  }

  Future<void> addShop(Shop shop) async {
    await _db.collection('shops').add(shop.toFirestore());
  }

  Future<void> updateShop(Shop shop) async {
    await _db.collection('shops').doc(shop.id).update(shop.toFirestore());
  }

  Future<void> deleteShop(String shopId) async {
    await _db.collection('shops').doc(shopId).delete();
  }

  Stream<List<Book>> getBooks() {
    return _db
        .collection('books')
        .snapshots()
        .map(
          (snaps) => snaps.docs
              .map((e) => Book.fromFirestore(e.data(), e.id))
              .toList(),
        );
  }

  Future<void> addBook(Book book) async {
    await _db.collection('books').add(book.toFirestore());
  }

  Future<void> updateBook(Book book) async {
    await _db.collection('books').doc(book.id).update(book.toFirestore());
  }

  Future<void> deleteBook(String bookId) async {
    await _db.collection('books').doc(bookId).delete();
  }

  Stream<List<Delivery>> getDeliveries(String shopId, String type) {
    return _db
        .collection('deliveries')
        .where('shopId', isEqualTo: shopId)
        .where('type', isEqualTo: type)
        .snapshots()
        .map(
          (snaps) => snaps.docs
              .map((e) => Delivery.fromFirestore(e.data(), e.id))
              .toList(),
        );
  }

  Future<void> addDelivery(Delivery delivery) async {
    await _db.collection('deliveries').add(delivery.toFirestore());
  }

  Future<void> updateDelivery(Delivery delivery) async {
    await _db
        .collection('deliveries')
        .doc(delivery.id)
        .update(delivery.toFirestore());
  }

  Future<void> deleteDelivery(String deliveryId) async {
    await _db.collection('deliveries').doc(deliveryId).delete();
  }

  Stream<List<Delivery>> getDeliveriesByDateRange(
    DateTime start,
    DateTime end,
    String type,
  ) {
    return _db
        .collection('deliveries')
        .where("type", isEqualTo: type)
        .where('deliveryDate', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('deliveryDate', isLessThanOrEqualTo: end.toIso8601String())
        .snapshots()
        .map(
          (snaps) => snaps.docs
              .map((e) => Delivery.fromFirestore(e.data(), e.id))
              .toList(),
        );
  }

  Stream<List<Delivery>> getDeliveriesByShopAndMonth(
    String shopId, DateTime monthStart, DateTime monthEnd, String type) {
    return _db
        .collection('deliveries')
        .where('shopId', isEqualTo: shopId)
        .where('type', isEqualTo: type)
        .where('issueDate', isGreaterThanOrEqualTo: monthStart.toIso8601String())
        .where('issueDate', isLessThanOrEqualTo: monthEnd.toIso8601String())
        .snapshots()
        .map((snaps) => snaps.docs
            .map((e) => Delivery.fromFirestore(e.data(), e.id))
            .toList());
  }
}