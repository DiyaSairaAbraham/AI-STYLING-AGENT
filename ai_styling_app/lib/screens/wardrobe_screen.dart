import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../services/api_service.dart';

class WardrobeScreen extends StatefulWidget {
  const WardrobeScreen({
    super.key,
  });

  @override
  State<WardrobeScreen> createState() =>
      _WardrobeScreenState();
}

class _WardrobeScreenState
    extends State<WardrobeScreen> {
  final ApiService _api = ApiService();
  final ImagePicker _picker = ImagePicker();

  List<Map<String, dynamic>> _items =
      <Map<String, dynamic>>[];

  bool _loading = true;
  bool _adding = false;

  @override
  void initState() {
    super.initState();
    _loadWardrobe();
  }

  Future<void> _loadWardrobe() async {
    if (mounted) {
      setState(() {
        _loading = true;
      });
    }

    try {
      final items = await _api.getWardrobe(
        'personal',
      );

      if (!mounted) return;

      setState(() {
        _items = items;
        _loading = false;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        _loading = false;
      });

      _showError(error);
    }
  }

  Future<void> _addItem() async {
    if (_adding) return;

    final pickedFile =
        await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 95,
    );

    if (pickedFile == null) {
      return;
    }

    setState(() {
      _adding = true;
    });

    try {
      await _api.addWardrobeItem(
        source: 'personal',
        image: File(pickedFile.path),
      );

      if (!mounted) return;

      await _loadWardrobe();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Wardrobe item added successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showError(error);
    } finally {
      if (mounted) {
        setState(() {
          _adding = false;
        });
      }
    }
  }

  Future<void> _deleteItem(
    String itemId,
  ) async {
    if (itemId.trim().isEmpty) {
      _showError(
        'Invalid wardrobe item ID.',
      );
      return;
    }

    try {
      await _api.deleteWardrobeItem(
        source: 'personal',
        itemId: itemId,
      );

      if (!mounted) return;

      await _loadWardrobe();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Item deleted successfully.',
          ),
        ),
      );
    } catch (error) {
      if (!mounted) return;

      _showError(error);
    }
  }

  Future<void> _confirmDelete(
    String itemId,
    String name,
  ) async {
    final confirmed =
        await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Remove item?',
          ),
          content: Text(
            'Remove "$name" from your personal wardrobe?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  false,
                );
              },
              child: const Text(
                'Cancel',
              ),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(
                  context,
                  true,
                );
              },
              child: const Text(
                'Remove',
              ),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      await _deleteItem(itemId);
    }
  }

  void _showError(Object error) {
    final message = error
        .toString()
        .replaceFirst(
          'Exception: ',
          '',
        );

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  String _itemId(Map<String, dynamic> item) {
  return (
    item['id_baju'] ??
    item['item_id'] ??
    item['id'] ??
    item['itemId'] ??
    ''
  ).toString().trim();
}

  String _itemName(
    Map<String, dynamic> item,
  ) {
    return (
      item['name'] ??
      item['item_name'] ??
      item['category'] ??
      item['type'] ??
      'Wardrobe Item'
    ).toString();
  }

  String? _imagePath(
    Map<String, dynamic> item,
  ) {
    final value =
        item['image_path'] ??
        item['image'] ??
        item['path'] ??
        item['file_path'] ??
        item['url'];

    if (value == null) {
      return null;
    }

    final url = _api.getImageUrl(
      value.toString(),
    );

    return url.isEmpty ? null : url;
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor:
            Colors.transparent,
        elevation: 0,
        foregroundColor:
            const Color(0xFF2F2924),
        title: const Text(
          'Personal Wardrobe',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
        actions: [
          IconButton(
            onPressed:
                _loading
                    ? null
                    : _loadWardrobe,
            icon: const Icon(
              Icons.refresh_rounded,
            ),
          ),
        ],
      ),
      floatingActionButton:
          FloatingActionButton.extended(
        onPressed:
            _adding ? null : _addItem,
        backgroundColor:
            const Color(0xFF2F2924),
        foregroundColor:
            Colors.white,
        icon: _adding
            ? const SizedBox(
                width: 18,
                height: 18,
                child:
                    CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(
                Icons.add_rounded,
              ),
        label: Text(
          _adding
              ? 'Adding...'
              : 'Add Item',
        ),
      ),
      body: _loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : _items.isEmpty
              ? _emptyState()
              : RefreshIndicator(
                  onRefresh:
                      _loadWardrobe,
                  child:
                      GridView.builder(
                    padding:
                        const EdgeInsets
                            .fromLTRB(
                      18,
                      12,
                      18,
                      110,
                    ),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing:
                          14,
                      mainAxisSpacing:
                          14,
                      childAspectRatio:
                          0.70,
                    ),
                    itemCount:
                        _items.length,
                    itemBuilder:
                        (context, index) {
                      return _wardrobeCard(
                        _items[index],
                      );
                    },
                  ),
                ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding:
            const EdgeInsets.all(32),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            const Icon(
              Icons
                  .checkroom_outlined,
              size: 70,
              color: Colors.black26,
            ),
            const SizedBox(
              height: 18,
            ),
            const Text(
              'Your wardrobe is empty',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.w800,
              ),
            ),
            const SizedBox(
              height: 8,
            ),
            const Text(
              'Add clothes to your personal wardrobe.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    Colors.black54,
              ),
            ),
            const SizedBox(
              height: 24,
            ),
            FilledButton.icon(
              onPressed:
                  _adding
                      ? null
                      : _addItem,
              icon: const Icon(
                Icons.add_rounded,
              ),
              label: const Text(
                'Add Item',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _wardrobeCard(
    Map<String, dynamic> item,
  ) {
    debugPrint(
      'WARDROBE ITEM: $item',
    );

    final imageUrl =
        _imagePath(item);
    final itemId =
        _itemId(item);
    final name =
        _itemName(item);

    debugPrint(
      'WARDROBE ITEM ID: $itemId',
    );

    return Container(
      decoration:
          BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(
          22,
        ),
        boxShadow: const [
          BoxShadow(
            blurRadius: 12,
            offset: Offset(0, 4),
            color:
                Color(0x12000000),
          ),
        ],
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Expanded(
            child:
                imageUrl == null
                    ? _imagePlaceholder()
                    : Image.network(
                        imageUrl,
                        width:
                            double.infinity,
                        fit:
                            BoxFit.cover,
                        errorBuilder:
                            (
                          context,
                          error,
                          stackTrace,
                        ) {
                          debugPrint(
                            'IMAGE ERROR: '
                            '$error',
                          );

                          return _imagePlaceholder();
                        },
                      ),
          ),
          Padding(
            padding:
                const EdgeInsets
                    .fromLTRB(
              12,
              10,
              6,
              8,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    name,
                    maxLines: 2,
                    overflow:
                        TextOverflow
                            .ellipsis,
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight
                              .w700,
                    ),
                  ),
                ),
                IconButton(
                  onPressed:
                      itemId.isEmpty
                          ? null
                          : () =>
                              _confirmDelete(
                                itemId,
                                name,
                              ),
                  icon:
                      const Icon(
                    Icons
                        .delete_outline_rounded,
                    color:
                        Colors.redAccent,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imagePlaceholder() {
    return Container(
      color:
          const Color(0xFFECE8E2),
      alignment:
          Alignment.center,
      child: const Icon(
        Icons.image_outlined,
        size: 42,
        color: Colors.black26,
      ),
    );
  }
}