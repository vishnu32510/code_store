import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Looping Animation View (TimelineView trick)

/// Renders an infinitely looping sprite animation by cycling through
/// pre-sliced PNG frames stored in the App Group shared container.
///
/// Uses `TimelineView(.periodic)` to bypass iOS background thread
/// restrictions — the system redraws the view at the specified interval
/// without waking up the core app processor.
struct LoopingAnimationView: View {
    let animationName: String
    let totalFrames: Int
    let framesPerSecond: Int

    private let appGroupId = "group.com.nungu.codestore"

    var body: some View {
        let interval = 1.0 / Double(max(framesPerSecond, 1))

        TimelineView(.periodic(from: .now, by: interval)) { context in
            let frameIndex = getFrameIndex(for: context.date)

            if let containerURL = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: appGroupId
            ) {
                let standardPath = containerURL.appendingPathComponent("\(animationName)_\(frameIndex).png").path
                let fallbackPath = containerURL.appendingPathComponent("IMG_\(animationName)_\(frameIndex).png").path
                let imagePath = FileManager.default.fileExists(atPath: standardPath) ? standardPath : fallbackPath

                if let uiImage = UIImage(contentsOfFile: imagePath) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 28, height: 28)
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            } else {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.system(size: 14))
                    .foregroundColor(.red)
            }
        }
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
                        .foregroundColor(.blue)
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
                        .frame(width: 48, height: 48)
                    } else if let iconName = context.state.iconSystemName {
                        Image(systemName: iconName)
                            .font(.system(size: 28))
                            .foregroundColor(.blue)
                    }
                }
                DynamicIslandExpandedRegion(.center) {
                    VStack(spacing: 2) {
                        Text(context.state.title ?? context.attributes.name)
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)

                        if let subtitle = context.state.subtitle, !subtitle.isEmpty {
                            Text(subtitle)
                                .font(.system(size: 11))
                                .foregroundColor(.gray)
                        }
                    }
                }
                DynamicIslandExpandedRegion(.trailing) {
                    EmptyView()
                }
                DynamicIslandExpandedRegion(.bottom) {
                    EmptyView()
                }
            } compactLeading: {
                // Compact Leading — animation or icon
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
                        .foregroundColor(.blue)
                } else {
                    Image(systemName: "pawprint.fill")
                        .font(.system(size: 14))
                        .foregroundColor(.orange)
                }
            } compactTrailing: {
                // Compact Trailing — animation or empty
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
                } else {
                    EmptyView()
                }
            } minimal: {
                // Minimal — smallest representation
                if context.state.isAnimating,
                   let animName = context.state.animationName,
                   !animName.isEmpty {
                    LoopingAnimationView(
                        animationName: animName,
                        totalFrames: context.state.totalFrames,
                        framesPerSecond: context.state.framesPerSecond
                    )
                } else {
                    Image(systemName: context.state.iconSystemName ?? "pawprint.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.orange)
                }
            }
        }
    }
}
