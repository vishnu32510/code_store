import ActivityKit

/// Defines the data model for Dynamic Island Live Activities.
///
/// - Static data: `name` and `placement` (set once when the activity starts).
/// - Dynamic data: `ContentState` (updated while the activity is running).
struct IslandAnimationAttributes: ActivityAttributes {
    /// The animation set name (e.g. "retro_cat_idle").
    let name: String

    /// Where to place the animation: "compactLeading", "compactTrailing", or "both".
    let placement: String

    /// Dynamic content state that can be updated while the activity is live.
    struct ContentState: Codable, Hashable {
        /// Total frames in the animation loop.
        let totalFrames: Int

        /// Playback speed in frames per second.
        let framesPerSecond: Int

        /// Title text for simple status mode.
        let title: String?

        /// Subtitle text for expanded/lock screen views.
        let subtitle: String?

        /// SF Symbol name for the status icon.
        let iconSystemName: String?

        /// Whether the status represents an active state.
        let isActive: Bool

        /// Whether this activity should render a sprite animation.
        let isAnimating: Bool

        /// Animation name for locating frame files.
        let animationName: String?
    }
}
