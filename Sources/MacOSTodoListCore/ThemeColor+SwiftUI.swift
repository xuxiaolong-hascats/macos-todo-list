import SwiftUI

extension ThemeColor {
    var color: Color {
        switch self {
        case .blue:
            Color(nsColor: .systemBlue)
        case .graphite:
            Color(nsColor: .systemGray)
        case .green:
            Color(nsColor: .systemGreen)
        case .orange:
            Color(nsColor: .systemOrange)
        case .pink:
            Color(nsColor: .systemPink)
        case .purple:
            Color(nsColor: .systemPurple)
        }
    }
}
