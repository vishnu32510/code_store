import 'package:equatable/equatable.dart';

class CampaignShowcaseState extends Equatable {
  final double scrollProgress;
  final int activeSection;
  final bool isScrollSyncMode;
  final bool isMuted;
  final bool isFramesInitialized;
  final int currentFrameIndex;
  final int totalFrames;
  final Duration remainingCountdown;

  const CampaignShowcaseState({
    this.scrollProgress = 0.0,
    this.activeSection = 0,
    this.isScrollSyncMode = true,
    this.isMuted = true,
    this.isFramesInitialized = false,
    this.currentFrameIndex = 1,
    this.totalFrames = 320,
    this.remainingCountdown = const Duration(days: 4, hours: 18, minutes: 32, seconds: 45),
  });

  String get currentFramePath {
    final paddedIndex = currentFrameIndex.toString().padLeft(4, '0');
    return 'assets/frames/frame_$paddedIndex.jpg';
  }

  CampaignShowcaseState copyWith({
    double? scrollProgress,
    int? activeSection,
    bool? isScrollSyncMode,
    bool? isMuted,
    bool? isFramesInitialized,
    int? currentFrameIndex,
    int? totalFrames,
    Duration? remainingCountdown,
  }) {
    return CampaignShowcaseState(
      scrollProgress: scrollProgress ?? this.scrollProgress,
      activeSection: activeSection ?? this.activeSection,
      isScrollSyncMode: isScrollSyncMode ?? this.isScrollSyncMode,
      isMuted: isMuted ?? this.isMuted,
      isFramesInitialized: isFramesInitialized ?? this.isFramesInitialized,
      currentFrameIndex: currentFrameIndex ?? this.currentFrameIndex,
      totalFrames: totalFrames ?? this.totalFrames,
      remainingCountdown: remainingCountdown ?? this.remainingCountdown,
    );
  }

  @override
  List<Object?> get props => [
        scrollProgress,
        activeSection,
        isScrollSyncMode,
        isMuted,
        isFramesInitialized,
        currentFrameIndex,
        totalFrames,
        remainingCountdown,
      ];
}
