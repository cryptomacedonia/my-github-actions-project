import SwiftUI

var font = "Avenir"
struct AppFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory

    public enum TextStyle {
        case title1
        case title2
        case title3
        case largeTitle
        case headLine
        case subHeadline
        case body
        case footNote1
        case footNote2
        case caption1
        case caption2
        case callout
    }

    var textStyle: TextStyle

    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(fontName, size: scaledSize))
    }

    private var fontName: String {
        switch textStyle {
        case .largeTitle:
            return "\(font)"
        case .title1:
            return "\(font)"
        case .title2:
            return "\(font)"
        case .title3:
            return "\(font)"
        case .headLine:
            return "\(font)-Black"
        case .subHeadline:
            return "\(font)"
        case .body:
            return "\(font)"
        case .footNote1:
            return "\(font)"
        case .footNote2:
            return "\(font)"
        case .caption1:
            return "\(font)"
        case .caption2:
            return "\(font)"
        case .callout:
            return "\(font)"
        }
    }

    private var size: CGFloat {
        switch textStyle {
        case .title1:
            return 26
        case .title2:
            return 20
        case .title3:
            return 18
        case .largeTitle:
            return 32
        case .headLine:
            return 18
        case .subHeadline:
            return 15
        case .body:
            return 15
        case .footNote1:
            return 12
        case .footNote2:
            return 10
        case .caption1:
            return 11
        case .caption2:
            return 11
        case .callout:
            return 15
        }
    }
}
