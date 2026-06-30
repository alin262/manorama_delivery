import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';
import '../models/shop.dart';

class SummaryScreen extends ConsumerStatefulWidget {
  const SummaryScreen({super.key});

  @override
  ConsumerState<SummaryScreen> createState() => _SummaryScreenState();
}

class _SummaryScreenState extends ConsumerState<SummaryScreen> {
  DateTime _selectedMonth = DateTime.now();
  Shop? _selectedShop;

  void _changeMonth(int delta) {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + delta,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final shopsAsync = ref.watch(shopsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Monthly Summary'),
      ),
      body: Column(
        children: [
          // Shop selector
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Select Shop',
                  style: GoogleFonts.inter(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 8),
                shopsAsync.when(
                  data: (shops) {
                    if (shops.isEmpty) {
                      return Text(
                        'No shops yet',
                        style: GoogleFonts.inter(
                          color: AppTheme.textSecondary,
                        ),
                      );
                    }
                    return DropdownButtonFormField<String>(
                      value: _selectedShop?.id,
                      hint: const Text('Choose a shop'),
                      decoration: InputDecoration(
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                        filled: true,
                        fillColor: Colors.white.withValues(alpha:0.6),
                        prefixIcon: const Icon(Icons.store_rounded),
                      ),
                      items: shops
                          .map((s) => DropdownMenuItem(
                                value: s.id,
                                child: Text(s.name),
                              ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedShop =
                              shops.firstWhere((s) => s.id == value);
                        });
                      },
                    );
                  },
                  loading: () => const CircularProgressIndicator(),
                  error: (e, _) => Text('Error: $e'),
                ),
              ],
            ),
          ),

          // Month selector
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 16),
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: AppTheme.glassDecoration(),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left_rounded),
                  onPressed: () => _changeMonth(-1),
                ),
                Text(
                  DateFormat('MMMM yyyy').format(_selectedMonth),
                  style: GoogleFonts.inter(
                    fontSize: 17,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right_rounded),
                  onPressed: () => _changeMonth(1),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Content
          Expanded(
            child: _selectedShop == null
                ? Center(
                    child: Text(
                      'Select a shop to view summary',
                      style: GoogleFonts.inter(
                        color: AppTheme.textSecondary,
                        fontSize: 15,
                      ),
                    ),
                  )
                : _buildShopSummary(),
          ),
        ],
      ),
    );
  }

  Widget _buildShopSummary() {
    final monthStart =
        DateTime(_selectedMonth.year, _selectedMonth.month, 1);
    final monthEnd =
        DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59);

    final deliveriesAsync = ref.watch(
      shopMonthlyDeliveriesProvider(ShopMonthQuery(
        shopId: _selectedShop!.id,
        monthStart: monthStart,
        monthEnd: monthEnd,
        type: 'delivery',
      )),
    );

    final returnsAsync = ref.watch(
      shopMonthlyDeliveriesProvider(ShopMonthQuery(
        shopId: _selectedShop!.id,
        monthStart: monthStart,
        monthEnd: monthEnd,
        type: 'return',
      )),
    );

    return deliveriesAsync.when(
      data: (deliveries) {
        return returnsAsync.when(
          data: (returns) {
            return _buildSummaryContent(deliveries, returns);
          },
          loading: () =>
              const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (e, _) => Center(child: Text('Error: $e')),
    );
  }

  Widget _buildSummaryContent(List deliveries, List returns) {
    final bookData = <String, Map<String, int>>{};

    for (final d in deliveries) {
      bookData.putIfAbsent(d.bookName, () => {'delivered': 0, 'returned': 0});
      bookData[d.bookName]!['delivered'] =
          (bookData[d.bookName]!['delivered'] ?? 0) + (d.quantity as int);
    }

    for (final r in returns) {
      bookData.putIfAbsent(r.bookName, () => {'delivered': 0, 'returned': 0});
      bookData[r.bookName]!['returned'] =
          (bookData[r.bookName]!['returned'] ?? 0) + (r.quantity as int);
    }

    if (bookData.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.bar_chart_rounded,
                size: 64, color: AppTheme.textSecondary),
            const SizedBox(height: 16),
            Text(
              'No data for ${_selectedShop!.name} this month',
              style: GoogleFonts.inter(
                fontSize: 15,
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    int totalDelivered = 0;
    int totalReturned = 0;
    for (final data in bookData.values) {
      totalDelivered += data['delivered']!;
      totalReturned += data['returned']!;
    }
    final totalNetSales = totalDelivered - totalReturned;

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: AppTheme.glassDecoration(
            color: AppTheme.primary.withValues(alpha:0.05),
          ),
          child: Column(
            children: [
              Text(
                _selectedShop!.name,
                style: GoogleFonts.inter(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _statColumn(
                      'Delivered', totalDelivered, AppTheme.primary),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textSecondary.withValues(alpha:0.2),
                  ),
                  _statColumn(
                      'Returned', totalReturned, AppTheme.warning),
                  Container(
                    width: 1,
                    height: 40,
                    color: AppTheme.textSecondary.withValues(alpha:0.2),
                  ),
                  _statColumn(
                      'Net Sales', totalNetSales, AppTheme.success),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Text(
          'By Book',
          style: GoogleFonts.inter(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 8),
        ...bookData.entries.map((entry) {
          final delivered = entry.value['delivered']!;
          final returned = entry.value['returned']!;
          final netSales = delivered - returned;

          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.all(16),
            decoration: AppTheme.glassDecoration(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.key,
                  style: GoogleFonts.inter(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _miniStat('Delivered', delivered, AppTheme.primary),
                    _miniStat('Returned', returned, AppTheme.warning),
                    _miniStat('Net', netSales, AppTheme.success),
                  ],
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  Widget _statColumn(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.inter(
            fontSize: 24,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 12,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _miniStat(String label, int value, Color color) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: GoogleFonts.inter(
            fontSize: 11,
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }
}