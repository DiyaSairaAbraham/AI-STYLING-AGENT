import 'package:flutter/material.dart';

import '../models/recommendation.dart';
import '../services/api_service.dart';

import 'package:ai_styling_app/screens/outfit_result_screen.dart';

class OptionsScreen extends StatefulWidget {
final Map<String, dynamic> optionsData;

const OptionsScreen({
super.key,
required this.optionsData,
});

@override
State<OptionsScreen> createState() => _OptionsScreenState();
}

class _OptionsScreenState extends State<OptionsScreen> {
final ApiService _apiService = ApiService();

List<dynamic> recommendations = <dynamic>[];

bool _loading = false;
String _loadingMessage = '';

final Set<int> _refreshingIndexes = <int>{};

@override
void initState() {
super.initState();


final data = widget.optionsData['data'];

if (data is Map<String, dynamic> &&
    data['recommendations'] is List) {
  recommendations = List<dynamic>.from(
    data['recommendations'] as List,
  );
}


}

Future<void> _generateOutfit(
Map<String, dynamic> outfit,
) async {
if (_loading) {
return;
}


setState(() {
  _loading = true;
  _loadingMessage = 'Creating your outfit image...';
});

try {
  final prompt = outfit['image_generation_prompt'];

  if (prompt == null || prompt.toString().isEmpty) {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Image generation prompt is missing',
        ),
      ),
    );

    return;
  }

  final userImagePath =
      widget.optionsData['user_image_path'];

  if (userImagePath == null ||
      userImagePath.toString().isEmpty) {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'User image path is missing',
        ),
      ),
    );

    return;
  }

  final result =
      await _apiService.generateSelectedOutfit(
    prompt: prompt.toString(),
    userImagePath: userImagePath.toString(),
  );

  if (!mounted) {
    return;
  }

  setState(() {
    _loading = false;
  });

  if (result == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Failed to generate outfit image',
        ),
      ),
    );

    return;
  }

  final imageUrl = result['image_url'];

debugPrint("GENERATED IMAGE URL: $imageUrl");

if (imageUrl == null ||imageUrl.toString().trim().isEmpty)  {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Image URL not received'),
    ),
  );

  return;
}


} catch (e) {
  if (!mounted) {
    return;
  }

  setState(() {
    _loading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Failed to generate outfit image: $e',
      ),
    ),
  );
}


}

Future<void> _regenerateRecommendations() async {
if (_loading) {
return;
}


setState(() {
  _loading = true;
  _loadingMessage =
      'Generating new outfit recommendations...';
});

try {
  final userImagePath =
      widget.optionsData['user_image_path'];

  if (userImagePath == null ||
      userImagePath.toString().isEmpty) {
    if (!mounted) {
      return;
    }

    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'User image path is missing',
        ),
      ),
    );

    return;
  }

  final result =
      await _apiService.regenerateRecommendations(
    userImagePath.toString(),
  );

  if (!mounted) {
    return;
  }

  final data = result?['data'];

  if (data is Map<String, dynamic> &&
      data['recommendations'] is List) {
    setState(() {
      recommendations = List<dynamic>.from(
        data['recommendations'] as List,
      );
      _loading = false;
    });
  } else {
    setState(() {
      _loading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Failed to regenerate recommendations',
        ),
      ),
    );
  }
} catch (e) {
  if (!mounted) {
    return;
  }

  setState(() {
    _loading = false;
  });

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        'Failed to regenerate recommendations: $e',
      ),
    ),
  );
}

}

Future<void> _regenerateOneRecommendation(
int index,
) async {
if (_loading ||
_refreshingIndexes.contains(index)) {
return;
}


if (index < 0 ||
    index >= recommendations.length) {
  return;
}

final rawOutfit = recommendations[index];

if (rawOutfit is! Map) {
  return;
}

final outfit =
    Map<String, dynamic>.from(rawOutfit);

final category =
    outfit['category']?.toString();

if (category == null || category.isEmpty) {
  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'Outfit category is missing',
      ),
    ),
  );

  return;
}

final userImagePath =
    widget.optionsData['user_image_path'];

if (userImagePath == null ||
    userImagePath.toString().isEmpty) {
  if (!mounted) {
    return;
  }

  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text(
        'User image path is missing',
      ),
    ),
  );

  return;
}

setState(() {
  _refreshingIndexes.add(index);
});

try {
  final result =
      await _apiService.regenerateOneRecommendation(
    userImagePath: userImagePath.toString(),
    category: category,
  );

  if (!mounted) {
    return;
  }

  if (result != null &&
      result['recommendation'] != null) {
    final newRecommendation =
        result['recommendation'];

    if (newRecommendation is Map) {
      setState(() {
        recommendations[index] =
            Map<String, dynamic>.from(
          newRecommendation,
        );
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Invalid recommendation received',
          ),
        ),
      );
    }
  } else {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Failed to regenerate recommendation',
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
        'Failed to regenerate recommendation: $e',
      ),
    ),
  );
} finally {
  if (mounted) {
    setState(() {
      _refreshingIndexes.remove(index);
    });
  }
}


}

