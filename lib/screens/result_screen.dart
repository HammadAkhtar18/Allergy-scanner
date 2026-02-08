import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/restrictions.dart';
import '../services/product_api.dart';

class ResultScreen extends StatefulWidget {
  const ResultScreen({super.key, required this.barcode});

  final String barcode;

  @override
  State<ResultScreen> createState() => _ResultScreenState();
}

class _ResultScreenState extends State<ResultScreen> {
  final ProductApi _api = ProductApi();

  late Future<ProductInfo?> _future;

  @override
  void initState() {
    super.initState();
    _future = _api.fetchProduct(widget.barcode);
  }

  @override
  Widget build(BuildContext context) {
    final restrictions = context.watch<RestrictionsModel>().restrictions;
    return Scaffold(
      appBar: AppBar(title: const Text('Scan Result')),
      body: FutureBuilder<ProductInfo?>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return _ErrorState(
              message: 'Unable to fetch product. Check your connection and try again.',
              onRetry: () {
                setState(() {
                  _future = _api.fetchProduct(widget.barcode);
                });
              },
            );
          }
          final product = snapshot.data;
          if (product == null) {
            return const _EmptyState();
          }

          final matched = _findMatches(product, restrictions);
          final isUnsafe = matched.isNotEmpty;

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _StatusHeader(isUnsafe: isUnsafe, matched: matched),
              const SizedBox(height: 16),
              if (product.imageUrl != null)
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(product.imageUrl!, height: 220, fit: BoxFit.cover),
                ),
              const SizedBox(height: 16),
              Text(product.name, style: Theme.of(context).textTheme.headlineSmall),
              const SizedBox(height: 12),
              _SectionCard(
                title: 'Ingredients',
                child: _HighlightedText(text: product.ingredients, highlights: matched),
              ),
              _SectionCard(
                title: 'Allergens',
                child: Text(product.allergens),
              ),
              _SectionCard(
                title: 'Labels',
                child: Text(product.labels),
              ),
            ],
          );
        },
      ),
    );
  }

  List<String> _findMatches(ProductInfo product, List<String> restrictions) {
    final combined = '${product.ingredients} ${product.allergens} ${product.labels}'.toLowerCase();
    return restrictions.where((restriction) => combined.contains(restriction)).toList();
  }
}

class _StatusHeader extends StatelessWidget {
  const _StatusHeader({required this.isUnsafe, required this.matched});

  final bool isUnsafe;
  final List<String> matched;

  @override
  Widget build(BuildContext context) {
    final color = isUnsafe ? Colors.red : Colors.green;
    final title = isUnsafe ? 'Potentially unsafe' : 'Looks safe';
    final subtitle = isUnsafe
        ? 'Matches found: ${matched.join(', ')}'
        : 'No matching restrictions found.';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color),
      ),
      child: Row(
        children: [
          Icon(isUnsafe ? Icons.warning : Icons.check_circle, color: color, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: color)),
                const SizedBox(height: 4),
                Text(subtitle),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  const _SectionCard({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(top: 12),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}

class _HighlightedText extends StatelessWidget {
  const _HighlightedText({required this.text, required this.highlights});

  final String text;
  final List<String> highlights;

  @override
  Widget build(BuildContext context) {
    if (highlights.isEmpty) {
      return Text(text);
    }

    final lowerText = text.toLowerCase();
    final spans = <TextSpan>[];
    int start = 0;
    while (start < text.length) {
      final match = _nextMatch(lowerText, start, highlights);
      if (match == null) {
        spans.add(TextSpan(text: text.substring(start)));
        break;
      }
      if (match.start > start) {
        spans.add(TextSpan(text: text.substring(start, match.start)));
      }
      spans.add(
        TextSpan(
          text: text.substring(match.start, match.end),
          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
        ),
      );
      start = match.end;
    }

    return RichText(
      text: TextSpan(
        style: DefaultTextStyle.of(context).style,
        children: spans,
      ),
    );
  }

  _Match? _nextMatch(String text, int start, List<String> highlights) {
    _Match? best;
    for (final highlight in highlights) {
      final index = text.indexOf(highlight.toLowerCase(), start);
      if (index == -1) {
        continue;
      }
      final match = _Match(index, index + highlight.length);
      if (best == null || match.start < best.start) {
        best = match;
      }
    }
    return best;
  }
}

class _Match {
  _Match(this.start, this.end);

  final int start;
  final int end;
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('No product found for this barcode.'),
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({required this.message, required this.onRetry});

  final String message;
  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Try again'),
            ),
          ],
        ),
      ),
    );
  }
}
