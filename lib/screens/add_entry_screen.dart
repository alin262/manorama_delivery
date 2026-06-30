import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/shop.dart';
import '../models/delivery.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';

class AddEntryScreen extends ConsumerStatefulWidget {
  final Shop shop;
  final String type;
  final Delivery? delivery;

  const AddEntryScreen({
    super.key,
    required this.shop,
    required this.type,
    this.delivery,
  });

  @override
  ConsumerState<AddEntryScreen> createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends ConsumerState<AddEntryScreen> {
  String? _selectedBookId;
  String? _selectedBookName;
  DateTime? _issueDate;
  DateTime _deliveryDate = DateTime.now();
  final _quantityController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.delivery != null) {
      _selectedBookId = widget.delivery!.bookId;
      _selectedBookName = widget.delivery!.bookName;
      _issueDate = widget.delivery!.issueDate;
      _deliveryDate = widget.delivery!.deliveryDate;
      _quantityController.text = widget.delivery!.quantity.toString();
    }
  }

  @override
  void dispose() {
    _quantityController.dispose();
    super.dispose();
  }

  Future<void> _pickIssueDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _issueDate ?? DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _issueDate = picked);
  }

  Future<void> _pickDeliveryDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _deliveryDate,
      firstDate: DateTime(2020),
      lastDate: DateTime(2030),
    );
    if (picked != null) setState(() => _deliveryDate = picked);
  }

  Future<void> _save() async {
    if (_selectedBookId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a book')),
      );
      return;
    }
    if (_issueDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select an issue date')),
      );
      return;
    }
    if (_quantityController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter quantity')),
      );
      return;
    }

    setState(() => _isLoading = true);
    ref.read(syncStatusProvider.notifier).state = 'saving';

    try {
      final service = ref.read(firestoreServiceProvider);
      final delivery = Delivery(
        id: widget.delivery?.id ?? '',
        shopId: widget.shop.id,
        shopName: widget.shop.name,
        bookId: _selectedBookId!,
        bookName: _selectedBookName!,
        issueDate: _issueDate!,
        deliveryDate: _deliveryDate,
        quantity: int.tryParse(_quantityController.text.trim()) ?? 0,
        type: widget.type,
      );

      if (widget.delivery == null) {
        await service.addDelivery(delivery);
      } else {
        await service.updateDelivery(delivery);
      }

      ref.read(syncStatusProvider.notifier).state = 'saved';

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.delivery == null
                ? '${widget.type == 'delivery' ? 'Delivery' : 'Return'} added!'
                : 'Entry updated!'),
            backgroundColor: AppTheme.success,
          ),
        );
      }
    } catch (e) {
      ref.read(syncStatusProvider.notifier).state = 'error';
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppTheme.danger,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksProvider);
    final isEditing = widget.delivery != null;
    final isReturn = widget.type == 'return';

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing
            ? 'Edit Entry'
            : isReturn
                ? 'Add Return'
                : 'Add Delivery'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              decoration: AppTheme.glassDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Shop name (read only)
                  Text(
                    'Shop',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.store_rounded,
                            color: AppTheme.primary, size: 20),
                        const SizedBox(width: 12),
                        Text(
                          widget.shop.name,
                          style: GoogleFonts.inter(
                            fontSize: 15,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Book selection
                  Text(
                    'Book',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  booksAsync.when(
                    data: (books) {
                      if (books.isEmpty) {
                        return Text(
                          'No books yet — add books first from home screen',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedBookId,
                        hint: const Text('Select a book'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha:0.6),
                          prefixIcon:
                              const Icon(Icons.menu_book_rounded),
                        ),
                        items: books
                            .map((b) => DropdownMenuItem(
                                  value: b.id,
                                  child: Text(b.name),
                                ))
                            .toList(),
                        onChanged: (value) {
                          setState(() {
                            _selectedBookId = value;
                            _selectedBookName = books
                                .firstWhere((b) => b.id == value)
                                .name;
                          });
                        },
                      );
                    },
                    loading: () =>
                        const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
                  ),
                  const SizedBox(height: 16),

                  // Issue date
                  Text(
                    'Issue Date',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickIssueDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_month_rounded,
                              color: AppTheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(
                            _issueDate == null
                                ? 'Select issue date'
                                : DateFormat('dd MMM yyyy')
                                    .format(_issueDate!),
                            style: GoogleFonts.inter(
                              fontSize: 15,
                              color: _issueDate == null
                                  ? AppTheme.textSecondary
                                  : AppTheme.textPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quantity
                  Text(
                    'Quantity',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _quantityController,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      hintText: 'Enter quantity',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha:0.6),
                      prefixIcon: const Icon(Icons.numbers_rounded),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Delivery date (optional)
                  Text(
                    'Date of ${isReturn ? 'Return' : 'Delivery'} (optional — defaults to today)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDeliveryDate,
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.6),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.calendar_today_rounded,
                            color: isReturn
                                ? AppTheme.warning
                                : AppTheme.primary,
                            size: 20,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            DateFormat('dd MMM yyyy')
                                .format(_deliveryDate),
                            style: GoogleFonts.inter(fontSize: 15),
                          ),
                          const Spacer(),
                          Text(
                            'Change',
                            style: GoogleFonts.inter(
                              fontSize: 13,
                              color: AppTheme.primary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Save button
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isReturn
                      ? AppTheme.warning
                      : AppTheme.primary,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : Text(
                        isEditing
                            ? 'Save Changes'
                            : isReturn
                                ? 'Add Return'
                                : 'Add Delivery',
                        style: GoogleFonts.inter(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}