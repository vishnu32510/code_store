import 'package:flutter/material.dart';
import '../models/card_type.dart';

/// Crisp, vector-rendered card brand badge suitable for input field suffix/postfix icons
/// and card preview banners.
class CardBrandIcon extends StatelessWidget {
  const CardBrandIcon({
    super.key,
    required this.cardType,
    this.width = 38,
    this.height = 24,
    this.animate = true,
  });

  /// The detected card brand type.
  final CardType cardType;

  /// Width of the badge.
  final double width;

  /// Height of the badge.
  final double height;

  /// Whether to smoothly animate transitions between card brands.
  final bool animate;

  @override
  Widget build(BuildContext context) {
    final badge = _buildBrandBadge(context);

    if (!animate) return badge;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 250),
      transitionBuilder: (child, animation) {
        return FadeTransition(
          opacity: animation,
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.85, end: 1.0).animate(animation),
            child: child,
          ),
        );
      },
      child: KeyedSubtree(
        key: ValueKey<CardType>(cardType),
        child: badge,
      ),
    );
  }

  Widget _buildBrandBadge(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: _badgeBackgroundColor,
        borderRadius: BorderRadius.circular(5),
        border: Border.all(
          color: _badgeBorderColor,
          width: 0.8,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 3,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      alignment: Alignment.center,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: _buildBadgeContent(context),
        ),
      ),
    );
  }

  Color get _badgeBackgroundColor {
    switch (cardType) {
      case CardType.visa:
        return const Color(0xFF1A1F71);
      case CardType.mastercard:
        return const Color(0xFF222222);
      case CardType.americanExpress:
        return const Color(0xFF007BC1);
      case CardType.discover:
        return const Color(0xFFFFFFFF);
      case CardType.jcb:
        return const Color(0xFFFFFFFF);
      case CardType.dinersClub:
        return const Color(0xFF004A7F);
      case CardType.unionPay:
        return const Color(0xFFFFFFFF);
      case CardType.maestro:
        return const Color(0xFF252525);
      case CardType.elo:
        return const Color(0xFF000000);
      case CardType.unknown:
        return Colors.transparent;
    }
  }

  Color get _badgeBorderColor {
    switch (cardType) {
      case CardType.unknown:
        return Colors.grey.withValues(alpha: 0.35);
      case CardType.discover:
      case CardType.jcb:
      case CardType.unionPay:
        return const Color(0xFFD0D0D0);
      default:
        return Colors.black.withValues(alpha: 0.2);
    }
  }

  Widget _buildBadgeContent(BuildContext context) {
    switch (cardType) {
      case CardType.visa:
        return const Center(
          child: Text(
            'VISA',
            style: TextStyle(
              color: Colors.white,
              fontSize: 10.5,
              fontWeight: FontWeight.w900,
              fontStyle: FontStyle.italic,
              letterSpacing: 0.8,
            ),
          ),
        );

      case CardType.mastercard:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 13,
              height: 13,
              decoration: const BoxDecoration(
                color: Color(0xFFEB001B),
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-5, 0),
              child: Container(
                width: 13,
                height: 13,
                decoration: BoxDecoration(
                  color: const Color(0xFFF79E1B).withValues(alpha: 0.88),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );

      case CardType.americanExpress:
        return const Center(
          child: Text(
            'AMEX',
            style: TextStyle(
              color: Colors.white,
              fontSize: 8.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.6,
            ),
          ),
        );

      case CardType.discover:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DISC',
              style: TextStyle(
                color: Color(0xFF1E2838),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
              ),
            ),
            Container(
              width: 7.5,
              height: 7.5,
              margin: const EdgeInsets.symmetric(horizontal: 1),
              decoration: const BoxDecoration(
                color: Color(0xFFFF6000),
                shape: BoxShape.circle,
              ),
            ),
            const Text(
              'VER',
              style: TextStyle(
                color: Color(0xFF1E2838),
                fontSize: 7.5,
                fontWeight: FontWeight.w900,
              ),
            ),
          ],
        );

      case CardType.jcb:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildJcbPill(const Color(0xFF003780)),
            const SizedBox(width: 1),
            _buildJcbPill(const Color(0xFFCC0000)),
            const SizedBox(width: 1),
            _buildJcbPill(const Color(0xFF006837)),
          ],
        );

      case CardType.dinersClub:
        return const Center(
          child: Text(
            'DINERS',
            style: TextStyle(
              color: Colors.white,
              fontSize: 7.5,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        );

      case CardType.unionPay:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 8,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFFB31B1B),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Container(
              width: 8,
              height: 14,
              decoration: BoxDecoration(
                color: const Color(0xFF006670),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ],
        );

      case CardType.maestro:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 11,
              height: 11,
              decoration: const BoxDecoration(
                color: Color(0xFF0061A8),
                shape: BoxShape.circle,
              ),
            ),
            Transform.translate(
              offset: const Offset(-4, 0),
              child: Container(
                width: 11,
                height: 11,
                decoration: const BoxDecoration(
                  color: Color(0xFFEB001B),
                  shape: BoxShape.circle,
                ),
              ),
            ),
          ],
        );

      case CardType.elo:
        return const Center(
          child: Text(
            'elo',
            style: TextStyle(
              color: Color(0xFF00A4E0),
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        );

      case CardType.unknown:
        return Icon(
          Icons.credit_card_rounded,
          size: 16,
          color: Theme.of(context).colorScheme.outline,
        );
    }
  }

  Widget _buildJcbPill(Color color) {
    return Container(
      width: 6,
      height: 14,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(2),
      ),
    );
  }
}
