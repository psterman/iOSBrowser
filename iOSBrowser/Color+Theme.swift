import SwiftUI

extension Color {
    static let themeGreen = Color(red: 0.2, green: 0.7, blue: 0.3)
    static let themeLightGreen = Color(red: 0.3, green: 0.8, blue: 0.4)
    static let themeDarkGreen = Color(red: 0.1, green: 0.6, blue: 0.2)
    
    static let themeBackground = Color(.systemBackground)
    static let themeSecondaryBackground = Color(.secondarySystemBackground)
    static let themeGroupedBackground = Color(.systemGroupedBackground)
    
    static let themeSeparator = Color(.separator)
    static let themeOpaqueSeparator = Color(.opaqueSeparator)
    
    static let themePrimary = Color(.label)
    static let themeSecondary = Color(.secondaryLabel)
    static let themeTertiary = Color(.tertiaryLabel)
    static let themeQuaternary = Color(.quaternaryLabel)
    
    static let themePlaceholder = Color(.placeholderText)
    static let themeLink = Color(.link)
    
    static let themeTint = themeGreen
    static let themeAccent = themeLightGreen
} 