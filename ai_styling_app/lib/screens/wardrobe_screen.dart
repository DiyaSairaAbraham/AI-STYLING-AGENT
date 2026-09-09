import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../models/wardrobe_item.dart';
import '../services/wardrobe_service.dart';

// ============================================================
// App-wide purple theme
// ============================================================

class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

// ============================================================
// WARDROBE SCREEN
// ============================================================

class WardrobeScreen extends StatefulWidget {
  final String? userImagePath;

  const WardrobeScreen({
    super.key,
    this.userImagePath,
  });

  @override
  State<WardrobeScreen> createState() => _WardrobeScreenState();
}

class _WardrobeScreenState extends State<WardrobeScreen> {
  final WardrobeService service = WardrobeService();

  List<WardrobeItem> wardrobe = [];
  final Set<String> selectedItemIds = <String>{};

  bool loading = true;
  bool _submitting = false;

  bool get isStylingFlow => widget.userImagePath != null;

  @override
  void initState() {
    super.initState();
    loadWardrobe();
  }

  // ==========================================================
  // LOAD WARDROBE
  // ==========================================================

  Future<void> loadWardrobe() async {
    if (!mounted) {
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final List<WardrobeItem> items =
          await service.getWardrobe();

      if (!mounted) {
        return;
      }

      setState(() {
        wardrobe = items;
        loading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to load your wardrobe.\n$e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // ADD ITEM
  // ==========================================================

  Future<void> addItem() async {
    try {
      final ImagePicker picker = ImagePicker();

      final XFile? image = await picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1600,
        maxHeight: 1600,
      );

      if (image == null) {
        return;
      }

      if (!mounted) {
        return;
      }

      setState(() {
        loading = true;
      });

      final bool success =
          await service.addClothing(image);

      if (!mounted) {
        return;
      }

      if (success) {
        await loadWardrobe();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Item added to your wardrobe.',
            ),
          ),
        );
      } else {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to add clothing item.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        loading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong while adding the item.\n$e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // DELETE ITEM
  // ==========================================================

  Future<void> deleteItem(String id) async {
    try {
      final bool success =
          await service.deleteClothing(id);

      if (!mounted) {
        return;
      }

      if (success) {
        setState(() {
          selectedItemIds.remove(id);
        });

        await loadWardrobe();

        if (!mounted) {
          return;
        }

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Item removed from your wardrobe.',
            ),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Failed to delete clothing item.',
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) {
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Something went wrong while deleting the item.\n$e',
          ),
        ),
      );
    }
  }

  // ==========================================================
  // SELECT / DESELECT ITEM
  // ==========================================================

  void toggleSelection(String id) {
    if (!isStylingFlow) {
      return;
    }

    setState(() {
      if (selectedItemIds.contains(id)) {
        selectedItemIds.remove(id);
      } else {
        selectedItemIds.add(id);
      }
    });
  }

  // ==========================================================
  // CONTINUE WITH SELECTION
  // ==========================================================

