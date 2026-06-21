import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop.dart';
import '../models/group.dart';
import '../models/book.dart';
import '../models/delivery.dart';
import '../services/firestore_service.dart';


final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});



final shopsProvider = StreamProvider<List<Shop>>((ref) {
  return ref.watch(firestoreServiceProvider).getShops();
});



final groupsProvider = StreamProvider<List<ShopGroup>>((ref) {
  return ref.watch(firestoreServiceProvider).getGroups();
});



final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(firestoreServiceProvider).getBooks();
});


final selectedShopIdProvider = StateProvider<String?>((ref) => null);


final selectedTypeProvider = StateProvider<String>((ref) => 'delivery');

final deliveriesProvider = StreamProvider.family<List<Delivery>, Map<String, String>>((ref, params) {
  return ref.watch(firestoreServiceProvider).getDeliveries(
    params['shopId']!,
    params['type']!,
  );
});

final startDateProvider = StateProvider<DateTime?>((ref) => null);
final endDateProvider = StateProvider<DateTime?>((ref) => null);

final deliveriesByDateRangeProvider = StreamProvider.family<List<Delivery>, Map<String, dynamic>>((ref, params) {
  return ref.watch(firestoreServiceProvider).getDeliveriesByDateRange(
    params['start'] as DateTime,
    params['end'] as DateTime,
    params['type'] as String,
  );
});

final syncStatusProvider = StateProvider<String>((ref) => 'idle');