import WidgetKit
import SwiftUI

/// Entry point for the Dynamic Island Widget Extension.
///
/// This bundle registers the Dynamic Island Live Activity widget.
@main
struct DynamicIslandExtensionBundle: WidgetBundle {
    var body: some Widget {
        DynamicIslandWidget()
    }
}
