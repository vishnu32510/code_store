import 'dart:math' as math;
import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CardScannerScreen extends StatefulWidget {
  const CardScannerScreen({super.key});

  @override
  State<CardScannerScreen> createState() => _CardScannerScreenState();
}

class _CardScannerScreenState extends State<CardScannerScreen>
    with SingleTickerProviderStateMixin {
  final ICardScannerService _scannerService = getIt<ICardScannerService>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  // Text Controllers
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _cardHolderController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  // Focus Nodes
  final FocusNode _cardNumberFocus = FocusNode();
  final FocusNode _cardHolderFocus = FocusNode();
  final FocusNode _expiryFocus = FocusNode();
  final FocusNode _cvvFocus = FocusNode();

  // Animation controller for 3D card flip
  late final AnimationController _flipController;
  late final Animation<double> _flipAnimation;

  // Card State
  CardType _detectedType = CardType.unknown;
  bool _isCardFlipped = false;
  bool _isScanning = false;
  bool _obscureCvv = true;
  bool _isLuhnValid = false;

  @override
  void initState() {
    super.initState();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _flipAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _flipController, curve: Curves.easeInOutCubic),
    );

    // Auto flip card to back when CVV field is focused
    _cvvFocus.addListener(() {
      if (_cvvFocus.hasFocus && !_isCardFlipped) {
        _flipCard(showBack: true);
      } else if (!_cvvFocus.hasFocus && _isCardFlipped) {
        _flipCard(showBack: false);
      }
    });

    _cardNumberController.addListener(_onCardNumberChanged);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _cardNumberController.removeListener(_onCardNumberChanged);
    _cardNumberController.dispose();
    _cardHolderController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    _cardNumberFocus.dispose();
    _cardHolderFocus.dispose();
    _expiryFocus.dispose();
    _cvvFocus.dispose();
    super.dispose();
  }

  void _onCardNumberChanged() {
    final rawNumber = _cardNumberController.text;
    final cleanDigits = rawNumber.replaceAll(RegExp(r'\D'), '');
    final detected = CardValidator.detectType(cleanDigits);
    final isValid = cleanDigits.length >= 13 && CardValidator.validateLuhn(cleanDigits);

    if (detected != _detectedType || isValid != _isLuhnValid) {
      setState(() {
        _detectedType = detected;
        _isLuhnValid = isValid;
      });
    }
  }

  void _flipCard({bool? showBack}) {
    final target = showBack ?? !_isCardFlipped;
    if (target) {
      _flipController.forward();
    } else {
      _flipController.reverse();
    }
    setState(() => _isCardFlipped = target);
  }

  Future<void> _startScan() async {
    setState(() => _isScanning = true);
    FocusScope.of(context).unfocus();

    try {
      final result = await _scannerService.scanCard(mockFallbackIfUnavailable: true);

      if (!mounted) return;

      if (result.success && result.cardDetails != null) {
        final details = result.cardDetails!;
        setState(() {
          _cardNumberController.text = details.formattedNumber;
          _detectedType = details.cardType;
          if (details.cardHolderName.isNotEmpty) {
            _cardHolderController.text = details.cardHolderName;
          }
          if (details.formattedExpiry.isNotEmpty) {
            _expiryController.text = details.formattedExpiry;
          }
          if (details.cvv.isNotEmpty) {
            _cvvController.text = details.cvv;
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle_rounded, color: Colors.white),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Card details extracted successfully (${details.cardType.displayName})',
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );
      } else if (!result.isCancelled && result.errorMessage != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result.errorMessage!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to scan card: $e'),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isScanning = false);
      }
    }
  }

  void _applyPresetCard({
    required String number,
    required String holder,
    required String expiry,
    required String cvv,
  }) {
    setState(() {
      _cardNumberController.text = number;
      _cardHolderController.text = holder;
      _expiryController.text = expiry;
      _cvvController.text = cvv;
      _detectedType = CardValidator.detectType(number);
      _isLuhnValid = CardValidator.validateLuhn(number);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Filled preset: ${_detectedType.displayName}'),
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _clearForm() {
    _formKey.currentState?.reset();
    setState(() {
      _cardNumberController.clear();
      _cardHolderController.clear();
      _expiryController.clear();
      _cvvController.clear();
      _detectedType = CardType.unknown;
      _isLuhnValid = false;
      if (_isCardFlipped) _flipCard(showBack: false);
    });
  }

  void _saveCardDetails() {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final rawNumber = _cardNumberController.text.replaceAll(RegExp(r'\D'), '');
    final expParts = _expiryController.text.split('/');
    final month = expParts.isNotEmpty ? int.tryParse(expParts[0]) : null;
    final year = expParts.length > 1 ? int.tryParse(expParts[1]) : null;

    final card = CardDetails(
      cardNumber: rawNumber,
      expiryMonth: month,
      expiryYear: year,
      cardHolderName: _cardHolderController.text.trim(),
      cvv: _cvvController.text.trim(),
      cardType: _detectedType,
    );

    showModalBottomSheet<void>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) {
        final colors = Theme.of(sheetContext).colorScheme;
        return Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.withValues(alpha: 0.4),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.green.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_circle_rounded,
                      color: Colors.green,
                      size: 28,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Card Added Successfully',
                          style: Theme.of(sheetContext).textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                        ),
                        Text(
                          'Verified via Luhn Mod-10 Checksum',
                          style: Theme.of(sheetContext).textTheme.bodySmall?.copyWith(
                                color: colors.onSurfaceVariant,
                              ),
                        ),
                      ],
                    ),
                  ),
                  CardBrandIcon(cardType: card.cardType, width: 44, height: 28),
                ],
              ),
              const SizedBox(height: 20),
              const Divider(),
              const SizedBox(height: 12),
              _buildDetailRow(sheetContext, 'Card Brand', card.cardType.displayName),
              _buildDetailRow(sheetContext, 'Masked Number', card.maskedNumber),
              _buildDetailRow(sheetContext, 'Cardholder', card.cardHolderName.isEmpty ? 'N/A' : card.cardHolderName),
              _buildDetailRow(sheetContext, 'Expires', card.formattedExpiry),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(sheetContext).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: colors.primary,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Done',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
          Text(
            value,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner & Details'),
        actions: [
          IconButton(
            tooltip: 'Clear form',
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _clearForm,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // 1. Interactive 3D Card Preview
              GestureDetector(
                onTap: () => _flipCard(),
                child: AnimatedBuilder(
                  animation: _flipAnimation,
                  builder: (context, child) {
                    final angle = _flipAnimation.value * math.pi;
                    final isUnder = _flipAnimation.value > 0.5;

                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.0012)
                        ..rotateY(angle),
                      alignment: Alignment.center,
                      child: isUnder
                          ? Transform(
                              transform: Matrix4.identity()..rotateY(math.pi),
                              alignment: Alignment.center,
                              child: _buildCardBack(context),
                            )
                          : _buildCardFront(context),
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isCardFlipped ? 'Tap card to view front' : 'Tap card to view back & CVV',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colors.onSurfaceVariant.withValues(alpha: 0.7),
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // 2. Scan Card Action Button
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [colors.primary, colors.tertiary],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: colors.primary.withValues(alpha: 0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ElevatedButton.icon(
                  onPressed: _isScanning ? null : _startScan,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    shadowColor: Colors.transparent,
                    foregroundColor: colors.onPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isScanning
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.photo_camera_rounded, size: 22),
                  label: Text(
                    _isScanning ? 'Opening Card Scanner...' : 'Scan Debit / Credit Card',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      letterSpacing: 0.3,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // 3. Quick Preset Test Chips
              _buildPresetChipsSection(context),

              const SizedBox(height: 20),

              // 4. Manual Card Details Form
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: colors.surfaceContainerHighest.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: colors.outlineVariant.withValues(alpha: 0.4),
                  ),
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.credit_card_rounded,
                            size: 20,
                            color: colors.primary,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Card Details',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const Spacer(),
                          if (_isLuhnValid)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.check_circle_rounded,
                                    size: 13,
                                    color: Colors.green,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Valid Checksum',
                                    style: TextStyle(
                                      color: Colors.green,
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // Card Number with Real-time Regex Brand Detection and Postfix Icon!
                      TextFormField(
                        controller: _cardNumberController,
                        focusNode: _cardNumberFocus,
                        keyboardType: TextInputType.number,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(19),
                          _CardNumberFormatter(),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Card Number',
                          hintText: '•••• •••• •••• ••••',
                          prefixIcon: const Icon(Icons.pin_rounded),
                          // Postfix icon showing the real-time detected card brand!
                          suffixIcon: Padding(
                            padding: const EdgeInsets.only(right: 10),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isLuhnValid)
                                  const Padding(
                                    padding: EdgeInsets.only(right: 6),
                                    child: Icon(
                                      Icons.check_circle_rounded,
                                      color: Colors.green,
                                      size: 18,
                                    ),
                                  ),
                                CardBrandIcon(
                                  cardType: _detectedType,
                                  width: 40,
                                  height: 26,
                                ),
                              ],
                            ),
                          ),
                          helperText: _detectedType != CardType.unknown
                              ? 'Detected: ${_detectedType.displayName}'
                              : 'Supports Visa, Mastercard, Amex, Discover, etc.',
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        validator: (value) {
                          final clean = (value ?? '').replaceAll(RegExp(r'\D'), '');
                          if (clean.isEmpty) {
                            return 'Please enter a card number';
                          }
                          if (clean.length < 13) {
                            return 'Card number is too short';
                          }
                          if (!CardValidator.validateLuhn(clean)) {
                            return 'Invalid card number checksum (Luhn check)';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Cardholder Name
                      TextFormField(
                        controller: _cardHolderController,
                        focusNode: _cardHolderFocus,
                        textCapitalization: TextCapitalization.characters,
                        textInputAction: TextInputAction.next,
                        inputFormatters: [
                          LengthLimitingTextInputFormatter(32),
                        ],
                        decoration: InputDecoration(
                          labelText: 'Cardholder Name',
                          hintText: 'JOHN DOE',
                          prefixIcon: const Icon(Icons.person_outline_rounded),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        onChanged: (_) => setState(() {}),
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
                            return 'Please enter the cardholder name';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 14),

                      // Expiry Date and CVV Row
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Expiry Field
                          Expanded(
                            flex: 3,
                            child: TextFormField(
                              controller: _expiryController,
                              focusNode: _expiryFocus,
                              keyboardType: TextInputType.number,
                              textInputAction: TextInputAction.next,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(4),
                                _CardExpiryFormatter(),
                              ],
                              decoration: InputDecoration(
                                labelText: 'Expires',
                                hintText: 'MM/YY',
                                prefixIcon: const Icon(Icons.calendar_today_outlined),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Enter MM/YY';
                                }
                                final parts = value.split('/');
                                if (parts.length != 2) return 'Invalid MM/YY';
                                final month = int.tryParse(parts[0]);
                                final year = int.tryParse(parts[1]);
                                if (!CardValidator.validateExpiry(month, year)) {
                                  return 'Expired / invalid';
                                }
                                return null;
                              },
                            ),
                          ),

                          const SizedBox(width: 12),

                          // CVV Field
                          Expanded(
                            flex: 2,
                            child: TextFormField(
                              controller: _cvvController,
                              focusNode: _cvvFocus,
                              keyboardType: TextInputType.number,
                              obscureText: _obscureCvv,
                              textInputAction: TextInputAction.done,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                                LengthLimitingTextInputFormatter(_detectedType.cvvLength),
                              ],
                              decoration: InputDecoration(
                                labelText: 'CVV',
                                hintText: _detectedType.cvvLength == 4 ? '1234' : '123',
                                prefixIcon: const Icon(Icons.lock_outline_rounded),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscureCvv
                                        ? Icons.visibility_off_outlined
                                        : Icons.visibility_outlined,
                                    size: 18,
                                  ),
                                  onPressed: () {
                                    setState(() => _obscureCvv = !_obscureCvv);
                                  },
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              onChanged: (_) => setState(() {}),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Required';
                                }
                                if (!CardValidator.validateCvv(value, _detectedType)) {
                                  return '${_detectedType.cvvLength} digits';
                                }
                                return null;
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 20),

                      // Save Card Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveCardDetails,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: colors.primary,
                            foregroundColor: colors.onPrimary,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            'Save Card Details',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  // MARK: - Card Front View
  Widget _buildCardFront(BuildContext context) {
    final gradientColors = _detectedType.gradientColors;
    final formattedNumber = _cardNumberController.text.isEmpty
        ? '•••• •••• •••• ••••'
        : _cardNumberController.text;
    final cardHolder = _cardHolderController.text.isEmpty
        ? 'CARDHOLDER NAME'
        : _cardHolderController.text.toUpperCase();
    final expiry = _expiryController.text.isEmpty
        ? 'MM/YY'
        : _expiryController.text;

    return Container(
      height: 215,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Top Row: Chip + Brand
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // EMV Chip
              Container(
                width: 44,
                height: 32,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFFFDF7A), Color(0xFFD4AF37)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.2),
                      blurRadius: 3,
                    ),
                  ],
                ),
                child: Center(
                  child: Container(
                    width: 32,
                    height: 22,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.brown.withValues(alpha: 0.5),
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(3),
                    ),
                  ),
                ),
              ),
              const Icon(
                Icons.contactless_rounded,
                color: Colors.white70,
                size: 26,
              ),
              const Spacer(),
              // Detected Brand Badge
              CardBrandIcon(
                cardType: _detectedType,
                width: 52,
                height: 32,
              ),
            ],
          ),

          const Spacer(),

          // Card Number
          Text(
            formattedNumber,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              letterSpacing: 2.2,
              fontWeight: FontWeight.w600,
              fontFamily: 'monospace',
              shadows: [
                Shadow(
                  color: Colors.black45,
                  blurRadius: 3,
                  offset: Offset(0, 1.5),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Bottom Row: Holder Name & Expiry
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'CARDHOLDER',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 9,
                        letterSpacing: 1.1,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      cardHolder,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    'EXPIRES',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 9,
                      letterSpacing: 1.1,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    expiry,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1,
                      fontFamily: 'monospace',
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // MARK: - Card Back View (with CVV and Magnetic Stripe)
  Widget _buildCardBack(BuildContext context) {
    final gradientColors = _detectedType.gradientColors;
    final cvvText = _cvvController.text.isEmpty
        ? '•••'
        : _obscureCvv
            ? '•' * _cvvController.text.length
            : _cvvController.text;

    return Container(
      height: 215,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.4),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 22),
          // Magnetic Stripe
          Container(
            height: 44,
            width: double.infinity,
            color: const Color(0xFF1B1B1B),
          ),
          const SizedBox(height: 18),
          // Signature Bar & CVV
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 38,
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    color: Colors.white,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      _cardHolderController.text.toUpperCase(),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontStyle: FontStyle.italic,
                        fontWeight: FontWeight.bold,
                        fontSize: 11,
                      ),
                    ),
                  ),
                ),
                Container(
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  color: Colors.amber.shade100,
                  alignment: Alignment.center,
                  child: Text(
                    cvvText,
                    style: const TextStyle(
                      color: Colors.black,
                      fontFamily: 'monospace',
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                      letterSpacing: 2,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Authorized Signature • Not Transferable',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 8.5,
                  ),
                ),
                CardBrandIcon(cardType: _detectedType, width: 38, height: 22),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // MARK: - Preset Test Cards Section
  Widget _buildPresetChipsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              Icons.flash_on_rounded,
              size: 16,
              color: Theme.of(context).colorScheme.primary,
            ),
            const SizedBox(width: 6),
            Text(
              'Quick Test Presets (Simulator)',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: Row(
            children: [
              _buildPresetChip(
                label: 'Visa',
                cardType: CardType.visa,
                number: '4532 0151 1283 0366',
                holder: 'ALICE SMITH',
                expiry: '12/28',
                cvv: '842',
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Mastercard',
                cardType: CardType.mastercard,
                number: '5555 5555 5555 4444',
                holder: 'BOB JOHNSON',
                expiry: '09/27',
                cvv: '123',
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Amex',
                cardType: CardType.americanExpress,
                number: '3782 822463 10005',
                holder: 'CAROL WILLIAMS',
                expiry: '11/29',
                cvv: '7890',
              ),
              const SizedBox(width: 8),
              _buildPresetChip(
                label: 'Discover',
                cardType: CardType.discover,
                number: '6011 0009 9013 9424',
                holder: 'DAVID BROWN',
                expiry: '04/26',
                cvv: '456',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPresetChip({
    required String label,
    required CardType cardType,
    required String number,
    required String holder,
    required String expiry,
    required String cvv,
  }) {
    return ActionChip(
      avatar: CardBrandIcon(cardType: cardType, width: 22, height: 14),
      label: Text(label),
      onPressed: () => _applyPresetCard(
        number: number,
        holder: holder,
        expiry: expiry,
        cvv: cvv,
      ),
    );
  }
}

// MARK: - Formatters

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted = CardValidator.formatNumber(clean);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardExpiryFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final clean = newValue.text.replaceAll(RegExp(r'\D'), '');
    if (clean.isEmpty) {
      return newValue.copyWith(text: '');
    }

    final formatted = CardValidator.formatExpiry(clean);
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
