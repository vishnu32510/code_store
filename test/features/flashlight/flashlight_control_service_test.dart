import 'package:flutter_test/flutter_test.dart';
import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/services.dart';

class MockToastService implements IToastService {
  @override
  void showError(String message) {}
  @override
  void showInfo(String message) {}
  @override
  void showSuccess(String message) {}
  @override
  void showWarning(String message) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('FlashlightControlService', () {
    late FlashlightControlService service;
    late MockToastService mockToastService;

    setUp(() {
      mockToastService = MockToastService();
      service = FlashlightControlService(toast: mockToastService);

      // Mock the TorchLight method channel to avoid native calls failing
      const MethodChannel('torch_light').setMockMethodCallHandler((MethodCall methodCall) async {
        if (methodCall.method == 'enable_torch') {
          return true;
        } else if (methodCall.method == 'disable_torch') {
          return true;
        }
        return null;
      });
    });

    tearDown(() {
      service.dispose();
      // Remove mock
      const MethodChannel('torch_light').setMockMethodCallHandler(null);
    });

    group('stopEffectsAndTorch', () {
      test('clears all effects and turns off torch when none are active', () async {
        // Act
        await service.stopEffectsAndTorch();

        // Assert
        expect(service.strobeActive, isFalse);
        expect(service.sosActive, isFalse);
        expect(service.isTorchOn, isFalse);
      });

      test('stops strobe if it is running', () async {
        // Arrange
        service.toggleStrobe(); // Starts strobe effect
        expect(service.strobeActive, isTrue);

        // Act
        await service.stopEffectsAndTorch();

        // Assert
        expect(service.strobeActive, isFalse);
        expect(service.sosActive, isFalse);
        expect(service.isTorchOn, isFalse);
      });

      test('stops SOS if it is running', () async {
        // Arrange
        await service.toggleSos(); // Starts SOS effect
        expect(service.sosActive, isTrue);

        // Act
        await service.stopEffectsAndTorch();

        // Assert
        expect(service.strobeActive, isFalse);
        expect(service.sosActive, isFalse);
        expect(service.isTorchOn, isFalse);
      });
    });
  });
}
