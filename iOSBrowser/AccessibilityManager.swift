//
//  AccessibilityManager.swift
//  iOSBrowser
//
//  适老化模式管理器 - 支持切换适老模式和正常模式
//

import SwiftUI
import Combine

// MARK: - 适老化模式枚举
enum AccessibilityMode: String, CaseIterable {
    case normal = "normal"
    case elderly = "elderly"
    
    var displayName: String {
        switch self {
        case .normal:
            return "正常模式"
        case .elderly:
            return "适老模式"
        }
    }
    
    var description: String {
        switch self {
        case .normal:
            return "标准界面，适合一般用户"
        case .elderly:
            return "大字体、高对比度，适合老年用户"
        }
    }
    
    var icon: String {
        switch self {
        case .normal:
            return "person.fill"
        case .elderly:
            return "accessibility"
        }
    }
}

// MARK: - 适老化模式管理器
class AccessibilityManager: ObservableObject {
    static let shared = AccessibilityManager()
    
    @Published var isSearchFocused = false
    @Published var isVoiceOverEnabled = false
    @Published var isDynamicTypeEnabled = false
    @Published var preferredContentSizeCategory: ContentSizeCategory = .large
    
    private init() {
        // 监听系统辅助功能变化
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(voiceOverStatusDidChange),
            name: UIAccessibility.voiceOverStatusDidChangeNotification,
            object: nil
        )
        
        // 初始化状态
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
        isDynamicTypeEnabled = UIApplication.shared.preferredContentSizeCategory != .large
        preferredContentSizeCategory = UIApplication.shared.preferredContentSizeCategory
    }
    
    func setSearchFocused(_ focused: Bool) {
        isSearchFocused = focused
    }
    
    @objc private func voiceOverStatusDidChange() {
        isVoiceOverEnabled = UIAccessibility.isVoiceOverRunning
    }
    
    func announceSearchResult(_ result: String) {
        if isVoiceOverEnabled {
            UIAccessibility.post(notification: .announcement, argument: result)
        }
    }
    
    func getAccessibilityLabel(for text: String, context: String) -> String {
        return "\(context): \(text)"
    }
    
    func getAccessibilityHint(for action: String) -> String {
        return "双击以\(action)"
    }
}

// MARK: - 适老化模式切换视图
struct AccessibilityModeToggleView: View {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text("选择界面模式")) {
                    ForEach(AccessibilityMode.allCases, id: \.self) { mode in
                        Button(action: {
                            accessibilityManager.switchMode(mode)
                        }) {
                            HStack(spacing: 16) {
                                Image(systemName: mode.icon)
                                    .font(.system(size: accessibilityManager.getFontSize(20)))
                                    .foregroundColor(accessibilityManager.currentMode == mode ? .themeGreen : .gray)
                                    .frame(width: 30)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mode.displayName)
                                        .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
                                        .foregroundColor(accessibilityManager.getTextColor())
                                    
                                    Text(mode.description)
                                        .font(.system(size: accessibilityManager.getFontSize(14)))
                                        .foregroundColor(accessibilityManager.getSecondaryTextColor())
                                        .lineLimit(2)
                                }
                                
                                Spacer()
                                
                                if accessibilityManager.currentMode == mode {
                                    Image(systemName: "checkmark.circle.fill")
                                        .foregroundColor(.themeGreen)
                                        .font(.system(size: accessibilityManager.getFontSize(18)))
                                }
                            }
                            .padding(.vertical, 8)
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                }
                
                Section(header: Text("模式说明")) {
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "textformat.size")
                                .foregroundColor(.themeGreen)
                            Text("正常模式")
                                .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
                        }
                        Text("• 标准字体大小和间距")
                        Text("• 系统默认颜色主题")
                        Text("• 适合一般用户使用")
                    }
                    .font(.system(size: accessibilityManager.getFontSize(14)))
                    .foregroundColor(accessibilityManager.getSecondaryTextColor())
                    .padding(.vertical, 8)
                    
                    VStack(alignment: .leading, spacing: 12) {
                        HStack {
                            Image(systemName: "accessibility")
                                .foregroundColor(.themeGreen)
                            Text("适老模式")
                                .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
                        }
                        Text("• 字体放大1.3倍")
                        Text("• 高对比度颜色")
                        Text("• 搜索时字体进一步放大")
                        Text("• 适合老年用户使用")
                    }
                    .font(.system(size: accessibilityManager.getFontSize(14)))
                    .foregroundColor(accessibilityManager.getSecondaryTextColor())
                    .padding(.vertical, 8)
                }
                
                Section {
                    Button(action: {
                        accessibilityManager.resetToDefault()
                    }) {
                        HStack {
                            Image(systemName: "arrow.clockwise")
                            Text("重置为默认设置")
                        }
                        .foregroundColor(.red)
                        .font(.system(size: accessibilityManager.getFontSize(16)))
                    }
                }
            }
            .navigationTitle("适老化模式")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("完成") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.themeGreen)
                .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
            )
        }
        .preferredColorScheme(accessibilityManager.currentMode == .elderly ? .light : nil)
    }
}

// MARK: - 适老化文本视图修饰符
struct AccessibilityTextModifier: ViewModifier {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    let baseSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: accessibilityManager.getFontSize(baseSize)))
            .foregroundColor(accessibilityManager.getTextColor())
    }
}

// MARK: - 适老化搜索框修饰符
struct AccessibilitySearchFieldModifier: ViewModifier {
    @ObservedObject private var accessibilityManager = AccessibilityManager.shared
    let baseSize: CGFloat
    
    func body(content: Content) -> some View {
        content
            .font(.system(size: accessibilityManager.getSearchFontSize(baseSize)))
            .foregroundColor(accessibilityManager.getTextColor())
            .background(accessibilityManager.getSearchBackgroundColor())
    }
}

// MARK: - 视图扩展
extension View {
    func accessibilityText(baseSize: CGFloat) -> some View {
        modifier(AccessibilityTextModifier(baseSize: baseSize))
    }
    
    func accessibilitySearchField(baseSize: CGFloat) -> some View {
        modifier(AccessibilitySearchFieldModifier(baseSize: baseSize))
    }
} 