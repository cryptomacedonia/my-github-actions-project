import SwiftData
import SwiftUI
import UIKit
extension View {
    func appFont(_ textStyle: AppFont.TextStyle) -> some View {
        modifier(AppFont(textStyle: textStyle))
    }
}

extension UIColor {
    static func app(_ name: AssetsColor) -> UIColor? {
        return UIColor(named: name.rawValue)
    }
}

extension Color {
    static func app(_ name: AssetsColor) -> Color? {
        return Color(name.rawValue)
    }
}

public extension View {
    func roundedGrayBackground() -> some View {
        modifier(RoundedGratBackground())
    }

    func containedButton(horizontalPadding: CGFloat = AppShared.spacing(.regular)) -> some View {
        modifier(ContainedButton(horizontalPadding: horizontalPadding))
    }

    func outlinedButton() -> some View {
        modifier(ContainedButton())
    }

    func textButton() -> some View {
        modifier(ContainedButton())
    }

    func overlay<T: View>(overlayView: T, show: Binding<Bool>) -> some View {
        modifier(Overlay(show: show, overlayView: overlayView))
    }
}

extension View {
    // method to hide the keyboard after pressing  button
    func hideKeyboard() {
        let resign = #selector(UIResponder.resignFirstResponder)
        UIApplication.shared.sendAction(resign, to: nil, from: nil, for: nil)
    }
}

extension String {
    func matches(_ regex: String) -> Bool {
        return range(of: regex, options: .regularExpression, range: nil, locale: nil) != nil
    }
}

func makeQuery<T: PersistentModel>(predicate: Predicate<T>,
                                   sortDescriptor: SortDescriptor<T>,
                                   modelContext: ModelContext) -> [T]? {
    let descriptor = FetchDescriptor<T>(predicate: predicate, sortBy: [sortDescriptor])
    return try? modelContext.fetch(descriptor)
}

func getUser(modelContext: ModelContext?) -> UserDataObject? {
    guard let modelContext = modelContext  else { return nil }
    let predicate = #Predicate<UserDataObject> { _ in true }
    let sortDescriptor = SortDescriptor(\UserDataObject.hostName)
    if let user = makeQuery(predicate: predicate, sortDescriptor: sortDescriptor, modelContext: modelContext)?.first {
        return user
    } else {
        modelContext.insert(UserDataObject(role: 0))
        try? modelContext.save()
        return getUser(modelContext: modelContext)
    }
}

extension UIDevice {
    static let deviceDidShakeNotification = Notification.Name(rawValue: "deviceDidShakeNotification")
}

//  Override the default behavior of shake gestures to send our notification instead.
extension UIWindow {
    override open func motionEnded(_ motion: UIEvent.EventSubtype, with event: UIEvent?) {
        if motion == .motionShake {
            NotificationCenter.default.post(name: UIDevice.deviceDidShakeNotification, object: nil)
        }
    }
}


import SwiftUI

struct RoundedGratBackground: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding()
            .background(.gray.opacity(0.1))
            .cornerRadius(8)
    }
}

struct ContainedButton: ViewModifier {
    let horizontalPadding: CGFloat
    init(horizontalPadding: CGFloat = 33) {
        self.horizontalPadding = horizontalPadding
    }

    func body(content: Content) -> some View {
        content
            .padding()
            .padding(.horizontal, horizontalPadding)
            .background(Color.app(.primary))
            .cornerRadius(8)
            .foregroundColor(Color.app(.inversePrimary))
    }
}

struct Overlay<T: View>: ViewModifier {
    @Binding var show: Bool
    let overlayView: T

    func body(content: Content) -> some View {
        ZStack(alignment: .top) {
            content
            if show {
                overlayView
            }
        }
    }
}

enum SFTExtFieldStyle {
    case defaultTextFieldStyle
    case roundedBorderTextFieldStyle
    case plainTextFieldStyle
}

