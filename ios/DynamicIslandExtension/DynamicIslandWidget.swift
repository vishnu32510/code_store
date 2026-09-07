import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Looping Animation View (TimelineView trick)

/// Renders an infinitely looping sprite animation by cycling through
/// pre-sliced PNG frames stored in the App Group shared container or UserDefaults.
struct LoopingAnimationView: View {
    let animationName: String
    let totalFrames: Int
    let framesPerSecond: Int

    private let appGroupId = "group.com.nungu.codestore"

    var body: some View {
        let interval = 1.0 / Double(max(framesPerSecond, 1))

        TimelineView(.periodic(from: .now, by: interval)) { context in
            let frameIndex = getFrameIndex(for: context.date)

            if let uiImage = loadFrameImage(named: "\(animationName)_\(frameIndex)") {
                Image(uiImage: uiImage)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 28, height: 28)
            } else {
                Image(systemName: "cat.fill")
                    .font(.system(size: 16))
                    .foregroundColor(.orange)
            }
        }
    }

    private func loadFrameImage(named name: String) -> UIImage? {
        // 1. Try App Group container file
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
            let standardPath = containerURL.appendingPathComponent("\(name).png").path
            let fallbackPath = containerURL.appendingPathComponent("IMG_\(name).png").path
            let path = FileManager.default.fileExists(atPath: standardPath) ? standardPath : fallbackPath
            if let image = UIImage(contentsOfFile: path) {
                return image
            }
        }

        // 2. Try shared UserDefaults (suite) Data
        if let defaults = UserDefaults(suiteName: appGroupId),
           let data = defaults.data(forKey: name),
           let image = UIImage(data: data) {
            return image
        }

        // 3. Try standard documents directory (Simulator fallback)
        let docURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first
        if let docPath = docURL?.appendingPathComponent("\(name).png").path,
           let image = UIImage(contentsOfFile: docPath) {
            return image
        }

        return nil
    }

    /// Deterministically calculates the current frame index based on
    /// absolute time, ensuring the animation recovers correctly if the
    /// Dynamic Island is dismissed and reopened.
    private func getFrameIndex(for date: Date) -> Int {
        guard totalFrames > 0 else { return 0 }
        let frameDuration = 1.0 / Double(max(framesPerSecond, 1))
        let totalLoopDuration = Double(totalFrames) * frameDuration
        let currentLoopTime = date.timeIntervalSince1970
            .truncatingRemainder(dividingBy: totalLoopDuration)
        return Int(currentLoopTime / frameDuration) % totalFrames
    }
}

// MARK: - Dynamic Island Widget

struct DynamicIslandWidget: Widget {
    let kind: String = "DynamicIslandWidget"

    var body: some WidgetConfiguration {
        ActivityConfiguration(for: IslandAnimationAttributes.self) { context in
            // Lock Screen / Banner View
            HStack(spacing: 12) {
                if context.state.isAnimating,
                   let animName = context.state.animationName,
                   !animName.isEmpty {
                    LoopingAnimationView(
                        animationName: animName,
                        totalFrames: context.state.totalFrames,
                        framesPerSecond: context.state.framesPerSecond
                    )
                    .frame(width: 40, height: 40)
                } else if let iconName = context.state.iconSystemName {
                    Image(systemName: iconName)
                        .font(.system(size: 24))
                        .foregroundColor(.cyan)
                } else {
                    Image(systemName: "star.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.yellow)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text(context.state.title ?? context.attributes.name)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)

                    if let subtitle = context.state.subtitle, !subtitle.isEmpty {
                        Text(subtitle)
                            .font(.system(size: 12))
                            .foregroundColor(.gray)
                    }
                }

                Spacer()

                if context.state.isAnimating {
                    Text("\(context.state.framesPerSecond) FPS")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(.orange)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.orange.opacity(0.15))
                        .cornerRadius(8)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded Regions
                DynamicIslandExpandedRegion(.leading) {
                    if context.state.isAnimating,
                       let animName = context.state.animationName,
                       !animName.isEmpty {
                        LoopingAnimationView(
                            animationName: animName,
                            totalFrames: context.state.totalFrames,
                            framesPerSecond: context.state.framesPerSecond
                        )
                        .frame(width: 44, height: 44)
                    } else if let iconName = context.state.iconSystemName {
                        Image(systemName: iconName)
                            .font(.system(size: 26))
                            .foregroundColor(.cyan)
                    } else {
                        Image(systemName: "star.fill")
                            .font(.system(size: 26))
                            .foregroundColor(.yellow)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(context.state.title ?? context.attributes.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)

                        if let subtitle = context.state.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.system(size: 11))
                                .foregroundColor(.secondary)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.isAnimating {
                        Text("\(context.state.framesPerSecond) FPS")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.orange)
                    } else {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.green)
                    }
                }
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Text(context.state.isAnimating ? "Sprite Animation" : "Live Activity")
                            .font(.caption2)
                            .foregroundColor(.secondary)
                        Spacer()
                        Text("CodeStore")
                            .font(.caption2.bold())
                            .foregroundColor(.cyan)
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                // Compact Leading
                if context.state.isAnimating,
                   let animName = context.state.animationName,
                   !animName.isEmpty,
                   (context.attributes.placement == "compactLeading" ||
                    context.attributes.placement == "both") {
                    LoopingAnimationView(
                        animationName: animName,
                        totalFrames: context.state.totalFrames,
                        framesPerSecond: context.state.framesPerSecond
                    )
                } else if let iconName = context.state.iconSystemName {
                    Image(systemName: iconName)
                        .font(.system(size: 14))
                        .foregroundColor(.cyan)
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            } compactTrailing: {
                // Compact Trailing
                if context.state.isAnimating,
                   let animName = context.state.animationName,
                   !animName.isEmpty,
                   (context.attributes.placement == "compactTrailing" ||
                    context.attributes.placement == "both") {
                    LoopingAnimationView(
                        animationName: animName,
                        totalFrames: context.state.totalFrames,
                        framesPerSecond: context.state.framesPerSecond
                    )
                } else if let title = context.state.title, !title.isEmpty {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold))
                        .foregroundColor(.white)
                } else {
                    Text("Live")
                        .font(.system(size: 11, weight: .bold))
                        .foregroundColor(.green)
                }
            } minimal: {
                // Minimal
                if context.state.isAnimating,
                   let animName = context.state.animationName,
                   !animName.isEmpty {
                    LoopingAnimationView(
                        animationName: animName,
                        totalFrames: context.state.totalFrames,
                        framesPerSecond: context.state.framesPerSecond
                    )
                } else if let iconName = context.state.iconSystemName {
                    Image(systemName: iconName)
                        .font(.system(size: 12))
                        .foregroundColor(.cyan)
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
