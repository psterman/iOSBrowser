//
//  GestureGuideView.swift
//  iOSBrowser
//
//  手势操作指南页面 - 适老化设计
//

import SwiftUI

struct GestureGuideView: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    @State private var currentPage = 0
    
    private let gestureGuides = [
        GestureGuide(
            title: "左右滑动切换标签页",
            description: "在底部标签栏区域左右滑动手指，可以快速切换不同的功能页面",
            icon: "arrow.left.and.right",
            color: .blue
        ),
        GestureGuide(
            title: "长按快速操作",
            description: "长按搜索框、书签或应用图标，可以快速复制、分享或执行其他操作",
            icon: "hand.tap",
            color: .green
        ),
        GestureGuide(
            title: "下拉刷新页面",
            description: "在浏览器页面下拉手指，可以刷新当前网页内容",
            icon: "arrow.clockwise",
            color: .orange
        ),
        GestureGuide(
            title: "双指缩放",
            description: "在浏览器页面使用双指捏合或展开手势，可以放大或缩小网页内容",
            icon: "arrow.up.left.and.arrow.down.right",
            color: .purple
        ),
        GestureGuide(
            title: "快捷搜索",
            description: "在任何页面点击搜索框，输入关键词或网址即可快速搜索或访问",
            icon: "magnifyingglass",
            color: .red
        )
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 页面指示器
                HStack(spacing: 8) {
                    ForEach(0..<gestureGuides.count, id: \.self) { index in
                        Circle()
                            .fill(index == currentPage ? Color.themeGreen : Color.gray.opacity(0.3))
                            .frame(width: 8, height: 8)
                            .scaleEffect(index == currentPage ? 1.2 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                    }
                }
                .padding(.top, 20)
                .padding(.bottom, 30)
                
                // 手势指南内容
                TabView(selection: $currentPage) {
                    ForEach(0..<gestureGuides.count, id: \.self) { index in
                        GestureGuideCard(guide: gestureGuides[index])
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                
                // 底部按钮
                VStack(spacing: 16) {
                    // 页面切换按钮
                    HStack(spacing: 20) {
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentPage = max(0, currentPage - 1)
                            }
                        }) {
                            HStack(spacing: 8) {
                                Image(systemName: "chevron.left")
                                    .font(.system(size: 18, weight: .medium))
                                                Text("上一页")
                    .font(.system(size: accessibilityManager.getFontSize(18), weight: .medium))
                            }
                            .foregroundColor(currentPage > 0 ? .themeGreen : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(currentPage > 0 ? Color.themeGreen.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                        }
                        .disabled(currentPage == 0)
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                currentPage = min(gestureGuides.count - 1, currentPage + 1)
                            }
                        }) {
                            HStack(spacing: 8) {
                                                Text("下一页")
                    .font(.system(size: accessibilityManager.getFontSize(18), weight: .medium))
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 18, weight: .medium))
                            }
                            .foregroundColor(currentPage < gestureGuides.count - 1 ? .themeGreen : .gray)
                            .padding(.horizontal, 20)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(currentPage < gestureGuides.count - 1 ? Color.themeGreen.opacity(0.1) : Color.gray.opacity(0.1))
                            )
                        }
                        .disabled(currentPage == gestureGuides.count - 1)
                    }
                    
                    // 完成按钮
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                                        Text("我知道了")
                    .font(.system(size: accessibilityManager.getFontSize(20), weight: .semibold))
                    .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.themeGreen)
                            )
                    }
                    .padding(.horizontal, 40)
                }
                .padding(.bottom, 40)
            }
            .navigationTitle("手势操作指南")
            .navigationBarTitleDisplayMode(.large)
            .navigationBarItems(
                trailing: Button("跳过") {
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.themeGreen)
                .font(.system(size: accessibilityManager.getFontSize(16), weight: .medium))
            )
        }
        .preferredColorScheme(accessibilityManager.currentMode == .elderly ? .light : nil)
    }
}

// MARK: - 手势指南卡片
struct GestureGuideCard: View {
    let guide: GestureGuide
    @StateObject private var accessibilityManager = AccessibilityManager.shared
    
    var body: some View {
        VStack(spacing: 30) {
            // 图标区域
            ZStack {
                Circle()
                    .fill(guide.color.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: guide.icon)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(guide.color)
            }
            .padding(.top, 40)
            
            // 文字内容
            VStack(spacing: 20) {
                Text(guide.title)
                    .font(.system(size: accessibilityManager.getFontSize(28), weight: .bold))
                    .foregroundColor(accessibilityManager.getTextColor())
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 20)
                
                Text(guide.description)
                    .font(.system(size: accessibilityManager.getFontSize(18), weight: .regular))
                    .foregroundColor(accessibilityManager.getSecondaryTextColor())
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
                    .padding(.horizontal, 30)
            }
            
            Spacer()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(accessibilityManager.getBackgroundColor())
    }
}

// MARK: - 手势指南数据模型
struct GestureGuide {
    let title: String
    let description: String
    let icon: String
    let color: Color
}

// MARK: - 预览
struct GestureGuideView_Previews: PreviewProvider {
    static var previews: some View {
        GestureGuideView()
    }
} 