  void continueWithSelection() {
    if (selectedItemIds.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select at least one wardrobe item.',
          ),
        ),
      );

      return;
    }

    if (_submitting) {
      return;
    }

    setState(() {
      _submitting = true;
    });

    Navigator.pop(
      context,
      selectedItemIds.toList(),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          isStylingFlow
              ? 'Choose From My Wardrobe'
              : 'My Wardrobe',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: loading ? null : addItem,
            tooltip: 'Add clothing',
          ),
        ],
      ),
      body: loading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : wardrobe.isEmpty
              ? _buildEmptyState()
              : _buildWardrobeGrid(),
      bottomNavigationBar:
          isStylingFlow && selectedItemIds.isNotEmpty
              ? SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(
                      16,
                      8,
                      16,
                      16,
                    ),
                    child: ElevatedButton.icon(
                      onPressed: _submitting
                          ? null
                          : continueWithSelection,
                      icon: const Icon(
                        Icons.arrow_forward,
                      ),
                      label: Text(
                        'Continue with '
                        '${selectedItemIds.length} selected',
                      ),
                    ),
                  ),
                )
              : null,
    );
  }

  // ==========================================================
  // WARDROBE GRID
  // ==========================================================

  Widget _buildWardrobeGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(12),
      gridDelegate:
          const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 0.65,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: wardrobe.length,
      itemBuilder: (context, index) {
        final WardrobeItem item = wardrobe[index];

        final bool isSelected =
            selectedItemIds.contains(item.id);

        final String imagePath =
            item.thumbnailPath?.isNotEmpty == true
                ? item.thumbnailPath!
                : item.imagePath;

        final String imageUrl =
            '${WardrobeService.baseUrl}$imagePath';

        return GestureDetector(
          onTap: isStylingFlow
              ? () => toggleSelection(item.id)
              : null,
          child: Card(
            clipBehavior: Clip.antiAlias,
            child: Stack(
              children: [
                Column(
                  children: [
                    // ==================================================
                    // CLOTHING IMAGE
                    // ==================================================

                    Expanded(
                      child: Image.network(
                        imageUrl,
                        width: double.infinity,
                        fit: BoxFit.cover,

                        // Wardrobe cards are small, so there is no reason
                        // to decode the original high-resolution image.
                        cacheWidth: 280,
                        cacheHeight: 360,

                        filterQuality: FilterQuality.low,

                        errorBuilder: (
                          context,
                          error,
                          stackTrace,
                        ) {
                          debugPrint(
                            'Wardrobe image failed: $imageUrl',
                          );

                          return const Center(
                            child: Icon(
                              Icons
                                  .image_not_supported_outlined,
                              size: 40,
                            ),
                          );
                        },

                        loadingBuilder: (
                          context,
                          child,
                          loadingProgress,
                        ) {
                          if (loadingProgress == null) {
                            return child;
                          }

                          return const Center(
                            child: SizedBox(
                              width: 28,
                              height: 28,
                              child:
                                  CircularProgressIndicator(),
                            ),
                          );
                        },
                      ),
                    ),

                    // ==================================================
                    // CATEGORY
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        8,
                        8,
                        8,
                        0,
                      ),
                      child: Text(
                        item.category,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                    // ==================================================
                    // COLOR
                    // ==================================================

                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                      ),
                      child: Text(
                        item.color,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                    // ==================================================
                    // DELETE BUTTON
                    // ==================================================

                    SizedBox(
                      height: 42,
                      child: IconButton(
                        icon: const Icon(
                          Icons.delete,
                        ),
                        onPressed: () =>
                            deleteItem(item.id),
                        tooltip: 'Delete clothing',
                      ),
                    ),
                  ],
                ),

                // ======================================================
                // SELECTION CHECKMARK
                // ======================================================

                if (isStylingFlow)
                  Positioned(
                    top: 10,
                    right: 10,
                    child: AnimatedContainer(
                      duration:
                          const Duration(milliseconds: 150),
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? AppTheme.purpleDeep
                            : Colors.white,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.purpleDeep,
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color:
                                Colors.black.withValues(
                              alpha: 0.15,
                            ),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: isSelected
                          ? const Icon(
                              Icons.check,
                              color: Colors.white,
                              size: 20,
                            )
                          : null,
                    ),
                  ),

                // ======================================================
                // SELECTED BORDER
                // ======================================================

                if (isSelected)
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: AppTheme.purpleDeep,
                            width: 4,
                          ),
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // EMPTY STATE
  // ==========================================================

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 72,
              color: AppTheme.purpleSoft,
            ),

            const SizedBox(height: 20),

            const Text(
              'Your wardrobe is empty',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppTheme.inkDark,
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Add some clothing items to start '
              'building your personal wardrobe.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.inkMuted,
              ),
            ),

            const SizedBox(height: 24),

            ElevatedButton.icon(
              onPressed: addItem,
              icon: const Icon(
                Icons.add,
              ),
              label: const Text(
                'Add Clothing',
              ),
            ),
          ],
        ),
      ),
    );
  }
}