import 'package:flutter_test/flutter_test.dart';
import 'package:code_store/features/campaign_showcase/bloc/campaign_showcase_bloc.dart';
import 'package:code_store/features/campaign_showcase/bloc/campaign_showcase_event.dart';

void main() {
  group('CampaignShowcaseBloc Frame Sequence Engine', () {
    late CampaignShowcaseBloc bloc;

    setUp(() {
      bloc = CampaignShowcaseBloc();
    });

    tearDown(() {
      bloc.close();
    });

    test('initial state has correct frame defaults', () {
      expect(bloc.state.scrollProgress, 0.0);
      expect(bloc.state.activeSection, 0);
      expect(bloc.state.isScrollSyncMode, true);
      expect(bloc.state.currentFrameIndex, 1);
      expect(bloc.state.totalFrames, 320);
      expect(bloc.state.currentFramePath, 'assets/frames/frame_0001.jpg');
    });

    test('CampaignScrollChanged computes progress, section, and frame index', () async {
      bloc.add(const CampaignScrollChanged(
        pixels: 500,
        maxScrollExtent: 1000,
      ));

      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) {
          return state.scrollProgress == 0.5 &&
              state.activeSection == 2 &&
              state.currentFrameIndex == 161 &&
              state.currentFramePath == 'assets/frames/frame_0161.jpg';
        })),
      );
    });

    test('CampaignPlaybackModeToggled toggles isScrollSyncMode', () async {
      bloc.add(const CampaignPlaybackModeToggled());

      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.isScrollSyncMode == false)),
      );
    });

    test('CampaignFramesInitialized sets isFramesInitialized to true', () async {
      bloc.add(const CampaignFramesInitialized());

      await expectLater(
        bloc.stream,
        emits(predicate<dynamic>((state) => state.isFramesInitialized == true)),
      );
    });
  });
}
