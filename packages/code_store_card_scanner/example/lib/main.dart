import 'package:code_store_card_scanner/code_store_card_scanner.dart';
import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupCardScannerDI();
  runApp(const CardScannerExampleApp());
}

/// Example application demonstrating card scanning.
class CardScannerExampleApp extends StatelessWidget {
  /// Creates the example application.
  const CardScannerExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Card Scanner Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const CardScannerExampleHomePage(),
    );
  }
}

/// Home page of the card scanner example.
class CardScannerExampleHomePage extends StatefulWidget {
  /// Creates the home page.
  const CardScannerExampleHomePage({super.key});

  @override
  State<CardScannerExampleHomePage> createState() =>
      _CardScannerExampleHomePageState();
}

class _CardScannerExampleHomePageState
    extends State<CardScannerExampleHomePage> {
  CardDetails? _scannedCard;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Card Scanner Example'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              if (_scannedCard != null) ...<Widget>[
                CardBrandIcon(
                  cardType: _scannedCard!.cardType,
                  width: 48,
                  height: 30,
                ),
                const SizedBox(height: 12),
                Text(
                  'Card: ${_scannedCard!.formattedNumber}',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                Text(
                  'Expires: ${_scannedCard!.formattedExpiry}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),
              ] else ...<Widget>[
                const Icon(Icons.credit_card, size: 64, color: Colors.grey),
                const SizedBox(height: 16),
                const Text('No card scanned yet.'),
                const SizedBox(height: 24),
              ],
              ElevatedButton.icon(
                icon: const Icon(Icons.camera_alt),
                label: const Text('Scan Card'),
                onPressed: () async {
                  final CardDetails? result =
                      await CardCameraOverlayScanner.show(context);
                  if (result != null && mounted) {
                    setState(() {
                      _scannedCard = result;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
