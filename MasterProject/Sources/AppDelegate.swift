
import Alamofire
import Pulse
import SwiftData
import UIKit
import UserNotifications

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(_ application: UIApplication,
                     didFinishLaunchingWithOptions launchOptions:
                     [UIApplication.LaunchOptionsKey: Any]? = nil) -> Bool {
        /// this is needed for network debugging usifg Pulse !
        URLSessionProxyDelegate.enableAutomaticRegistration()
        return true
    }
}