@override
Widget build(BuildContext context) {
return Scaffold(
appBar: AppBar(
title: const Text(
'Choose Your Outfit',
),
actions: [
IconButton(
tooltip:
'Generate new outfit recommendations',
icon: const Icon(
Icons.refresh,
),
onPressed: _loading
? null
: _regenerateRecommendations,
),
],
),
body: Stack(
children: [
if (recommendations.isEmpty)
const Center(
child: Text(
'No outfit recommendations available.',
),
)
else
ListView.builder(
padding:
const EdgeInsets.all(16),
itemCount:
recommendations.length,
itemBuilder:
(context, index) {
final rawOutfit =
recommendations[index];


            if (rawOutfit is! Map) {
              return const SizedBox.shrink();
            }

            final outfit =
                Map<String, dynamic>.from(
              rawOutfit,
            );

            final selectedItems =
                outfit['selected_items']
                        is List
                    ? List<dynamic>.from(
                        outfit[
                            'selected_items'] as List,
                      )
                    : <dynamic>[];

            final category =
                outfit['category']
                        ?.toString() ??
                    'Outfit';

            final stylingAdvice =
                outfit['styling_advice']
                        ?.toString() ??
                    '';

            final isRefreshing =
                _refreshingIndexes
                    .contains(index);

            return Card(
              elevation: 5,
              margin:
                  const EdgeInsets.only(
                bottom: 20,
              ),
              shape:
                  RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(
                  15,
                ),
              ),
              child: Padding(
                padding:
                    const EdgeInsets.all(18),
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      mainAxisAlignment:
                          MainAxisAlignment
                              .spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            category,
                            style:
                                const TextStyle(
                              fontSize: 22,
                              fontWeight:
                                  FontWeight
                                      .bold,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 8,
                        ),
                        AnimatedSwitcher(
                          duration:
                              const Duration(
                            milliseconds: 250,
                          ),
                          transitionBuilder:
                              (
                            child,
                            animation,
                          ) {
                            return FadeTransition(
                              opacity:
                                  animation,
                              child: child,
                            );
                          },
                          child:
                              isRefreshing
                                  ? Column(
                                      key: const ValueKey(
                                        'loading',
                                      ),
                                      mainAxisSize:
                                          MainAxisSize
                                              .min,
                                      children: [
                                        const SizedBox(
                                          width: 24,
                                          height: 24,
                                          child:
                                              CircularProgressIndicator(
                                            strokeWidth:
                                                2,
                                          ),
                                        ),
                                        const SizedBox(
                                          height: 6,
                                        ),
                                        Text(
                                          'Generating new\n$category outfit...',
                                          textAlign:
                                              TextAlign
                                                  .center,
                                          style:
                                              const TextStyle(
                                            fontSize:
                                                11,
                                            color:
                                                Colors
                                                    .grey,
                                            fontStyle:
                                                FontStyle
                                                    .italic,
                                          ),
                                        ),
                                      ],
                                    )
                                  : Tooltip(
                                      key: const ValueKey(
                                        'button',
                                      ),
                                      message:
                                          'Generate another $category outfit',
                                      child:
                                          IconButton(
                                        icon:
                                            const Icon(
                                          Icons
                                              .refresh,
                                        ),
                                        onPressed:
                                            _loading
                                                ? null
                                                : () {
                                                    _regenerateOneRecommendation(
                                                      index,
                                                    );
                                                  },
                                      ),
                                    ),
                        ),
                      ],
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    const Text(
                      'Selected Items',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ...List.generate(
                      selectedItems.length,
                      (itemIndex) {
                        final item =
                            selectedItems[
                                itemIndex];

                        final description =
                            item is Map
                                ? item[
                                            'description']
                                        ?.toString() ??
                                    'Item'
                                : item
                                    .toString();

                        return Padding(
                          padding:
                              const EdgeInsets
                                  .only(
                            bottom: 6,
                          ),
                          child: Text(
                            '• $description',
                          ),
                        );
                      },
                    ),
                    const SizedBox(
                      height: 15,
                    ),
                    Text(
                      stylingAdvice,
                      style:
                          const TextStyle(
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(
                      height: 20,
                    ),
                    SizedBox(
                      width:
                          double.infinity,
                      child:
                          ElevatedButton(
                        onPressed: _loading
                            ? null
                            : () {
                                _generateOutfit(
                                  outfit,
                                );
                              },
                        child:
                            const Text(
                          'Generate This Outfit',
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      if (_loading)
        Container(
          color: Colors.black54,
          child: Center(
            child: Column(
              mainAxisSize:
                  MainAxisSize.min,
              children: [
                const CircularProgressIndicator(),
                const SizedBox(
                  height: 15,
                ),
                Text(
                  _loadingMessage,
                  textAlign:
                      TextAlign.center,
                  style:
                      const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ),
    ],
  ),
);


}
}
