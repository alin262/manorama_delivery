import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/shop.dart';
import '../providers/providers.dart';
import '../utils/app_theme.dart';

class AddShopScreen extends ConsumerStatefulWidget {
  final Shop? shop; // if editing existing shop
  const AddShopScreen({super.key, this.shop});

  @override
  ConsumerState<AddShopScreen> createState() => _AddShopScreenState();
}

class _AddShopScreenState extends ConsumerState<AddShopScreen> {
  final _nameController = TextEditingController();
  String? _selectedGroupId;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill if editing
    if (widget.shop != null) {
      _nameController.text = widget.shop!.name;
      _selectedGroupId = widget.shop!.groupId;
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a shop name')),
      );
      return;
    }

    setState(() => _isLoading = true);
    ref.read(syncStatusProvider.notifier).state = 'saving';

    try {
      final service = ref.read(firestoreServiceProvider);
      final shop = Shop(
        id: widget.shop?.id ?? '',
        name: _nameController.text.trim(),
        groupId: _selectedGroupId,
      );

      if (widget.shop == null) {
        await service.addShop(shop);
      } else {
        await service.updateShop(shop);
      }

      ref.read(syncStatusProvider.notifier).state = 'saved';

      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.shop == null
                ? 'Shop added successfully!'
                : 'Shop updated successfully!'),
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
    final groupsAsync = ref.watch(groupsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.shop == null ? 'Add Shop' : 'Edit Shop'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Shop name field
            Container(
              decoration: AppTheme.glassDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Shop Name',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _nameController,
                    decoration: InputDecoration(
                      hintText: 'Enter shop name',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: Colors.white.withValues(alpha:0.6),
                      prefixIcon: const Icon(Icons.store_rounded),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // Group selection
            Container(
              decoration: AppTheme.glassDecoration(),
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Group (Optional)',
                    style: GoogleFonts.inter(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  groupsAsync.when(
                    data: (groups) {
                      if (groups.isEmpty) {
                        return Text(
                          'No groups yet — add a group first',
                          style: GoogleFonts.inter(
                            color: AppTheme.textSecondary,
                            fontSize: 14,
                          ),
                        );
                      }
                      return DropdownButtonFormField<String>(
                        value: _selectedGroupId,
                        hint: const Text('Select a group'),
                        decoration: InputDecoration(
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide.none,
                          ),
                          filled: true,
                          fillColor: Colors.white.withValues(alpha:0.6),
                        ),
                        items: [
                          const DropdownMenuItem(
                            value: null,
                            child: Text('No group'),
                          ),
                          ...groups.map((g) => DropdownMenuItem(
                                value: g.id,
                                child: Text(g.name),
                              )),
                        ],
                        onChanged: (value) =>
                            setState(() => _selectedGroupId = value),
                      );
                    },
                    loading: () => const CircularProgressIndicator(),
                    error: (e, _) => Text('Error: $e'),
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
                  backgroundColor: AppTheme.primary,
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
                        widget.shop == null ? 'Add Shop' : 'Save Changes',
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