struct SFTextField: View {
    let title: String
    let regex: AppShared.Regex
    let alignment: Alignment
    let offset: (x: CGFloat, y: CGFloat)
    let showErrors: Bool
    @State var isValid: Int = 2
    @State var activatedValidation = false
    @Binding var text: String
//    let style: T
    init(title: String,
         regex: AppShared.Regex,
         alignment: Alignment = .bottomTrailing,
         text: Binding<String>,
//         style: T = defaultTextFieldStyle(),
         offset: (CGFloat, CGFloat) = (0, 9),
         showErrors: Bool = true) {
        self.regex = regex
        self.alignment = alignment
        _text = text
//        self.style = style
        self.offset = offset
        self.title = title
        self.showErrors = showErrors
    }

    var body: some View {
        VStack {
            if regex != .password {
                TextField(title, text: $text, onEditingChanged: { editing in
                    activatedValidation = activatedValidation == true ? true : !editing
                }).disableAutocorrection(true)
                    .autocapitalization(.none)
                    .keyboardType(regex == .serverAddress ? .default : .emailAddress)
                    .textFieldStyle(DefaultTextFieldStyle())
                    .onChange(of: text) { _, _ in
                        let predicate = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
                        if predicate.evaluate(with: text) {
                            isValid = 1
                        } else {
                            if text.isEmpty {
                                isValid = 2
                            } else {
                                isValid = 0
                            }
                        }
                    }
                    .overlay(alignment: alignment) {
                        if activatedValidation && isValid != 2 && showErrors {
                            Text(isValid == 1
                                 ? ""
                                 : getMyErrorString(regex: regex)).appFont(.caption1)
                                .offset(x: offset.x, y: offset.y)
                                .foregroundColor(Color.app(.error))
                                .background(.clear)
                        } else {
                        }
                    }
            } else {
                SecureField(title, text: $text).onTapGesture {
                    activatedValidation = true
                }
                .disableAutocorrection(true)
                .autocapitalization(.none)
                .keyboardType(.emailAddress)
                .textFieldStyle(DefaultTextFieldStyle())
                .onChange(of: text) { _, _ in
                    let predicate = NSPredicate(format: "SELF MATCHES %@", regex.rawValue)
                    if predicate.evaluate(with: text) {
                        isValid = 1
                    } else {
                        if text.isEmpty {
                            isValid = 2
                        } else {
                            isValid = 0
                        }
                    }
                }
                .overlay(alignment: alignment) {
                    if activatedValidation && isValid != 2 && showErrors {
                        Text(isValid == 1
                             ? ""
                             : getMyErrorString(regex: regex))
                        .appFont(.caption1).offset(x: offset.x, y: offset.y)
                        .foregroundColor(Color.app(.error))
                        .background(.clear)
                    } else {
                    }
                }
            }
        }
    }
}

func getMyErrorString(regex: AppShared.Regex) -> String {
    var errorString = ""
    switch regex {
    case .email:
        errorString = "please enter valid email address"
    case .password:
        errorString = "password must have special character and uppercase lowercase"
    case .serverAddress:
        errorString = "enter valid url pointing to server including http"
    case .number:
        errorString = ""
    case .name:
        errorString = "Name must not contain digits or special characters"
    }
    print(errorString)
    return errorString
}

struct DeviceShakeViewModifier: ViewModifier {
    let action: () -> Void

    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.deviceDidShakeNotification)) { _ in
                action()
            }
    }
}

extension View {
    func onShake(perform action: @escaping () -> Void) -> some View {
        modifier(DeviceShakeViewModifier(action: action))
    }
}

struct DeviceRotationViewModifier: ViewModifier {
    let action: (UIDeviceOrientation) -> Void
    func body(content: Content) -> some View {
        content
            .onAppear()
            .onReceive(NotificationCenter.default.publisher(for: UIDevice.orientationDidChangeNotification)) { _ in
                action(UIDevice.current.orientation)
            }
    }
}

// A View wrapper to make the modifier easier to use
extension View {
    func onRotate(perform action: @escaping (UIDeviceOrientation) -> Void) -> some View {
        modifier(DeviceRotationViewModifier(action: action))
    }
}
