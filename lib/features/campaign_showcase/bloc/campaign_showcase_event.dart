import 'package:equatable/equatable.dart';

abstract class CampaignShowcaseEvent extends Equatable {
  const CampaignShowcaseEvent();

  @override
  List<Object?> get props => [];
}

class CampaignScrollChanged extends CampaignShowcaseEvent {
  final double pixels;
  final double maxScrollExtent;

  const CampaignScrollChanged({
    required this.pixels,
    required this.maxScrollExtent,
  });

  @override
  List<Object?> get props => [pixels, maxScrollExtent];
}

class CampaignPlaybackModeToggled extends CampaignShowcaseEvent {
  const CampaignPlaybackModeToggled();
}

class CampaignMuteToggled extends CampaignShowcaseEvent {
  const CampaignMuteToggled();
}

class CampaignFramesInitialized extends CampaignShowcaseEvent {
  const CampaignFramesInitialized();
}

class CampaignAutoPlayFrameTicked extends CampaignShowcaseEvent {
  const CampaignAutoPlayFrameTicked();
}

class CampaignCountdownTicked extends CampaignShowcaseEvent {
  const CampaignCountdownTicked();
}
