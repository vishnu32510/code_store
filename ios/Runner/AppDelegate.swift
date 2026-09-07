import Flutter
import UIKit
#if canImport(ActivityKit)
import ActivityKit
#endif

#if canImport(ActivityKit)
@available(iOS 16.1, *)
struct IslandAnimationAttributes: ActivityAttributes {
    let name: String
    let placement: String

    struct ContentState: Codable, Hashable {
        let totalFrames: Int
        let framesPerSecond: Int
        let title: String?
        let subtitle: String?
        let iconSystemName: String?
        let isActive: Bool
        let isAnimating: Bool
        let animationName: String?
    }
}
#endif

@main
@objc class AppDelegate: FlutterAppDelegate {
  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    if #available(iOS 10.0, *) {
      UNUserNotificationCenter.current().delegate = self as? UNUserNotificationCenterDelegate
    }
    GeneratedPluginRegistrant.register(with: self)

    let result = super.application(application, didFinishLaunchingWithOptions: launchOptions)
    setupDynamicIslandChannel()
    return result
  }

  private func setupDynamicIslandChannel() {
    let messenger: FlutterBinaryMessenger?
    if let registrar = self.registrar(forPlugin: "DynamicIslandPlugin") {
      messenger = registrar.messenger()
    } else if let controller = window?.rootViewController as? FlutterViewController {
      messenger = controller.binaryMessenger
    } else {
      messenger = nil
    }

    guard let binaryMessenger = messenger else {
      NSLog("DynamicIsland: Failed to obtain FlutterBinaryMessenger")
      return
    }

    let channel = FlutterMethodChannel(
      name: "com.nungu.codestore/dynamic_island",
      binaryMessenger: binaryMessenger
    )

    channel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "isSupported":
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
          result(ActivityAuthorizationInfo().areActivitiesEnabled)
        } else {
          result(false)
        }
        #else
        result(false)
        #endif

      case "startActivity":
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
          guard let args = call.arguments as? [String: Any] else {
            result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
            return
          }
          let animName = args["animationName"] as? String ?? "activity"
          let placement = args["placement"] as? String ?? "compactLeading"
          let attributes = IslandAnimationAttributes(name: animName, placement: placement)

          let contentState = IslandAnimationAttributes.ContentState(
            totalFrames: args["totalFrames"] as? Int ?? 0,
            framesPerSecond: args["framesPerSecond"] as? Int ?? 10,
            title: args["title"] as? String,
            subtitle: args["subtitle"] as? String,
            iconSystemName: args["iconSystemName"] as? String,
            isActive: args["isActive"] as? Bool ?? true,
            isAnimating: args["isAnimating"] as? Bool ?? false,
            animationName: animName
          )

          do {
            if #available(iOS 16.2, *) {
              let activity = try Activity.request(
                attributes: attributes,
                content: .init(state: contentState, staleDate: nil)
              )
              result(activity.id)
            } else {
              let activity = try Activity.request(
                attributes: attributes,
                contentState: contentState
              )
              result(activity.id)
            }
          } catch {
            result(FlutterError(code: "ACTIVITY_ERROR", message: error.localizedDescription, details: nil))
          }
        } else {
          result(FlutterError(code: "UNSUPPORTED", message: "iOS 16.1+ required", details: nil))
        }
        #else
        result(FlutterError(code: "UNSUPPORTED", message: "ActivityKit not supported", details: nil))
        #endif

      case "updateActivity":
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
          guard let args = call.arguments as? [String: Any],
                let activityId = args["activityId"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Activity ID missing", details: nil))
            return
          }
          Task {
            for activity in Activity<IslandAnimationAttributes>.activities where activity.id == activityId {
              let animName = args["animationName"] as? String ?? activity.attributes.name
              let contentState = IslandAnimationAttributes.ContentState(
                totalFrames: args["totalFrames"] as? Int ?? 0,
                framesPerSecond: args["framesPerSecond"] as? Int ?? 10,
                title: args["title"] as? String,
                subtitle: args["subtitle"] as? String,
                iconSystemName: args["iconSystemName"] as? String,
                isActive: args["isActive"] as? Bool ?? true,
                isAnimating: args["isAnimating"] as? Bool ?? false,
                animationName: animName
              )
              if #available(iOS 16.2, *) {
                await activity.update(.init(state: contentState, staleDate: nil))
              } else {
                await activity.update(using: contentState)
              }
            }
            result(true)
          }
        } else {
          result(false)
        }
        #else
        result(false)
        #endif

      case "endActivity":
        #if canImport(ActivityKit)
        if #available(iOS 16.1, *) {
          Task {
            for activity in Activity<IslandAnimationAttributes>.activities {
              if #available(iOS 16.2, *) {
                await activity.end(nil, dismissalPolicy: .immediate)
              } else {
                await activity.end(dismissalPolicy: .immediate)
              }
            }
            result(true)
          }
        } else {
          result(false)
        }
        #else
        result(false)
        #endif

      case "saveFrame":
        guard let args = call.arguments as? [String: Any],
              let fileName = args["fileName"] as? String,
              let typedData = args["bytes"] as? FlutterStandardTypedData else {
          result(FlutterError(code: "INVALID_ARGS", message: "Arguments missing", details: nil))
          return
        }
        let appGroupId = args["appGroupId"] as? String ?? "group.com.nungu.codestore"
        if let containerURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupId) {
          let fileURL = containerURL.appendingPathComponent(fileName)
          do {
            try typedData.data.write(to: fileURL)
            result(true)
          } catch {
            result(FlutterError(code: "WRITE_ERROR", message: error.localizedDescription, details: nil))
          }
        } else {
          result(FlutterError(code: "CONTAINER_ERROR", message: "App group container not found", details: nil))
        }

      default:
        result(FlutterMethodNotImplemented)
      }
    }
  }
}
