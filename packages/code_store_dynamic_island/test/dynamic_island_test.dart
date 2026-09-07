import 'package:code_store_dynamic_island/code_store_dynamic_island.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:get_it/get_it.dart';

/// Mock implementation of [IDynamicIslandService] for testing.
class MockDynamicIslandService implements IDynamicIslandService {
  bool supportedResult = false;
  bool startStatusCalled = false;
  bool startAnimationCalled = false;
  bool updateStatusCalled = false;
  bool endActivityCalled = false;
  int sliceResult = 0;

  @override
  Future<bool> isSupported() async => supportedResult;

  @override
  Future<bool> startStatus(IslandStatus status) async {
    startStatusCalled = true;
    return true;
  }

  @override
  Future<bool> startAnimation(IslandAnimationConfig config) async {
    startAnimationCalled = true;
    return true;
  }

  @override
  Future<bool> updateStatus(IslandStatus status) async {
    updateStatusCalled = true;
    return true;
  }

  @override
  Future<bool> endActivity() async {
    endActivityCalled = true;
    return true;
  }

  @override
  Future<int> sliceSpriteSheet({
    required String assetPath,
    required String animationName,
    required int columns,
    required int rows,
    int? startRow,
    int? endRow,
  }) async {
    return sliceResult;
  }
}

void main() {
  group('Dynamic Island Models', () {
    test('IslandAnimationConfig toMap/fromMap roundtrip', () {
      const config = IslandAnimationConfig(
        animationName: 'retro_cat_idle',
        totalFrames: 4,
        framesPerSecond: 10,
        frameWidth: 64,
        frameHeight: 64,
        placement: IslandPlacement.compactLeading,
      );

      final map = config.toMap();
      expect(map['animationName'], 'retro_cat_idle');
      expect(map['totalFrames'], 4);
      expect(map['framesPerSecond'], 10);
      expect(map['placement'], 'compactLeading');

      final restored = IslandAnimationConfig.fromMap(map);
      expect(restored.animationName, config.animationName);
      expect(restored.totalFrames, config.totalFrames);
      expect(restored.framesPerSecond, config.framesPerSecond);
      expect(restored.placement, config.placement);
    });

    test('IslandAnimationConfig copyWith', () {
      const config = IslandAnimationConfig(
        animationName: 'test',
        totalFrames: 4,
      );

      final updated = config.copyWith(
        framesPerSecond: 15,
        placement: IslandPlacement.both,
      );

      expect(updated.animationName, 'test');
      expect(updated.framesPerSecond, 15);
      expect(updated.placement, IslandPlacement.both);
    });

    test('IslandStatus toMap/fromMap roundtrip', () {
      const status = IslandStatus(
        title: 'Recording',
        subtitle: 'In progress...',
        iconSystemName: 'record.circle',
        isActive: true,
      );

      final map = status.toMap();
      expect(map['title'], 'Recording');
      expect(map['subtitle'], 'In progress...');
      expect(map['iconSystemName'], 'record.circle');
      expect(map['isActive'], true);

      final restored = IslandStatus.fromMap(map);
      expect(restored.title, status.title);
      expect(restored.subtitle, status.subtitle);
      expect(restored.iconSystemName, status.iconSystemName);
      expect(restored.isActive, status.isActive);
    });

    test('IslandStatus copyWith', () {
      const status = IslandStatus(title: 'Hello');
      final updated = status.copyWith(subtitle: 'World', isActive: false);

      expect(updated.title, 'Hello');
      expect(updated.subtitle, 'World');
      expect(updated.isActive, false);
    });

    test('IslandAnimationConfig toString', () {
      const config = IslandAnimationConfig(
        animationName: 'cat',
        totalFrames: 4,
      );
      expect(config.toString(), contains('cat'));
      expect(config.toString(), contains('4'));
    });

    test('IslandStatus toString', () {
      const status = IslandStatus(title: 'Test');
      expect(status.toString(), contains('Test'));
    });
  });

  group('Dynamic Island DI', () {
    test('setupDynamicIslandDI registers mock service correctly', () {
      final di = GetIt.asNewInstance();
      final mock = MockDynamicIslandService();

      setupDynamicIslandDI(locator: di, customService: mock);

      expect(di.isRegistered<IDynamicIslandService>(), true);
      expect(di<IDynamicIslandService>(), isA<MockDynamicIslandService>());
    });

    test('setupDynamicIslandDI is idempotent', () {
      final di = GetIt.asNewInstance();
      final mock1 = MockDynamicIslandService();
      final mock2 = MockDynamicIslandService();

      setupDynamicIslandDI(locator: di, customService: mock1);
      setupDynamicIslandDI(locator: di, customService: mock2);

      expect(di<IDynamicIslandService>(), same(mock1));
    });
  });

  group('MockDynamicIslandService', () {
    test('mock methods track calls correctly', () async {
      final mock = MockDynamicIslandService();
      mock.supportedResult = true;

      expect(await mock.isSupported(), true);

      await mock.startStatus(const IslandStatus(title: 'Test'));
      expect(mock.startStatusCalled, true);

      await mock.startAnimation(
        const IslandAnimationConfig(animationName: 'cat', totalFrames: 4),
      );
      expect(mock.startAnimationCalled, true);

      await mock.updateStatus(const IslandStatus(title: 'Updated'));
      expect(mock.updateStatusCalled, true);

      await mock.endActivity();
      expect(mock.endActivityCalled, true);
    });
  });
}
