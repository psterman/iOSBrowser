//
//  ContentView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/13.
//

import SwiftUI
import UIKit

struct ContentView: View {
    @StateObject private var webViewModel = WebViewModel()
    @State private var selectedTab = 0
    @State private var dragOffset: CGFloat = 0
    @State private var isDragging = false
    @State private var initialDragLocation: CGPoint = .zero
    @State private var canSwitchTab = false

    var body: some View {
        VStack(spacing: 0) {

            // 主内容区域 - 微信风格的简洁滑动
            GeometryReader { geometry in
                HStack(spacing: 0) {
                    AIContactsView()
                        .frame(width: geometry.size.width)

                    BrowserView(viewModel: webViewModel)
                        .frame(width: geometry.size.width)

                    SearchView()
                        .frame(width: geometry.size.width)

                    SettingsView()
                        .frame(width: geometry.size.width)
                }
                .offset(x: -CGFloat(selectedTab) * geometry.size.width + dragOffset)
                .animation(isDragging ? .none : .easeInOut(duration: 0.25), value: selectedTab)
                .gesture(
                    DragGesture(coordinateSpace: .global)
                        .onChanged { value in
                            // 检查边界条件
                            let canSwipeLeft = selectedTab < 3 // 不是最后一个tab
                            let canSwipeRight = selectedTab > 0 // 不是第一个tab

                            // 根据滑动方向和边界条件决定是否允许拖拽
                            let isSwipingLeft = value.translation.width < 0
                            let isSwipingRight = value.translation.width > 0

                            // 检查是否是从屏幕边缘开始的滑动（提高优先级）
                            let edgeThreshold: CGFloat = 50
                            let isFromLeftEdge = value.startLocation.x < edgeThreshold
                            let isFromRightEdge = value.startLocation.x > geometry.size.width - edgeThreshold
                            let isEdgeSwipe = isFromLeftEdge || isFromRightEdge

                            // 检查滑动距离是否足够（避免误触）
                            let swipeDistance = abs(value.translation.width)
                            let minSwipeDistance: CGFloat = isEdgeSwipe ? 10 : 30

                            if swipeDistance > minSwipeDistance &&
                               ((isSwipingLeft && canSwipeLeft) || (isSwipingRight && canSwipeRight)) {
                                isDragging = true
                                // 限制拖拽范围，防止过度滑动
                                let maxOffset = geometry.size.width * 0.3
                                dragOffset = max(-maxOffset, min(maxOffset, value.translation.width))
                            }
                        }
                        .onEnded { value in
                            isDragging = false
                            let threshold: CGFloat = geometry.size.width * 0.15 // 降低阈值，更容易触发

                            // 向右滑动（显示前一个tab）- 第一个tab不能左滑
                            if value.translation.width > threshold && selectedTab > 0 {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedTab -= 1
                                }
                            }
                            // 向左滑动（显示后一个tab）- 第四个tab不能右滑
                            else if value.translation.width < -threshold && selectedTab < 3 {
                                withAnimation(.easeInOut(duration: 0.25)) {
                                    selectedTab += 1
                                }
                            }

                            dragOffset = 0
                        }
                )
                .clipped()
            }

            // 微信风格的底部Tab栏
            WeChatTabBar(selectedTab: $selectedTab)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}





struct WeChatTabBar: View {
    @Binding var selectedTab: Int

    var body: some View {
        HStack(spacing: 0) {
            // AI联系人
            WeChatTabItem(
                icon: "person.2.fill",
                title: "AI联系人",
                isSelected: selectedTab == 0
            ) {
                selectedTab = 0
            }

            // 浏览器
            WeChatTabItem(
                icon: "globe",
                title: "浏览器",
                isSelected: selectedTab == 1
            ) {
                selectedTab = 1
            }

            // 搜索
            WeChatTabItem(
                icon: "magnifyingglass",
                title: "搜索",
                isSelected: selectedTab == 2
            ) {
                selectedTab = 2
            }

            // 设置
            WeChatTabItem(
                icon: "gearshape.fill",
                title: "设置",
                isSelected: selectedTab == 3
            ) {
                selectedTab = 3
            }
        }
        .padding(.top, 8)
        .padding(.bottom, 8)
        .background(Color(.systemBackground))
        .overlay(
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(Color(.separator)),
            alignment: .top
        )
    }
}

struct WeChatTabItem: View {
    let icon: String
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 24, weight: .regular))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(.systemGray))

                Text(title)
                    .font(.system(size: 10, weight: .regular))
                    .foregroundColor(isSelected ? Color(red: 0.2, green: 0.7, blue: 0.3) : Color(.systemGray))
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 6)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// 临时的SearchView定义，直到文件被正确添加到项目中
struct SearchView: View {
    @State private var searchText = ""
    @State private var showingAlert = false
    @State private var alertMessage = ""
    @State private var selectedCategory = "全部"

