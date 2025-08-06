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
    
    @Published var currentMode: AccessibilityMode = .normal
    @Published var isSearchFocused: Bool = false
    
    private let userDefaults = UserDefaults.standard
    private let accessibilityModeKey = "accessibility_mode"
    
    private init() {
        loadAccessibilityMode()
    }
    
    // MARK: - 模式切换
    func switchMode(_ mode: AccessibilityMode) {
        currentMode = mode
        saveAccessibilityMode()
        print("🔄 切换到\(mode.displayName)")
    }
    
    // MARK: - 获取字体大小
    func getFontSize(_ baseSize: CGFloat) -> CGFloat {
        switch currentMode {
        case .normal:
            return baseSize
        case .elderly:
            return baseSize * 1.3
        }
    }
    
    // MARK: - 获取搜索框字体大小
    func getSearchFontSize(_ baseSize: CGFloat) -> CGFloat {
        if isSearchFocused && currentMode == .elderly {
            return baseSize * 1.5 // 搜索时进一步放大
        }
        return getFontSize(baseSize)
    }
    
    // MARK: - 获取颜色
    func getTextColor() -> Color {
        switch currentMode {
        case .normal:
            return .primary
        case .elderly:
            return .black // 高对比度
        }
    }
    
    func getSecondaryTextColor() -> Color {
        switch currentMode {
        case .normal:
            return .secondary
        case .elderly:
            return .gray // 高对比度
        }
    }
    
    func getBackgroundColor() -> Color {
        switch currentMode {
        case .normal:
            return Color(.systemBackground)
        case .elderly:
            return .white // 高对比度
        }
    }
    
    func getSearchBackgroundColor() -> Color {
        switch currentMode {
        case .normal:
            return Color(.systemGray6)
        case .elderly:
            return Color(.systemGray5) // 更明显的背景
        }
    }
    
    // MARK: - 获取间距
    func getSpacing(_ baseSpacing: CGFloat) -> CGFloat {
        switch currentMode {
        case .normal:
            return baseSpacing
        case .elderly:
            return baseSpacing * 1.2
        }
    }
    
    // MARK: - 获取按钮大小
    func getButtonSize(_ baseSize: CGFloat) -> CGFloat {
        switch currentMode {
        case .normal:
            return baseSize
        case .elderly:
            return baseSize * 1.2
        }
    }
    
    // MARK: - 搜索框焦点状态
    func setSearchFocused(_ focused: Bool) {
        isSearchFocused = focused
        print("🔍 搜索框焦点状态: \(focused ? "获得焦点" : "失去焦点")")
    }
    
    // MARK: - 保存和加载设置
    private func saveAccessibilityMode() {
        userDefaults.set(currentMode.rawValue, forKey: accessibilityModeKey)
        userDefaults.synchronize()
        print("💾 保存适老化模式: \(currentMode.displayName)")
    }
    
    private func loadAccessibilityMode() {
        if let savedMode = userDefaults.string(forKey: accessibilityModeKey),
           let mode = AccessibilityMode(rawValue: savedMode) {
            currentMode = mode
            print("📱 加载适老化模式: \(mode.displayName)")
        } else {
            currentMode = .normal
            print("📱 使用默认适老化模式: 正常模式")
        }
    }
    
    // MARK: - 重置为默认设置
    func resetToDefault() {
        currentMode = .normal
        saveAccessibilityMode()
        print("🔄 重置为默认适老化模式")
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