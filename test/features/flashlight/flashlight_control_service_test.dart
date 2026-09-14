import 'package:code_store/features/flashlight/flashlight_control_service.dart';
import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';


class MockToastService implements IToastService {
  final List<String> infoMessages = [];
  final List<String> warningMessages = [];
  final List<String> errorMessages = [];
  final List<String> successMessages = [];

  @override
  void showInfo(String message) {
    infoMessages.add(message);
  }

  @override
  void showWarning(String message) {
    warningMessages.add(message);
  }

  @override
  void showError(String message) {
    errorMessages.add(message);
  }

  @override
  void showSuccess(String message) {
    successMessages.add(message);
  }

  void clear() {
    infoMessages.clear();
    warningMessages.clear();
    errorMessages.clear();
    successMessages.clear();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late FlashlightControlService service;
  late MockToastService mockToast;

  const channelName = 'com.svprdga.torchlight/main';
  const methodEnable = 'enable_torch';
  const methodDisable = 'disable_torch';

  setUp(() {
    mockToast = MockToastService();
    service = FlashlightControlService(toast: mockToast);
  });

  tearDown(() {
    service.dispose();
  });

  void mockTorchLightResponse({
    Object? enableResponse,
    Object? disableResponse,
  }) {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(const MethodChannel(channelName), (
          MethodCall methodCall,
        ) async {
          if (methodCall.method == methodEnable) {
            if (enableResponse is Exception) {
              throw enableResponse;
            }
            return enableResponse;
          }
          if (methodCall.method == methodDisable) {
            if (disableResponse is Exception) {
              throw disableResponse;
            }
            return disableResponse;
          }
          return null;
        });
  }

  group('FlashlightControlService.handleMainTap', () {
    test('stops effects if active and returns stoppedEffects', () async {
      mockTorchLightResponse(enableResponse: null, disableResponse: null);

      // Start an effect (e.g., strobe)
      service.toggleStrobe();
      // toggleStrobe is synchronous up to state change, though ticks are async
      expect(service.strobeActive, isTrue);

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.stoppedEffects);
      expect(service.strobeActive, isFalse);
    });

    test('turns on torch if off and returns turnedOn', () async {
      mockTorchLightResponse(enableResponse: null);

      var notified = false;
      service.addListener(() {
        notified = true;
      });

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.turnedOn);
      expect(service.isTorchOn, isTrue);
      expect(notified, isTrue);
    });

    test('turns off torch if already on and returns turnedOff', () async {
      mockTorchLightResponse(enableResponse: null, disableResponse: null);
      await service.handleMainTap(); // turn it on first

      var notified = false;
      service.addListener(() {
        notified = true;
      });

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.turnedOff);
      expect(service.isTorchOn, isFalse);
      expect(notified, isTrue);
    });

    test('handles EnableTorchExistentUserException correctly', () async {
      mockTorchLightResponse(
        enableResponse: PlatformException(
          code: 'enable_torch_error_existent_user',
        ),
      );

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.turnedOn);
      expect(service.isTorchOn, isTrue);
      expect(mockToast.warningMessages, contains('Torch is already enabled.'));
    });

    test('handles DisableTorchExistentUserException correctly', () async {
      // First, turn it on successfully
      mockTorchLightResponse(enableResponse: null);
      await service.handleMainTap();

      // Then mock disable to throw
      mockTorchLightResponse(
        disableResponse: PlatformException(
          code: 'disable_torch_error_existent_user',
        ),
      );

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.turnedOff);
      expect(service.isTorchOn, isFalse);
      expect(mockToast.warningMessages, contains('Torch is already disabled.'));
    });

    test('handles EnableTorchNotAvailableException correctly', () async {
      mockTorchLightResponse(
        enableResponse: PlatformException(code: 'enable_torch_not_available'),
      );

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.unchanged);
      expect(service.isTorchOn, isFalse);
      expect(
        mockToast.errorMessages,
        contains('Torch is not available on this device.'),
      );
    });

    test('handles generic EnableTorchException correctly', () async {
      mockTorchLightResponse(
        enableResponse: PlatformException(code: 'unknown_error'),
      );

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.unchanged);
      expect(service.isTorchOn, isFalse);
      expect(mockToast.errorMessages, contains('Could not enable torch.'));
    });

    test('handles generic DisableTorchException correctly', () async {
      // First turn it on
      mockTorchLightResponse(enableResponse: null);
      await service.handleMainTap();

      // Then mock disable to throw unknown error
      mockTorchLightResponse(
        disableResponse: PlatformException(code: 'unknown_error'),
      );

      final result = await service.handleMainTap();

      expect(result, TorchMainTapOutcome.unchanged);
      expect(service.isTorchOn, isTrue);
      expect(mockToast.errorMessages, contains('Could not disable torch.'));
    });

    test(
      'handles generic Exception correctly (via mocked method call handler)',
      () async {
        // Note: TorchLight methods internally catch PlatformException and throw specific
        // exceptions (EnableTorchException, etc). If they get something that is not
        // a PlatformException, it will bubble up and be caught by the generic catch (_) in handleMainTap.
        // However, a MethodChannel mock handler's thrown exception will be wrapped into PlatformException.
        // To test the final catch (_) block, we can simulate an error during disable where
        // the error is anything else. But wait, we can't easily throw a non-PlatformException
        // from a MethodChannel mock.
        // Another way is to trigger it by mocking the kIsWeb part if we can't do it via MethodChannel.
        // Actually, if we throw MissingPluginException from the channel, does it get caught as PlatformException?
        // MissingPluginException is NOT a PlatformException.
        mockTorchLightResponse(
          enableResponse: MissingPluginException('No implementation found'),
        );

        final result = await service.handleMainTap();

        expect(result, TorchMainTapOutcome.unchanged);
        expect(service.isTorchOn, isFalse);
        expect(mockToast.errorMessages, contains('Torch action failed.'));
      },
    );
  });
}
