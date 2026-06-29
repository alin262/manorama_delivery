import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/shop.dart';
import '../models/delivery.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../widgets/sync_status_dot.dart';
import 'add_entry_screen.dart';

class ShopDetailScreen extends ConsumerStatefulWidget {
  final Shop shop;
  final String type;

  const ShopDetailScreen({
    super.key,
    required this.shop,
    required this.type,
  });

  @override
  ConsumerState<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends ConsumerState<ShopDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  DateTime? _filterDate;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop.name),
        actions: [
          const Padding(
            padding: EdgeInsets.only(right: 8),
            child: Center(child: SyncStatusDot()),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list_rounded),
            onPressed: () async {
              final picked = await showDatePicker(
                context: context,
                initialDate: DateTime.now(),
                firstDate: DateTime(2020),
                lastDate: DateTime.now(),
              );
              setState(() => _filterDate = picked);
            },
          ),
          if (_filterDate != null)
            IconButton(
              icon: const Icon(Icons.clear_rounded),
              onPressed: () => setState(() => _filterDate = null),
            ),
        ],
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Delivery'),
            Tab(text: 'Returns'),
          ],
          indicatorColor: AppTheme.primary,
          labelColor: AppTheme.primary,
          unselectedLabelColor: AppTheme.textSecondary,
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _buildEntryList('delivery'),
          _buildEntryList('return'),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final type =
              _tabController.index == 0 ? 'delivery' : 'return';
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryScreen(
                shop: widget.shop,
                type: type,
              ),
            ),
          );
        },
        backgroundColor: AppTheme.primary,
        child: const Icon(Icons.add_rounded, color: Colors.white),
      ),
    );
  }

  Widget _buildEntryList(String type) {
    final deliveriesAsync = ref.watch(
  deliveriesProvider(DeliveryQuery(shopId: widget.shop.id, type: type)),
);
print('Shop ID: ${widget.shop.id}, Type: $type, State: $deliveriesAsync');
    return deliveriesAsync.when(
      data: (deliveries) {
        // Apply date filter
        final filtered = _filterDate == null
            ? deliveries
            : deliveries.where((d) {
                return d.deliveryDate.year == _filterDate!.year &&
                    d.deliveryDate.month == _filterDate!.month &&
                    d.deliveryDate.day == _filterDate!.day;
              }).toList();

        if (filtered.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  type == 'delivery'
                      ? Icons.local_shipping_outlined
                      : Icons.assignment_return_outlined,
                  size: 64,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(height: 16),
                Text(
                  _filterDate != null
                      ? 'No entries for this date'
                      : 'No ${type}s yet',
                  style: GoogleFonts.inter(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Tap + to add an entry',
                  style: GoogleFonts.inter(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          );
        }

        // Group entries by date
        final grouped = <String, List<Delivery>>{};
        for (final d in filtered) {
          final key = DateFormat('dd MMM yyyy').format(d.deliveryDate);
          grouped.putIfAbsent(key, () => []).add(d);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: grouped.length,
          itemBuilder: (context, index) {
            final date = grouped.keys.elementAt(index);
            final entries = grouped[date]!;

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Date header
                Padding(
                  padding: const EdgeInsets.only(bottom: 8, top: 4),
                  child: Text(
                    date,
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
                // Entries for that date
                ...entries.map((delivery) => _buildEntryCard(delivery)),
                const SizedBox(height: 8),
              ],
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildEntryCard(Delivery delivery) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Dismissible(
        key: Key(delivery.id),
        direction: DismissDirection.endToStart,
        background: Container(
          alignment: Alignment.centerRight,
          padding: const EdgeInsets.only(right: 20),
          decoration: BoxDecoration(
            color: AppTheme.danger,
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.delete_rounded, color: Colors.white),
        ),
        confirmDismiss: (_) async {
          return await showDialog(
            context: context,
            builder: (_) => AlertDialog(
              title: const Text('Delete Entry'),
              content: Text('Delete ${delivery.bookName} entry?'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Delete',
                      style: TextStyle(color: AppTheme.danger)),
                ),
              ],
            ),
          );
        },
        onDismissed: (_) {
          ref.read(firestoreServiceProvider).deleteDelivery(delivery.id);
        },
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddEntryScreen(
                shop: widget.shop,
                type: delivery.type,
                delivery: delivery,
              ),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.menu_book_rounded,
                      color: AppTheme.primary, size: 22),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        delivery.bookName,
                        style: GoogleFonts.inter(
                          fontSize: 15,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Issue: ${DateFormat('dd MMM yyyy').format(delivery.issueDate)}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.primary.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Qty: ${delivery.quantity}',
                        style: GoogleFonts.inter(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppTheme.primary,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}