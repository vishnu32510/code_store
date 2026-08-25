import 'dart:async';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'campaign_showcase_event.dart';
import 'campaign_showcase_state.dart';

class CampaignShowcaseBloc extends Bloc<CampaignShowcaseEvent, CampaignShowcaseState> {
  Timer? _countdownTimer;
  Timer? _autoPlayTimer;

  CampaignShowcaseBloc() : super(const CampaignShowcaseState()) {
    on<CampaignScrollChanged>(_onScrollChanged);
    on<CampaignPlaybackModeToggled>(_onPlaybackModeToggled);
    on<CampaignMuteToggled>(_onMuteToggled);
    on<CampaignFramesInitialized>(_onFramesInitialized);
    on<CampaignAutoPlayFrameTicked>(_onAutoPlayFrameTicked);
    on<CampaignCountdownTicked>(_onCountdownTicked);

    _startCountdown();
  }

  void _startCountdown() {
    _countdownTimer?.cancel();
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      add(const CampaignCountdownTicked());
    });
  }

  void _startAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    // 24 frames per second ticker for smooth cinematic autoplay
    _autoPlayTimer = Timer.periodic(const Duration(milliseconds: 41), (_) {
      add(const CampaignAutoPlayFrameTicked());
    });
  }

  void _stopAutoPlayTimer() {
    _autoPlayTimer?.cancel();
    _autoPlayTimer = null;
  }

  void _onScrollChanged(
    CampaignScrollChanged event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    if (event.maxScrollExtent <= 0) return;

    final progress = (event.pixels / event.maxScrollExtent).clamp(0.0, 1.0);
    final section = (progress * 4).floor().clamp(0, 3);
    final frameIndex = ((progress * (state.totalFrames - 1)) + 1).round().clamp(1, state.totalFrames);

    emit(state.copyWith(
      scrollProgress: progress,
      activeSection: section,
      currentFrameIndex: state.isScrollSyncMode ? frameIndex : state.currentFrameIndex,
    ));
  }

  void _onPlaybackModeToggled(
    CampaignPlaybackModeToggled event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    final nextScrollSync = !state.isScrollSyncMode;
    if (!nextScrollSync) {
      _startAutoPlayTimer();
    } else {
      _stopAutoPlayTimer();
      final frameIndex = ((state.scrollProgress * (state.totalFrames - 1)) + 1)
          .round()
          .clamp(1, state.totalFrames);
      emit(state.copyWith(
        isScrollSyncMode: nextScrollSync,
        currentFrameIndex: frameIndex,
      ));
      return;
    }

    emit(state.copyWith(isScrollSyncMode: nextScrollSync));
  }

  void _onMuteToggled(
    CampaignMuteToggled event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    emit(state.copyWith(isMuted: !state.isMuted));
  }

  void _onFramesInitialized(
    CampaignFramesInitialized event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    emit(state.copyWith(isFramesInitialized: true));
  }

  void _onAutoPlayFrameTicked(
    CampaignAutoPlayFrameTicked event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    if (!state.isScrollSyncMode) {
      final nextIndex = (state.currentFrameIndex % state.totalFrames) + 1;
      emit(state.copyWith(currentFrameIndex: nextIndex));
    }
  }

  void _onCountdownTicked(
    CampaignCountdownTicked event,
    Emitter<CampaignShowcaseState> emit,
  ) {
    if (state.remainingCountdown.inSeconds > 0) {
      emit(state.copyWith(
        remainingCountdown: state.remainingCountdown - const Duration(seconds: 1),
      ));
    }
  }

  @override
  Future<void> close() {
    _countdownTimer?.cancel();
    _stopAutoPlayTimer();
    return super.close();
  }
}
