import 'package:flutter/material.dart';
import 'package:ai_styling_app/screens/outfit_result_screen.dart';

import '../models/wardrobe_item.dart';
import '../services/api_service.dart';
import '../services/wardrobe_service.dart';

class AppTheme {
  static const Color purpleDeep = Color(0xFF4C2FD6);
  static const Color purpleAccent = Color(0xFF6C48F2);
  static const Color purpleSoft = Color(0xFF7B5CF0);
  static const Color bgLight = Color(0xFFEDE8FD);
  static const Color inkDark = Color(0xFF1A1B4B);
  static const Color inkMuted = Color(0xFF5A5B7E);
}

class SelectWardrobeSourceScreen extends StatefulWidget {
  final String imagePath;
  final String styleType;

  const SelectWardrobeSourceScreen({
    super.key,
    required this.imagePath,
    required this.styleType,
  });

  @override
  State<SelectWardrobeSourceScreen> createState() =>
      _SelectWardrobeSourceScreenState();
}

class _SelectWardrobeSourceScreenState
    extends State<SelectWardrobeSourceScreen> {
  final ApiService apiService = ApiService();
  final WardrobeService wardrobeService = WardrobeService();

  String selectedSource = '';

  bool isLoading = false;
  bool isWardrobeLoading = false;

  List<WardrobeItem> wardrobe = [];

  final Set<String> selectedItemIds = <String>{};

  Future<void> loadWardrobe() async {
    if (isWardrobeLoading || !mounted) {
      return;
    }

    setState(() {
      isWardrobeLoading = true;
    });

    try {
      final items = await wardrobeService.getWardrobe();

      if (!mounted) {
        return;
      }

      setState(() {
        wardrobe = items;
        isWardrobeLoading = false;
      });
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isWardrobeLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Could not load your wardrobe: $e',
          ),
        ),
      );
    }
  }

  void selectSource(String source) {
    if (!mounted) {
      return;
    }

    setState(() {
      selectedSource = source;

      if (source != 'personal') {
        selectedItemIds.clear();
      }
    });

    if (source == 'personal' && wardrobe.isEmpty) {
      loadWardrobe();
    }
  }

  void toggleWardrobeItem(String itemId) {
    if (!mounted) {
      return;
    }

    setState(() {
      if (selectedItemIds.contains(itemId)) {
        selectedItemIds.remove(itemId);
      } else {
        selectedItemIds.add(itemId);
      }
    });
  }

  Future<void> generateOutfit() async {
    if (isLoading) {
      return;
    }

    if (selectedSource.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please select a wardrobe source first.',
          ),
        ),
      );
      return;
    }

    if (widget.imagePath.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'User image path is missing.',
          ),
        ),
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() {
      isLoading = true;
    });

    try {
      final optionsResult =
          await apiService.generateOutfitOptions(
        userImagePath: widget.imagePath,
        styleType: widget.styleType,
        wardrobeSource: selectedSource,

        // Empty list is valid for Personal.
        // The backend should interpret [] as:
        // "let the AI choose from the complete personal wardrobe."
        selectedItemIds: selectedItemIds.toList(),
      );

      if (!mounted) {
        return;
      }

      if (optionsResult == null) {
        throw Exception(
          'The outfit recommendation request failed.',
        );
      }

      final data = optionsResult['data'];

      if (data is! Map<String, dynamic>) {
        throw Exception(
          'Invalid recommendation response.',
        );
      }

      final recommendations = data['recommendations'];

      if (recommendations is! List ||
          recommendations.isEmpty) {
        throw Exception(
          'No outfit recommendations were returned.',
        );
      }

      final recommendation = recommendations.first;

      if (recommendation is! Map<String, dynamic>) {
        throw Exception(
          'Invalid outfit recommendation.',
        );
      }

      final imagePrompt =
          recommendation['image_generation_prompt'];

      final stylingAdvice =
          recommendation['styling_advice'];

      if (imagePrompt == null ||
          imagePrompt.toString().trim().isEmpty) {
        throw Exception(
          'No image generation prompt was returned.',
        );
      }

      final imageResult =
          await apiService.generateSelectedOutfit(
        prompt: imagePrompt.toString(),
        userImagePath: widget.imagePath,
      );

      if (!mounted) {
        return;
      }

      if (imageResult == null) {
        throw Exception(
          'The outfit image could not be generated.',
        );
      }

      final imageUrl = imageResult['image_url'];

      if (imageUrl == null ||
          imageUrl.toString().trim().isEmpty) {
        throw Exception(
          'The generated image URL is missing.',
        );
      }

      setState(() {
        isLoading = false;
      });

      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => OutfitResultScreen(
            imagePath: imageUrl.toString(),
            styleType: widget.styleType,
            sourceType: selectedSource,
            stylingAdvice:
                stylingAdvice?.toString() ?? '',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) {
        return;
      }

      setState(() {
        isLoading = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Failed to generate outfit: $e',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bgLight,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(
          color: AppTheme.inkDark,
        ),
      ),
      extendBodyBehindAppBar: true,
      body: SafeArea(
        child: isLoading
            ? _buildLoadingView()
            : _buildContent(),
      ),
    );
  }

  Widget _buildLoadingView() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              color: AppTheme.purpleAccent,
              strokeWidth: 4,
            ),
            SizedBox(height: 20),
            Text(
              'Generating your outfit...\n'
              'This may take up to 1 minute',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.inkMuted,
                fontSize: 15,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(
            24,
            24,
            24,
            30,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - 54,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 35),

                Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius:
                          BorderRadius.circular(30),
                      border: Border.all(
                        color: AppTheme.purpleSoft
                            .withOpacity(0.4),
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.auto_awesome,
                          size: 16,
                          color: AppTheme.purpleDeep,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'AI POWERED',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.purpleDeep,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'Choose Wardrobe Source',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.w900,
                    color: AppTheme.inkDark,
                  ),
                ),

                const SizedBox(height: 10),

                const Center(
                  child: SizedBox(
                    width: 48,
                    height: 4,
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: AppTheme.purpleAccent,
                        borderRadius: BorderRadius.all(
                          Radius.circular(2),
                        ),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  'Choose where your outfit should come from.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.inkMuted,
                    height: 1.4,
                  ),
                ),

                const SizedBox(height: 30),

                _buildSelectedStyleCard(),

                const SizedBox(height: 30),

                _buildSourceCard(
                  icon: Icons.person,
                  title: 'Personal',
                  subtitle:
                      'Choose clothes from your personal wardrobe',
                  value: 'personal',
                ),

                if (selectedSource == 'personal') ...[
                  const SizedBox(height: 20),
                  _buildPersonalWardrobe(),
                ],

                const SizedBox(height: 16),

                _buildSourceCard(
                  icon: Icons.shopping_bag,
                  title: 'Commercial',
                  subtitle:
                      'Use items from commercial catalog',
                  value: 'commercial',
                ),

                const SizedBox(height: 16),

                _buildSourceCard(
                  icon: Icons.public,
                  title: 'Open World',
                  subtitle:
                      'Let AI create outfits from the entire '
                      'fashion world',
                  value: 'open_world',
                ),

                const SizedBox(height: 30),

                if (selectedSource == 'personal' &&
                    selectedItemIds.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: AppTheme.purpleAccent
                          .withOpacity(0.10),
                      borderRadius:
                          BorderRadius.circular(14),
                      border: Border.all(
                        color: AppTheme.purpleAccent
                            .withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          color: AppTheme.purpleAccent,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            '${selectedItemIds.length} wardrobe '
                            '${selectedItemIds.length == 1 ? 'item' : 'items'} selected',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.inkDark,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                if (selectedSource == 'personal' &&
                    selectedItemIds.isNotEmpty)
                  const SizedBox(height: 16),

                SizedBox(
                  height: 56,
                  child: ElevatedButton.icon(
                    icon: const Icon(
                      Icons.auto_awesome,
                      color: Colors.white,
                    ),
                    label: const Text(
                      'Generate Outfit',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          AppTheme.purpleDeep,
                      foregroundColor: Colors.white,
                      minimumSize:
                          const Size(double.infinity, 56),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    onPressed:
                        isLoading ? null : generateOutfit,
                  ),
                ),

                const SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedStyleCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppTheme.purpleSoft.withOpacity(0.4),
        ),
        boxShadow: [
          BoxShadow(
            color:
                AppTheme.purpleDeep.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            color: AppTheme.purpleAccent,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Selected Style: '
              '${widget.styleType.toUpperCase()}',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.inkDark,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSourceCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required String value,
  }) {
    final bool isSelected =
        selectedSource == value;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: () {
          selectSource(value);
        },
        child: AnimatedContainer(
          duration:
              const Duration(milliseconds: 250),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: isSelected
                ? AppTheme.purpleAccent
                    .withOpacity(0.12)
                : Colors.white,
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? AppTheme.purpleAccent
                  : AppTheme.purpleSoft
                      .withOpacity(0.35),
              width: isSelected ? 2 : 1,
            ),
            boxShadow: [
              BoxShadow(
                color: isSelected
                    ? AppTheme.purpleDeep
                        .withOpacity(0.18)
                    : Colors.black
                        .withOpacity(0.05),
                blurRadius:
                    isSelected ? 12 : 8,
                offset:
                    const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment:
                CrossAxisAlignment.center,
            children: [
              Container(
                padding:
                    const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: isSelected
                      ? AppTheme.purpleDeep
                          .withOpacity(0.10)
                      : AppTheme.bgLight,
                  borderRadius:
                      BorderRadius.circular(14),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: isSelected
                      ? AppTheme.purpleDeep
                      : AppTheme.inkMuted,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 18,
                        fontWeight:
                            FontWeight.bold,
                        color:
                            AppTheme.inkDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color:
                            AppTheme.inkMuted,
                        fontSize: 14,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              AnimatedSwitcher(
                duration:
                    const Duration(
                  milliseconds: 200,
                ),
                child: isSelected
                    ? const Icon(
                        Icons.check_circle,
                        key: ValueKey(
                          'selected',
                        ),
                        color:
                            AppTheme.purpleAccent,
                        size: 24,
                      )
                    : const SizedBox(
                        key: ValueKey(
                          'unselected',
                        ),
                        width: 24,
                        height: 24,
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPersonalWardrobe() {
    if (isWardrobeLoading) {
      return Container(
        padding:
            const EdgeInsets.all(30),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
        ),
        child: const Center(
          child:
              CircularProgressIndicator(
            color:
                AppTheme.purpleAccent,
          ),
        ),
      );
    }

    if (wardrobe.isEmpty) {
      return Container(
        padding:
            const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(20),
          border: Border.all(
            color: AppTheme.purpleSoft
                .withOpacity(0.35),
          ),
        ),
        child: const Column(
          children: [
            Icon(
              Icons.checkroom_outlined,
              size: 50,
              color: AppTheme.purpleSoft,
            ),
            SizedBox(height: 12),
            Text(
              'Your wardrobe is empty.',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
                color:
                    AppTheme.inkDark,
              ),
            ),
            SizedBox(height: 6),
            Text(
              'Add clothing items to your wardrobe '
              'before generating a personal outfit.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                color:
                    AppTheme.inkMuted,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment:
          CrossAxisAlignment.start,
      children: [
        const Text(
          'Select Wardrobe Items',
          style: TextStyle(
            fontSize: 21,
            fontWeight: FontWeight.w900,
            color: AppTheme.inkDark,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'You can select specific clothes, or leave '
          'everything unselected and let the AI stylist '
          'choose from your entire wardrobe.',
          style: TextStyle(
            color: AppTheme.inkMuted,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
        GridView.builder(
          shrinkWrap: true,
          physics:
              const NeverScrollableScrollPhysics(),
          gridDelegate:
              const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio: 0.72,
          ),
          itemCount: wardrobe.length,
          itemBuilder:
              (context, index) {
            final item =
                wardrobe[index];

            return _buildWardrobeItemCard(
              item,
            );
          },
        ),
      ],
    );
  }

  Widget _buildWardrobeItemCard(
    WardrobeItem item,
  ) {
    final bool isSelected =
        selectedItemIds.contains(item.id);

    final String imagePath =
        item.thumbnailPath?.isNotEmpty == true
            ? item.thumbnailPath!
            : item.imagePath;

    final String imageUrl =
        '${WardrobeService.baseUrl}$imagePath';

    return GestureDetector(
      onTap: () {
        toggleWardrobeItem(item.id);
      },
      child: AnimatedContainer(
        duration:
            const Duration(milliseconds: 200),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
              BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? AppTheme.purpleAccent
                : AppTheme.purpleSoft
                    .withOpacity(0.25),
            width: isSelected ? 2.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? AppTheme.purpleDeep
                      .withOpacity(0.18)
                  : Colors.black
                      .withOpacity(0.05),
              blurRadius:
                  isSelected ? 12 : 7,
              offset:
                  const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius:
              BorderRadius.circular(17),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Expanded(
                    child: Image.network(
                      imageUrl,
                      fit: BoxFit.cover,
                      cacheWidth: 300,
                      cacheHeight: 375,
                      filterQuality:
                          FilterQuality.low,
                      errorBuilder: (
                        context,
                        error,
                        stackTrace,
                      ) {
                        return Container(
                          color:
                              AppTheme.bgLight,
                          child:
                              const Icon(
                            Icons
                                .broken_image_outlined,
                            size: 40,
                            color:
                                AppTheme.inkMuted,
                          ),
                        );
                      },
                      loadingBuilder: (
                        context,
                        child,
                        loadingProgress,
                      ) {
                        if (loadingProgress ==
                            null) {
                          return child;
                        }

                        return const Center(
                          child:
                              CircularProgressIndicator(
                            color:
                                AppTheme
                                    .purpleAccent,
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.all(
                            10),
                    color: Colors.white,
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          item.category,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            color:
                                AppTheme
                                    .inkDark,
                          ),
                        ),
                        const SizedBox(
                            height: 3),
                        Text(
                          item.color,
                          maxLines: 1,
                          overflow:
                              TextOverflow
                                  .ellipsis,
                          style:
                              const TextStyle(
                            fontSize: 12,
                            color:
                                AppTheme
                                    .inkMuted,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Positioned(
                top: 10,
                right: 10,
                child: AnimatedContainer(
                  duration:
                      const Duration(
                    milliseconds: 200,
                  ),
                  width: 30,
                  height: 30,
                  decoration:
                      BoxDecoration(
                    color: isSelected
                        ? AppTheme
                            .purpleAccent
                        : Colors.white
                            .withOpacity(
                                0.9),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected
                          ? AppTheme
                              .purpleAccent
                          : AppTheme
                              .purpleSoft
                              .withOpacity(
                                  0.5),
                    ),
                  ),
                  child: isSelected
                      ? const Icon(
                          Icons.check,
                          color:
                              Colors.white,
                          size: 19,
                        )
                      : null,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}