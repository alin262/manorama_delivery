import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shop.dart';
import '../models/book.dart';
import '../models/delivery.dart';
import '../services/firestore_service.dart';

class DeliveryQuery {
  final String shopId;
  final String type;
  const DeliveryQuery({required this.shopId, required this.type});

  @override
  bool operator ==(Object other) =>
      other is DeliveryQuery && other.shopId == shopId && other.type == type;

  @override
  int get hashCode => Object.hash(shopId, type);
}

final firestoreServiceProvider = Provider<FirestoreService>((ref) {
  return FirestoreService();
});

class ShopMonthQuery {
  final String shopId;
  final DateTime monthStart;
  final DateTime monthEnd;
  final String type;
  const ShopMonthQuery({
    required this.shopId,
    required this.monthStart,
    required this.monthEnd,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      other is ShopMonthQuery &&
      other.shopId == shopId &&
      other.monthStart == monthStart &&
      other.monthEnd == monthEnd &&
      other.type == type;

  @override
  int get hashCode => Object.hash(shopId, monthStart, monthEnd, type);
}

final shopMonthlyDeliveriesProvider =
    StreamProvider.family<List<Delivery>, ShopMonthQuery>((ref, query) {
      return ref
          .watch(firestoreServiceProvider)
          .getDeliveriesByShopAndMonth(
            query.shopId,
            query.monthStart,
            query.monthEnd,
            query.type,
          );
    });

class DateRangeQuery {
  final DateTime start;
  final DateTime end;
  final String type;
  const DateRangeQuery({
    required this.start,
    required this.end,
    required this.type,
  });

  @override
  bool operator ==(Object other) =>
      other is DateRangeQuery &&
      other.start == start &&
      other.end == end &&
      other.type == type;

  @override
  int get hashCode => Object.hash(start, end, type);
}

final shopsProvider = StreamProvider<List<Shop>>((ref) {
  return ref.watch(firestoreServiceProvider).getShops();
});

final booksProvider = StreamProvider<List<Book>>((ref) {
  return ref.watch(firestoreServiceProvider).getBooks();
});

final selectedShopIdProvider = StateProvider<String?>((ref) => null);

final selectedTypeProvider = StateProvider<String>((ref) => 'delivery');

final deliveriesProvider = StreamProvider.family<List<Delivery>, DeliveryQuery>(
  (ref, query) {
    return ref
        .watch(firestoreServiceProvider)
        .getDeliveries(query.shopId, query.type);
  },
);

final startDateProvider = StateProvider<DateTime?>((ref) => null);
final endDateProvider = StateProvider<DateTime?>((ref) => null);

final deliveriesByDateRangeProvider =
    StreamProvider.family<List<Delivery>, DateRangeQuery>((ref, query) {
      return ref
          .watch(firestoreServiceProvider)
          .getDeliveriesByDateRange(query.start, query.end, query.type);
    });

final syncStatusProvider = StateProvider<String>((ref) => 'idle');
