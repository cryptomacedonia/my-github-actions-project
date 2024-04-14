import Foundation
/// this is not used, may be used later on. could be deleted!
public class AppShared {
    public enum SpacingStyle {
        case small
        case regular
        case large
    }

    public enum Regex: String {
        case name = "^[a-zA-Z\\s]*$"
        case email = "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        case number = "^[0-9]+$"
        case password = #"^(?=.*[A-Z])(?=.*[a-z])(?=.*[!@#$%^&*()_+]).{7,}$"#
        case serverAddress =
                #"^((http|https)://)[-a-zA-Z0-9@:%._\\+~#?&//=]{2,256}\\.[a-z]{2,6}\\b([-a-zA-Z0-9@:%._\\+~#?&//=]*)$"#
    }

    public static func spacing(_ style: SpacingStyle) -> CGFloat {
        switch style {
        case .small:
            return 12
        case .regular:
            return 18
        case .large:
            return 25
        }
    }

    public  struct Settings {
        static var heicEnabled =  UserDefaults.standard.bool(forKey: "heicEnabled") {
            didSet {
                UserDefaults.standard.setValue(heicEnabled, forKey: "heicEnabled")
            }
        }
        static var pngjpgEnabled =  UserDefaults.standard.bool(forKey: "pngjpgEnabled") {
            didSet {
                UserDefaults.standard.setValue(pngjpgEnabled, forKey: "pngjpgEnabled")
            }
        }
        static var videosEnabled =  UserDefaults.standard.bool(forKey: "videosEnabled") {
            didSet {
                UserDefaults.standard.setValue(videosEnabled, forKey: "videosEnabled")
            }
        }
    }
}
