import 'package:flutter/material.dart';
import '../../../../core/models/recognition_result.dart';

class RecognitionItem extends StatefulWidget {
  final RecognitionResult result;
  final bool isSelected;
  final VoidCallback onTap;

  const RecognitionItem({
    Key? key,
    required this.result,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  State<RecognitionItem> createState() => _RecognitionItemState();
}

class _RecognitionItemState extends State<RecognitionItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.98).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final confidencePercentage =
          (widget.result.confidence * 100).toStringAsFixed(1);

      return GestureDetector(
        onTap: widget.onTap,
        onTapDown: (_) => _controller.forward(),
        onTapUp: (_) => _controller.reverse(),
        onTapCancel: () => _controller.reverse(),
        child: AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return Transform.scale(
              scale: _scaleAnimation.value,
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            margin: const EdgeInsets.symmetric(vertical: 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? Theme.of(context).colorScheme.primary.withAlpha(26)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(12),
              border: widget.isSelected
                  ? Border.all(
                      color: Theme.of(context).colorScheme.primary, width: 2)
                  : Border.all(color: Colors.grey.withAlpha(77)),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color:
                            Theme.of(context).colorScheme.primary.withAlpha(51),
                        blurRadius: 8,
                        spreadRadius: 1,
                        offset: const Offset(0, 2),
                      )
                    ]
                  : null,
            ),
            child: Row(
              children: [
                if (widget.isSelected)
                  Container(
                    margin: const EdgeInsets.only(right: 12),
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.primary,
                      size: 22,
                    ),
                  ),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.result.label,
                        style: TextStyle(
                          fontSize: widget.isSelected ? 16 : 15,
                          fontWeight: widget.isSelected
                              ? FontWeight.bold
                              : FontWeight.w500,
                          color: widget.isSelected
                              ? Theme.of(context).colorScheme.primary
                              : Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      _buildConfidenceIndicator(
                          context, widget.result.confidence),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } catch (e) {
      debugPrint('Error rendering RecognitionItem: $e');
      return const SizedBox
          .shrink(); // Return an empty widget if there's an error
    }
  }

  Widget _buildConfidenceIndicator(BuildContext context, double confidence) {
    final confidencePercentage = (confidence * 100).toStringAsFixed(1);

    Color getColor() {
      if (confidence > 0.8) {
        return Colors.green;
      } else if (confidence > 0.6) {
        return Colors.orangeAccent;
      } else {
        return Colors.redAccent;
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Confidence:',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '$confidencePercentage%',
              style: TextStyle(
                color: getColor(),
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Stack(
          alignment: Alignment.centerLeft,
          children: [
            Container(
              width: 100,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.grey.withAlpha(51),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              curve: Curves.easeInOut,
              width: 100 * confidence,
              height: 6,
              decoration: BoxDecoration(
                color: getColor(),
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
