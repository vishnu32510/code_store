import WidgetKit
import SwiftUI

/// Entry point for the Dynamic Island Widget Extension.
///
/// Registers the DynamicIslandWidget which renders power-efficient
/// sprite loops and status indicators using ActivityKit.
@main
struct DynamicIslandExtensionBundle: WidgetBundle {
    var body: some Widget {
        DynamicIslandWidget()
    }
}
