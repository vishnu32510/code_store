import 'dart:async';

import 'package:code_store_core/code_store_core.dart';
import 'package:flutter/foundation.dart';
import 'package:torch_light/torch_light.dart';

/// Outcome of the main flashlight control tap (for UI haptics).
enum TorchMainTapOutcome {
  /// Strobe or SOS was running and was cleared.
  stoppedEffects,

  /// Torch is now on.
  turnedOn,

  /// Torch is now off.
  turnedOff,

  /// State did not change meaningfully (e.g. error toast only).
  unchanged,
}

/// Outcome of the SOS button (for UI haptics).
enum TorchSosOutcome { started, stopped }

/// Torch, strobe (~1 Hz), and Morse SOS — not for photosensitive epilepsy.
class FlashlightControlService extends ChangeNotifier {
  FlashlightControlService({required this.toast});

  final IToastService toast;

  /// ~1 Hz on/off — see UI disclaimer.
  static const Duration strobeHalfPeriod = Duration(milliseconds: 500);

  bool _isOn = false;
  bool _strobeActive = false;
  bool _strobeLit = false;
  Timer? _strobeTimer;
  bool _sosActive = false;

  bool get isTorchOn => _isOn;
  bool get strobeActive => _strobeActive;
  bool get sosActive => _sosActive;

  bool get _effectsActive => _strobeActive || _sosActive;

  @override
  void dispose() {
    _strobeTimer?.cancel();
    _sosActive = false;
    unawaited(_torchOffQuiet());
    super.dispose();
  }

  Future<void> _torchOffQuiet() async {
    try {
      await TorchLight.disableTorch();
    } catch (_) {}
  }

  void _stopStrobe() {
    _strobeTimer?.cancel();
    _strobeTimer = null;
    _strobeActive = false;
    _strobeLit = false;
  }

  void _stopSos() {
    _sosActive = false;
  }

  Future<void> stopEffectsAndTorch() async {
    _stopStrobe();
    _stopSos();
    try {
      await TorchLight.disableTorch();
      _isOn = false;
      notifyListeners();
    } catch (_) {
      _isOn = false;
      notifyListeners();
    }
  }

  Future<TorchMainTapOutcome> handleMainTap() async {
    if (_effectsActive) {
      await stopEffectsAndTorch();
      return TorchMainTapOutcome.stoppedEffects;
    }

    try {
      if (_isOn) {
        await TorchLight.disableTorch();
        _isOn = false;
        notifyListeners();
        return TorchMainTapOutcome.turnedOff;
      }

      await TorchLight.enableTorch();
      _isOn = true;
      notifyListeners();
      return TorchMainTapOutcome.turnedOn;
    } on EnableTorchExistentUserException {
      toast.showWarning('Torch is already enabled.');
      _isOn = true;
      notifyListeners();
      return TorchMainTapOutcome.turnedOn;
    } on DisableTorchExistentUserException {
      toast.showWarning('Torch is already disabled.');
      _isOn = false;
      notifyListeners();
      return TorchMainTapOutcome.turnedOff;
    } on EnableTorchNotAvailableException {
      toast.showError('Torch is not available on this device.');
      return TorchMainTapOutcome.unchanged;
    } on EnableTorchException catch (_) {
      toast.showError('Could not enable torch.');
      return TorchMainTapOutcome.unchanged;
    } on DisableTorchException catch (_) {
      toast.showError('Could not disable torch.');
      return TorchMainTapOutcome.unchanged;
    } catch (_) {
      toast.showError('Torch action failed.');
      return TorchMainTapOutcome.unchanged;
    }
  }

  Future<void> _strobeTick() async {
    if (!_strobeActive) return;
    _strobeLit = !_strobeLit;
    try {
      if (_strobeLit) {
        await TorchLight.enableTorch();
        _isOn = true;
      } else {
        await TorchLight.disableTorch();
        _isOn = false;
      }
      notifyListeners();
    } catch (_) {
      _stopStrobe();
      notifyListeners();
    }
  }

  void toggleStrobe() {
    if (_sosActive) {
      _stopSos();
      unawaited(_torchOffQuiet());
    }

    if (_strobeActive) {
      _stopStrobe();
      unawaited(_torchOffQuiet());
      _isOn = false;
      notifyListeners();
      return;
    }

    _strobeActive = true;
    _strobeLit = false;
    notifyListeners();

    _strobeTimer?.cancel();
    unawaited(_strobeTick());
    _strobeTimer = Timer.periodic(strobeHalfPeriod, (_) {
      unawaited(_strobeTick());
    });
  }

  Future<void> _flashShort() async {
    try {
      await TorchLight.enableTorch();
      _isOn = true;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 200));
      await TorchLight.disableTorch();
      _isOn = false;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 220));
    } catch (_) {}
  }

  Future<void> _flashLong() async {
    try {
      await TorchLight.enableTorch();
      _isOn = true;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 600));
      await TorchLight.disableTorch();
      _isOn = false;
      notifyListeners();
      await Future<void>.delayed(const Duration(milliseconds: 220));
    } catch (_) {}
  }

  Future<void> _sosPatternOnce() async {
    for (var i = 0; i < 3; i++) {
      if (!_sosActive) return;
      await _flashShort();
    }
    await Future<void>.delayed(const Duration(milliseconds: 420));
    for (var i = 0; i < 3; i++) {
      if (!_sosActive) return;
      await _flashLong();
    }
    await Future<void>.delayed(const Duration(milliseconds: 420));
    for (var i = 0; i < 3; i++) {
      if (!_sosActive) return;
      await _flashShort();
    }
  }

  Future<void> _runSosLoop() async {
    while (_sosActive) {
      await _sosPatternOnce();
      if (!_sosActive) break;
      await Future<void>.delayed(const Duration(seconds: 2));
    }
    if (!_sosActive) {
      await _torchOffQuiet();
      _isOn = false;
      notifyListeners();
    }
  }

  Future<TorchSosOutcome> toggleSos() async {
    if (_strobeActive) {
      _stopStrobe();
      unawaited(_torchOffQuiet());
    }

    if (_sosActive) {
      await stopEffectsAndTorch();
      return TorchSosOutcome.stopped;
    }

    _sosActive = true;
    notifyListeners();
    unawaited(_runSosLoop());
    return TorchSosOutcome.started;
  }
}
