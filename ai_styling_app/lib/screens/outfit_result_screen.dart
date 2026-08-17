import 'package:flutter/material.dart';

import '../services/api_service.dart';

class OutfitResultScreen extends StatelessWidget {
  final Map<String, dynamic> result;
  final String functionName;

  const OutfitResultScreen({
    super.key,
    required this.result,
    required this.functionName,
  });

  @override
  Widget build(BuildContext context) {
    final api = ApiService();

    final rawImagePath =
        result['image_path']?.toString() ??
        result['image']?.toString() ??
        result['generated_image_path']
            ?.toString();

    final imageUrl = rawImagePath == null
        ? null
        : api.getImageUrl(rawImagePath);
          
    final recommendation =
        result['recommendation'];

    return Scaffold(
      backgroundColor:
          const Color(0xFFF8F5F0),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor:
            const Color(0xFF2F2924),
        title: const Text(
          'Your Look',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            20,
            10,
            20,
            40,
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                functionName,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.black54,
                  fontWeight: FontWeight.w700,
                ),
              ),

              const SizedBox(height: 7),

              const Text(
                'Your personalised look',
                style: TextStyle(
                  fontSize: 30,
                  height: 1.08,
                  fontWeight: FontWeight.w800,
                  color: Color(0xFF2F2924),
                ),
              ),

              const SizedBox(height: 24),

              if (imageUrl != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(28),
                  child: Image.network(
                    imageUrl,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    loadingBuilder:
                        (context, child, progress) {
                      if (progress == null) {
                        return child;
                      }

                      return Container(
                        height: 500,
                        alignment:
                            Alignment.center,
                        color: Colors.black12,
                        child:
                            const CircularProgressIndicator(),
                      );
                    },
                    errorBuilder:
                        (context, error, stack) {
                      return Container(
                        height: 500,
                        alignment:
                            Alignment.center,
                        color: Colors.black12,
                        child: const Text(
                          'Unable to load generated image.',
                        ),
                      );
                    },
                  ),
                )
              else
                Container(
                  height: 300,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.black12,
                    borderRadius:
                        BorderRadius.circular(28),
                  ),
                  alignment: Alignment.center,
                  child: const Text(
                    'No generated image was returned.',
                  ),
                ),

              const SizedBox(height: 24),

              if (recommendation is Map)
                _RecommendationCard(
                  recommendation:
                      Map<String, dynamic>.from(
                    recommendation,
                  ),
                )
              else if (recommendation != null)
                _TextCard(
                  text: recommendation
                      .toString(),
                ),

              const SizedBox(height: 24),

              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.popUntil(
                      context,
                      (route) => route.isFirst,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF2F2924),
                    foregroundColor: Colors.white,
                    padding:
                        const EdgeInsets.symmetric(
                      vertical: 17,
                    ),
                    shape:
                        RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),
                  child: const Text(
                    'Create Another Look',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _RecommendationCard
    extends StatelessWidget {
  final Map<String, dynamic> recommendation;

  const _RecommendationCard({
    required this.recommendation,
  });

  @override
  Widget build(BuildContext context) {
    final title =
        recommendation['title'] ??
        recommendation['category'] ??
        'Styling Recommendation';

    final advice =
        recommendation['styling_advice'] ??
        recommendation['description'] ??
        recommendation['advice'];

    return _TextCard(
      title: title.toString(),
      text: advice?.toString(),
    );
  }
}

class _TextCard extends StatelessWidget {
  final String? title;
  final String? text;

  const _TextCard({
    this.title,
    this.text,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          if (title != null)
            Text(
              title!,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
              ),
            ),
          if (title != null && text != null)
            const SizedBox(height: 12),
          if (text != null)
            Text(
              text!,
              style: const TextStyle(
                fontSize: 14,
                height: 1.5,
                color: Colors.black54,
              ),
            ),
        ],
      ),
    );
  }
}