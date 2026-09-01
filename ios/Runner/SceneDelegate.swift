import Flutter
import UIKit
import UserNotifications

class SceneDelegate: FlutterSceneDelegate {
  static let launchRouteKey = "flutter.bsr_tap_trail"

  override func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions
  ) {
    super.scene(scene, willConnectTo: session, options: connectionOptions)

    guard
      let response = connectionOptions.notificationResponse,
      let destination = Self.destination(
        inside: response.notification.request.content.userInfo
      )
    else { return }

    let defaults = UserDefaults.standard
    defaults.set(destination, forKey: Self.launchRouteKey)
    defaults.synchronize()

    #if DEBUG
    NSLog("[GALE.ROUTE] captured notification destination") // #if DEBUG
    #endif
  }

  private static func destination(
    inside payload: [AnyHashable: Any]
  ) -> String? {
    let candidates = [
      "deep_link",
      "target",
      "url",
      "deeplink",
      "link",
      "web_url",
      "webUrl",
      "destination",
    ]

    func firstValue(in dictionary: [AnyHashable: Any]) -> String? {
      for candidate in candidates {
        guard let value = dictionary[candidate] as? String else { continue }
        let trimmed = value.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmed.isEmpty { return trimmed }
      }
      return nil
    }

    // Search containers first so a nested `data.deep_link` (the standard FCM
    // shape) is picked before a generic top-level `url` that some servers
    // put on the base page.
    for container in ["data", "payload", "fcm_options", "notification"] {
      if let nested = payload[container] as? [AnyHashable: Any],
         let value = firstValue(in: nested) {
        return value
      }
    }

    return firstValue(in: payload)
  }
}