    private let categories = ["全部", "购物", "社交", "视频", "音乐", "生活", "地图", "浏览器", "其他"]

    // 应用数据 - 使用更贴近原App的图标和品牌色
    private let apps = [
        // 购物类
        AppInfo(name: "淘宝", icon: "T", systemIcon: "bag.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "taobao://s.taobao.com/search?q=", bundleId: "com.taobao.taobao4iphone", category: "购物"),
        AppInfo(name: "天猫", icon: "天", systemIcon: "bag.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "tmall://search?q=", bundleId: "com.tmall.wireless", category: "购物"),
        AppInfo(name: "拼多多", icon: "P", systemIcon: "cart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "pinduoduo://search?keyword=", bundleId: "com.xunmeng.pinduoduo", category: "购物"),
        AppInfo(name: "京东", icon: "京", systemIcon: "cube.box.fill", color: Color(red: 0.8, green: 0.0, blue: 0.0), urlScheme: "openapp.jdmobile://virtual?params={\"category\":\"jump\",\"des\":\"search\",\"keyword\":\"", bundleId: "com.360buy.jdmobile", category: "购物"),
        AppInfo(name: "闲鱼", icon: "闲", systemIcon: "fish.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "fleamarket://search?q=", bundleId: "com.taobao.fleamarket", category: "购物"),

        // 社交媒体
        AppInfo(name: "知乎", icon: "知", systemIcon: "bubble.left.circle.fill", color: Color(red: 0.0, green: 0.5, blue: 1.0), urlScheme: "zhihu://search?q=", bundleId: "com.zhihu.ios", category: "社交"),
        AppInfo(name: "微博", icon: "微", systemIcon: "at.circle.fill", color: Color(red: 1.0, green: 0.3, blue: 0.3), urlScheme: "sinaweibo://search?q=", bundleId: "com.sina.weibo", category: "社交"),
        AppInfo(name: "小红书", icon: "小", systemIcon: "heart.circle.fill", color: Color(red: 1.0, green: 0.2, blue: 0.4), urlScheme: "xhsdiscover://search?keyword=", bundleId: "com.xingin.xhs", category: "社交"),

        // 视频娱乐
        AppInfo(name: "抖音", icon: "抖", systemIcon: "music.note.tv.fill", color: Color(red: 0.0, green: 0.0, blue: 0.0), urlScheme: "snssdk1128://search?keyword=", bundleId: "com.ss.iphone.ugc.Aweme", category: "视频"),
        AppInfo(name: "快手", icon: "快", systemIcon: "video.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "kwai://search?keyword=", bundleId: "com.kuaishou.gif", category: "视频"),
        AppInfo(name: "bilibili", icon: "B", systemIcon: "tv.circle.fill", color: Color(red: 1.0, green: 0.4, blue: 0.7), urlScheme: "bilibili://search?keyword=", bundleId: "tv.danmaku.bili", category: "视频"),
        AppInfo(name: "YouTube", icon: "Y", systemIcon: "play.tv.fill", color: Color(red: 1.0, green: 0.0, blue: 0.0), urlScheme: "youtube://results?search_query=", bundleId: "com.google.ios.youtube", category: "视频"),
        AppInfo(name: "优酷", icon: "优", systemIcon: "play.rectangle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "youku://search?keyword=", bundleId: "com.youku.YouKu", category: "视频"),
        AppInfo(name: "爱奇艺", icon: "爱", systemIcon: "tv.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "qiyi-iphone://search?key=", bundleId: "com.qiyi.iphone", category: "视频"),

        // 音乐
        AppInfo(name: "QQ音乐", icon: "Q", systemIcon: "music.note.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.2), urlScheme: "qqmusic://search?key=", bundleId: "com.tencent.QQMusic", category: "音乐"),
        AppInfo(name: "网易云音乐", icon: "网", systemIcon: "music.note.list", color: Color(red: 1.0, green: 0.2, blue: 0.2), urlScheme: "orpheus://search?keyword=", bundleId: "com.netease.cloudmusic", category: "音乐"),

        // 生活服务
        AppInfo(name: "美团", icon: "美", systemIcon: "takeoutbag.and.cup.and.straw.fill", color: Color(red: 1.0, green: 0.8, blue: 0.0), urlScheme: "imeituan://www.meituan.com/search?q=", bundleId: "com.meituan.imeituan", category: "生活"),
        AppInfo(name: "饿了么", icon: "饿", systemIcon: "fork.knife.circle.fill", color: Color(red: 0.0, green: 0.6, blue: 1.0), urlScheme: "eleme://search?keyword=", bundleId: "me.ele.ios.eleme", category: "生活"),
        AppInfo(name: "大众点评", icon: "大", systemIcon: "star.circle.fill", color: Color(red: 1.0, green: 0.6, blue: 0.0), urlScheme: "dianping://search?keyword=", bundleId: "com.dianping.dpscope", category: "生活"),

        // 地图导航
        AppInfo(name: "高德地图", icon: "高", systemIcon: "map.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 1.0), urlScheme: "iosamap://search?keywords=", bundleId: "com.autonavi.minimap", category: "地图"),
        AppInfo(name: "腾讯地图", icon: "腾", systemIcon: "location.circle.fill", color: Color(red: 0.0, green: 0.8, blue: 0.4), urlScheme: "sosomap://search?keyword=", bundleId: "com.tencent.map", category: "地图"),

        // 浏览器
        AppInfo(name: "夸克", icon: "夸", systemIcon: "globe.circle.fill", color: Color(red: 0.4, green: 0.6, blue: 1.0), urlScheme: "quark://search?q=", bundleId: "com.quark.browser", category: "浏览器"),
        AppInfo(name: "UC浏览器", icon: "UC", systemIcon: "safari.fill", color: Color(red: 1.0, green: 0.4, blue: 0.0), urlScheme: "ucbrowser://search?keyword=", bundleId: "com.uc.iphone", category: "浏览器"),

        // 其他
        AppInfo(name: "豆瓣", icon: "豆", systemIcon: "book.circle.fill", color: Color(red: 0.0, green: 0.7, blue: 0.3), urlScheme: "douban://search?q=", bundleId: "com.douban.frodo", category: "其他")
    ]

    var filteredApps: [AppInfo] {
        if selectedCategory == "全部" {
            return apps
        } else {
            return apps.filter { $0.category == selectedCategory }
        }
    }

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // 搜索栏
                VStack(spacing: 16) {
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.gray)
                            .font(.system(size: 16))

                        TextField("输入搜索关键词", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())

                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 16))
                            }
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color(.systemGray6))
                    .cornerRadius(10)
                    .padding(.horizontal, 16)

                    Text("选择应用进行搜索")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
                .padding(.top, 16)
                .padding(.bottom, 16)

                // 分类选择器
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 12) {
                        ForEach(categories, id: \.self) { category in
                            Button(action: {
                                selectedCategory = category
                            }) {
                                Text(category)
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(selectedCategory == category ? Color.blue : Color(.systemGray5))
                                    .foregroundColor(selectedCategory == category ? .white : .primary)
                                    .cornerRadius(20)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.bottom, 16)

                // 应用网格
                ScrollView {
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 4), spacing: 16) {
                        ForEach(filteredApps, id: \.name) { app in
                            AppButton(app: app, searchText: searchText) {
                                searchInApp(app: app)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("应用搜索")
            .alert("提示", isPresented: $showingAlert) {
                Button("确定", role: .cancel) { }
            } message: {
                Text(alertMessage)
            }
        }
    }

    private func searchInApp(app: AppInfo) {
        guard !searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            alertMessage = "请输入搜索关键词"
            showingAlert = true
            return
        }

        let keyword = searchText.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? searchText
        let urlString = app.urlScheme + keyword

        if let url = URL(string: urlString) {
            UIApplication.shared.open(url)
        }
    }
}

struct AppInfo {
    let name: String
    let icon: String // Emoji图标或自定义图标名称
    let systemIcon: String // 系统图标作为备用
    let color: Color
    let urlScheme: String
    let bundleId: String? // App的Bundle ID，用于获取真实图标
    let category: String // 应用分类
}

// 获取已安装App图标的辅助函数
func getAppIcon(for bundleId: String) -> UIImage? {
    guard let url = URL(string: "app-settings:") else { return nil }

    // 尝试通过LSApplicationWorkspace获取图标（私有API，可能不被App Store接受）
    // 这里使用一个更安全的方法
    if UIApplication.shared.canOpenURL(URL(string: bundleId + "://") ?? url) {
        // App已安装，但我们无法直接获取图标
        // 返回nil，让界面使用备用图标
        return nil
    }
    return nil
}

struct AppButton: View {
    let app: AppInfo
    let searchText: String
    let action: () -> Void
    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                ZStack {
                    // 背景圆形，使用应用的品牌色
                    Circle()
                        .fill(app.color)
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)

                    // 显示文字图标或自定义图标
                    Group {
                        if UIImage(named: app.icon) != nil {
                            // 显示自定义图标
                            Image(app.icon)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                                .frame(width: 32, height: 32)
                                .clipShape(RoundedRectangle(cornerRadius: 6))
                        } else {
                            // 显示文字图标
                            Text(app.icon)
                                .font(.system(size: 18, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                    }
                }

                Text(app.name)
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.primary)
                    .lineLimit(1)
                    .minimumScaleFactor(0.8)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color(.systemBackground))
                    .shadow(color: .black.opacity(0.05), radius: 2, x: 0, y: 1)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
        .opacity(searchText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? 0.6 : 1.0)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
