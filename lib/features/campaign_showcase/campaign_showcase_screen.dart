import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../core/config/routes.dart';
import 'bloc/campaign_showcase_bloc.dart';
import 'bloc/campaign_showcase_event.dart';
import 'bloc/campaign_showcase_state.dart';

/// Implements a scroll-driven cinematic experience powered by a 320-frame image sequence engine.
/// The frames synchronize dynamically with the user's scroll progress (0% -> 100%) at 60fps with zero decoder latency.
class CampaignShowcaseScreen extends StatelessWidget {
  const CampaignShowcaseScreen({super.key});

  static const String routeName = AppRoutes.campaignShowcase;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => CampaignShowcaseBloc(),
      child: const _CampaignShowcaseView(),
    );
  }
}

class _CampaignShowcaseView extends StatefulWidget {
  const _CampaignShowcaseView();

  @override
  State<_CampaignShowcaseView> createState() => _CampaignShowcaseViewState();
}

class _CampaignShowcaseViewState extends State<_CampaignShowcaseView> {
  final ScrollController _scrollController = ScrollController();

  // Brand Palette: Candy Red, Volt Green, Pure Black
  static const Color candyRed = Color(0xFFFF1744);
  static const Color voltGreen = Color(0xFFCDFF00);
  static const Color pureBlack = Color(0xFF0A0A0A);
  static const Color darkCard = Color(0xFF141414);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _precacheInitialFrames();
      context.read<CampaignShowcaseBloc>().add(const CampaignFramesInitialized());
    });
  }

  /// Pre-caches initial and key milestone frames into image cache for instantaneous switching
  void _precacheInitialFrames() {
    // Precache first 30 frames and key interval landmarks
    for (int i = 1; i <= 30; i++) {
      final padded = i.toString().padLeft(4, '0');
      precacheImage(AssetImage('assets/frames/frame_$padded.jpg'), context);
    }
    for (int i = 31; i <= 320; i += 8) {
      final padded = i.toString().padLeft(4, '0');
      precacheImage(AssetImage('assets/frames/frame_$padded.jpg'), context);
    }
  }

  void _scrollToSection(int index) {
    if (!_scrollController.hasClients) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final targetOffset = (maxScroll / 3) * index;
    _scrollController.animateTo(
      targetOffset,
      duration: const Duration(milliseconds: 600),
      curve: Curves.easeInOutCubic,
    );
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _showJsonPromptBrief(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.82,
          decoration: const BoxDecoration(
            color: darkCard,
            borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Icon(Icons.code_rounded, color: voltGreen, size: 24),
                  const SizedBox(width: 10),
                  const Text(
                    'Campaign JSON Brief',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close, color: Colors.white70),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'The structured prompt fed into AI agents to generate the 4-clip cinematic campaign:',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white12),
                  ),
                  child: const SingleChildScrollView(
                    child: SelectableText(
                      '{\n  "campaign": "Apex Redline GT Launch",\n  "total_clips": 4,\n  "total_frames": 320,\n  "frame_rate": "10 FPS frame sequence",\n  "clips": [\n    {\n      "clip_id": 1,\n      "title": "Vehicle Reveal",\n      "frames": "001 - 080",\n      "prompt": "Cinematic reveal of a candy red race car emerging from darkness."\n    },\n    {\n      "clip_id": 2,\n      "title": "Material Craftsmanship",\n      "frames": "081 - 160",\n      "prompt": "Macro of carbon fiber, brake smoke, wheel spin in slow motion at 120fps."\n    },\n    {\n      "clip_id": 3,\n      "title": "Drift Motion",\n      "frames": "161 - 240",\n      "prompt": "Slow-motion night drift, headlights cutting through dark, tire smoke."\n    },\n    {\n      "clip_id": 4,\n      "title": "Museum Finale",\n      "frames": "241 - 320",\n      "prompt": "Race car on minimalist black pedestal, museum-quality spotlighting."\n    }\n  ]\n}',
                      style: TextStyle(
                        fontFamily: 'monospace',
                        color: voltGreen,
                        fontSize: 12,
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;
    // Long 2.2x scroll runway per section for super granular frame progression
    final sectionHeight = screenSize.height * 2.2;

    return Scaffold(
      backgroundColor: pureBlack,
      body: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          if (notification is ScrollUpdateNotification ||
              notification is ScrollEndNotification) {
            // Stream scroll metrics directly to BLoC
            context.read<CampaignShowcaseBloc>().add(
                  CampaignScrollChanged(
                    pixels: notification.metrics.pixels,
                    maxScrollExtent: notification.metrics.maxScrollExtent,
                  ),
                );
          }
          return false;
        },
        child: Stack(
          children: [
            // Background: Ultra-Smooth Frame Sequence Engine
            Positioned.fill(
              child: Opacity(
                opacity: 0.90,
                child: BlocSelector<CampaignShowcaseBloc, CampaignShowcaseState, String>(
                  selector: (state) => state.currentFramePath,
                  builder: (context, framePath) {
                    return Image.asset(
                      framePath,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: double.infinity,
                      gaplessPlayback: true,
                      filterQuality: FilterQuality.low,
                      errorBuilder: (_, _, _) => _buildLoadingBackdrop(),
                    );
                  },
                ),
              ),
            ),

            // Background: Dark Ambient Overlay
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.black.withValues(alpha: 0.70),
                      Colors.black.withValues(alpha: 0.40),
                      Colors.black.withValues(alpha: 0.85),
                    ],
                  ),
                ),
              ),
            ),

            // Scrollable Content Layer (Expanded long-runway sections)
            SingleChildScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              child: Column(
                children: [
                  _buildSectionContainer(height: sectionHeight, child: _buildHeroContent(context)),
                  _buildSectionContainer(height: sectionHeight, child: _buildCraftsmanshipContent()),
                  _buildSectionContainer(height: sectionHeight, child: _buildPerformanceContent()),
                  _buildSectionContainer(height: sectionHeight, child: _buildPreOrderContent()),
                ],
              ),
            ),

            // Top Floating Navigation Bar
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 16,
              right: 16,
              child: _buildTopNav(context),
            ),

            // Bottom Floating HUD
            Positioned(
              bottom: MediaQuery.of(context).padding.bottom + 12,
              left: 16,
              right: 16,
              child: _buildScrubHud(context),
            ),

            // Right-side Section Quick Switcher
            Positioned(
              right: 12,
              top: 0,
              bottom: 0,
              child: Center(child: _buildRightSectionPills()),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopNav(BuildContext context) {
    return BlocBuilder<CampaignShowcaseBloc, CampaignShowcaseState>(
      buildWhen: (prev, current) =>
          prev.isScrollSyncMode != current.isScrollSyncMode || prev.isMuted != current.isMuted,
      builder: (context, state) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton.filledTonal(
              onPressed: () => Navigator.of(context).pop(),
              style: IconButton.styleFrom(
                backgroundColor: Colors.black.withValues(alpha: 0.65),
                foregroundColor: Colors.white,
              ),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: voltGreen.withValues(alpha: 0.3)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: state.isScrollSyncMode ? voltGreen : candyRed,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isScrollSyncMode ? 'SCROLL // FRAME SYNC' : 'AUTO PLAY',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1.1,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton.filledTonal(
                  onPressed: () =>
                      context.read<CampaignShowcaseBloc>().add(const CampaignMuteToggled()),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                    foregroundColor: Colors.white,
                  ),
                  icon: Icon(
                    state.isMuted ? Icons.volume_off_rounded : Icons.volume_up_rounded,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 6),
                IconButton.filledTonal(
                  onPressed: () => _showJsonPromptBrief(context),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.black.withValues(alpha: 0.65),
                    foregroundColor: voltGreen,
                  ),
                  icon: const Icon(Icons.terminal_rounded, size: 20),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  Widget _buildScrubHud(BuildContext context) {
    const sectionNames = ['01 REVEAL', '02 CRAFT', '03 MOTION', '04 FINALE'];

    return BlocBuilder<CampaignShowcaseBloc, CampaignShowcaseState>(
      buildWhen: (prev, current) =>
          prev.scrollProgress != current.scrollProgress ||
          prev.activeSection != current.activeSection ||
          prev.currentFrameIndex != current.currentFrameIndex ||
          prev.isScrollSyncMode != current.isScrollSyncMode,
      builder: (context, state) {
        final percentStr = (state.scrollProgress * 100).toStringAsFixed(0);

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.85),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: voltGreen.withValues(alpha: 0.35)),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.6),
                blurRadius: 18,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(
                    state.isScrollSyncMode ? Icons.swap_vert_rounded : Icons.play_arrow_rounded,
                    color: voltGreen,
                    size: 18,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    state.isScrollSyncMode
                        ? 'Frame: ${state.currentFrameIndex}/${state.totalFrames} ($percentStr%)'
                        : 'Auto Playing: Frame ${state.currentFrameIndex}/${state.totalFrames}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: voltGreen.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: Text(
                      sectionNames[state.activeSection],
                      style: const TextStyle(
                        color: voltGreen,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => context
                        .read<CampaignShowcaseBloc>()
                        .add(const CampaignPlaybackModeToggled()),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.white12,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        state.isScrollSyncMode ? 'AUTO PLAY' : 'SCROLL SYNC',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: state.scrollProgress,
                  minHeight: 4,
                  backgroundColor: Colors.white12,
                  valueColor: const AlwaysStoppedAnimation<Color>(voltGreen),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRightSectionPills() {
    return BlocSelector<CampaignShowcaseBloc, CampaignShowcaseState, int>(
      selector: (state) => state.activeSection,
      builder: (context, activeSection) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(4, (index) {
            final isCurrent = activeSection == index;
            return GestureDetector(
              onTap: () => _scrollToSection(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 260),
                margin: const EdgeInsets.symmetric(vertical: 6),
                width: 6,
                height: isCurrent ? 28 : 8,
                decoration: BoxDecoration(
                  color: isCurrent ? voltGreen : Colors.white24,
                  borderRadius: BorderRadius.circular(3),
                ),
              ),
            );
          }),
        );
      },
    );
  }

  Widget _buildSectionContainer({required double height, required Widget child}) {
    return SizedBox(
      height: height,
      width: double.infinity,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Align(alignment: Alignment.centerLeft, child: child),
      ),
    );
  }

  Widget _buildLoadingBackdrop() {
    return Container(
      color: pureBlack,
      alignment: Alignment.center,
      child: const Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(voltGreen),
            ),
          ),
          SizedBox(height: 14),
          Text(
            'LOADING 4K CAMPAIGN...',
            style: TextStyle(
              color: Colors.white38,
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  // ── ACT 1: REVEAL & AERODYNAMICS ──────────────────────────────────────────

  Widget _buildHeroContent(BuildContext context) {
    return BlocBuilder<CampaignShowcaseBloc, CampaignShowcaseState>(
      buildWhen: (prev, current) =>
          prev.isScrollSyncMode != current.isScrollSyncMode ||
          prev.isFramesInitialized != current.isFramesInitialized,
      builder: (context, state) {
        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: candyRed.withValues(alpha: 0.15),
                border: Border.all(color: candyRed.withValues(alpha: 0.6)),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                '01 // VEHICLE REVEAL',
                style: TextStyle(
                  color: candyRed,
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.5,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'APEX\nREDLINE GT',
              style: TextStyle(
                color: Colors.white,
                fontSize: 48,
                fontWeight: FontWeight.w900,
                height: 1.02,
                letterSpacing: -0.5,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              state.isScrollSyncMode
                  ? '"Scroll down to scrub the 320-frame sequence in ultra-smooth 60fps."'
                  : '"Playing 24fps auto-play animation. Tap button to switch to scroll scrub."',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.75),
                fontSize: 16,
                fontStyle: FontStyle.italic,
              ),
            ),
            const SizedBox(height: 28),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: () => context
                      .read<CampaignShowcaseBloc>()
                      .add(const CampaignPlaybackModeToggled()),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: voltGreen,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: Icon(
                    state.isScrollSyncMode ? Icons.play_arrow_rounded : Icons.swap_vert_rounded,
                    size: 20,
                  ),
                  label: Text(
                    state.isScrollSyncMode ? 'AUTO PLAY (24 FPS)' : 'SCROLL FRAME SYNC',
                    style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white12,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: Colors.white24),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        state.isScrollSyncMode ? Icons.swap_vert_rounded : Icons.mouse_rounded,
                        color: voltGreen,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        state.isScrollSyncMode ? 'SCROLL TO SCRUB' : 'SCROLL TO READ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 36),
            _buildAeroHighlightCard(),
          ],
        );
      },
    );
  }

  Widget _buildAeroHighlightCard() {
    return Container(
      constraints: const BoxConstraints(maxWidth: 420),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCard.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.air_rounded, color: voltGreen, size: 20),
              SizedBox(width: 10),
              Text(
                'AERODYNAMIC PROFILE',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                  letterSpacing: 1.0,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Engineered in virtual wind tunnels with active front splitters and rear venturi tunnels generating over 450kg of downforce at speed.',
            style: TextStyle(color: Colors.white70, fontSize: 12, height: 1.4),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMiniMetric('0.28 Cd', 'DRAG COEFFICIENT'),
              _buildMiniMetric('1,340 KG', 'CURB WEIGHT'),
              _buildMiniMetric('48:52', 'WEIGHT BIAS'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniMetric(String value, String label) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(color: voltGreen, fontWeight: FontWeight.w900, fontSize: 15),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // ── ACT 2: CRAFTSMANSHIP & MATERIALS ──────────────────────────────────────

  Widget _buildCraftsmanshipContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '02 // CRAFTSMANSHIP',
          style: TextStyle(
            color: voltGreen,
            fontSize: 12,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.5,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'ENGINEERED\nMATERIALS',
          style: TextStyle(
            color: Colors.white,
            fontSize: 38,
            fontWeight: FontWeight.w900,
            height: 1.05,
          ),
        ),
        const SizedBox(height: 12),
        const Text(
          'Every contour serves aerodynamic purpose with zero weight penalty.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        _buildMaterialCard(
          Icons.texture_rounded,
          'Carbon Matrix Monocoque',
          'Single-piece autoclave-cured carbon shell delivering 40,000 Nm/deg torsional stiffness.',
        ),
        const SizedBox(height: 12),
        _buildMaterialCard(
          Icons.speed_rounded,
          'Carbon-Silicon Carbide Brakes',
          '410mm front and 390mm rear composite discs with 6-piston monobloc calipers.',
        ),
        const SizedBox(height: 12),
        _buildMaterialCard(
          Icons.album_rounded,
          'Forged Magnesium Wheels',
          'Ultra-light 20" center-lock wheels reducing rotational unsprung mass by 28%.',
        ),
      ],
    );
  }

  Widget _buildMaterialCard(IconData icon, String title, String desc) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: darkCard.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: voltGreen.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: voltGreen, size: 22),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.65),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── ACT 3: PERFORMANCE & DRIFT DYNAMICS ───────────────────────────────────

  Widget _buildPerformanceContent() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          '03 // IN MOTION',
          style: TextStyle(
              color: voltGreen, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
        ),
        const SizedBox(height: 8),
        const Text(
          'PEAK\nPERFORMANCE',
          style: TextStyle(
              color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, height: 1.05),
        ),
        const SizedBox(height: 12),
        const Text(
          'Pure analog drift control meets hyper-responsive twin-turbo V8 torque.',
          style: TextStyle(color: Colors.white70, fontSize: 14),
        ),
        const SizedBox(height: 24),
        Container(
          constraints: const BoxConstraints(maxWidth: 460),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: darkCard.withValues(alpha: 0.88),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: voltGreen.withValues(alpha: 0.3)),
          ),
          child: Column(
            children: [
              _buildStatRow('720HP', 'TWIN-TURBO 4.0L V8 POWER'),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow('2.8s', '0–100 KM/H CATAPULT ACCELERATION'),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow('345+', 'TOP TRACK SPEED KM/H'),
              const Divider(color: Colors.white12, height: 24),
              _buildStatRow('1.45G', 'PEAK LATERAL CORNERING GRIP'),
            ],
          ),
        ),
        const SizedBox(height: 14),
        _buildDynamicModeBadge('ELECTRONIC TORQUE VECTORING // APEX DRIFT ANGLE ASSIST'),
      ],
    );
  }

  Widget _buildDynamicModeBadge(String title) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: voltGreen.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: voltGreen.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: voltGreen),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title,
              style: const TextStyle(
                color: voltGreen,
                fontSize: 10,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatRow(String stat, String label) {
    return Row(
      children: [
        Text(stat,
            style: const TextStyle(
                color: voltGreen, fontSize: 24, fontWeight: FontWeight.w900)),
        const SizedBox(width: 14),
        Expanded(
          child: Text(label,
              style: const TextStyle(
                  color: Colors.white70, fontSize: 11, fontWeight: FontWeight.w700)),
        ),
      ],
    );
  }

  // ── ACT 4: COLLECTION FINALE & PRE-ORDER ──────────────────────────────────

  Widget _buildPreOrderContent() {
    return BlocSelector<CampaignShowcaseBloc, CampaignShowcaseState, Duration>(
      selector: (state) => state.remainingCountdown,
      builder: (context, remainingTime) {
        final days = remainingTime.inDays;
        final hours = remainingTime.inHours % 24;
        final minutes = remainingTime.inMinutes % 60;
        final seconds = remainingTime.inSeconds % 60;

        return Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '04 // FINALE',
              style: TextStyle(
                  color: voltGreen, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 1.5),
            ),
            const SizedBox(height: 8),
            const Text(
              'PRE-ORDER\nNOW AVAILABLE',
              style: TextStyle(
                  color: Colors.white, fontSize: 38, fontWeight: FontWeight.w900, height: 1.05),
            ),
            const SizedBox(height: 8),
            const Text(
              'Strictly limited to 500 numbered chassis worldwide.',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildCountdownBox('$days', 'DAYS'),
                const SizedBox(width: 8),
                _buildCountdownBox(hours.toString().padLeft(2, '0'), 'HOURS'),
                const SizedBox(width: 8),
                _buildCountdownBox(minutes.toString().padLeft(2, '0'), 'MINS'),
                const SizedBox(width: 8),
                _buildCountdownBox(seconds.toString().padLeft(2, '0'), 'SECS'),
              ],
            ),
            const SizedBox(height: 24),
            _buildTierCard('APEX LAUNCH EDITION', '\$295,000', 'Full Exposed Carbon, Bespoke Livery, VIP Delivery'),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('VIP reservation allocation submitted! Concierge will contact you.'),
                    backgroundColor: voltGreen,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: voltGreen,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                'RESERVE ALLOCATION NOW',
                style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.0, fontSize: 14),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildTierCard(String name, String price, String details) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 460),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: darkCard.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  details,
                  style: const TextStyle(color: Colors.white60, fontSize: 10),
                ),
              ],
            ),
          ),
          Text(
            price,
            style: const TextStyle(
              color: voltGreen,
              fontWeight: FontWeight.w900,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCountdownBox(String value, String label) {
    return Container(
      width: 62,
      padding: const EdgeInsets.symmetric(vertical: 10),
      decoration: BoxDecoration(
        color: darkCard.withValues(alpha: 0.88),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white12),
      ),
      child: Column(
        children: [
          Text(value,
              style: const TextStyle(
                  color: voltGreen, fontSize: 18, fontWeight: FontWeight.w900)),
          const SizedBox(height: 2),
          Text(label,
              style: const TextStyle(
                  color: Colors.white38, fontSize: 9, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
