//
//  HotTrendsView.swift
//  iOSBrowser
//
//  平台热榜界面组件 - 显示各平台热门内容
//

import SwiftUI

struct HotTrendsView: View {
    let platformId: String
    @StateObject private var hotTrendsManager = HotTrendsManager.shared
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedItem: HotTrendItem?
    @State private var showingItemDetail = false
    
    private var platform: PlatformContact? {
        PlatformContact.allPlatforms.first { $0.id == platformId }
    }
    
    private var hotTrends: HotTrendsList? {
        hotTrendsManager.getHotTrends(for: platformId)
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if let platform = platform {
                    // 平台头部信息
                    PlatformHeaderView(platform: platform)
                    
                    // 热榜列表
                    if let trends = hotTrends, !trends.items.isEmpty {
                        HotTrendsListView(
                            trends: trends,
                            onItemTap: { item in
                                selectedItem = item
                                handleItemTap(item)
                            }
                        )
                    } else if hotTrendsManager.isLoading[platformId] == true {
                        LoadingView()
                    } else {
                        EmptyStateView(platform: platform) {
                            hotTrendsManager.refreshHotTrends(for: platformId)
                        }
                    }
                } else {
                    Text("平台信息不存在")
                        .foregroundColor(.secondary)
                }
            }
            .navigationTitle(platform?.name ?? "热榜")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("刷新") {
                    hotTrendsManager.refreshHotTrends(for: platformId)
                }
            )
        }
        .onAppear {
            if hotTrendsManager.shouldUpdate(platform: platformId) {
                hotTrendsManager.refreshHotTrends(for: platformId)
            }
        }
        .sheet(isPresented: $showingItemDetail) {
            if let item = selectedItem {
                HotTrendItemDetailView(item: item)
            }
        }
    }
    
    private func handleItemTap(_ item: HotTrendItem) {
        print("🎯 点击热榜项目: \(item.title)")
        
        // 尝试打开深度链接
        if let urlString = item.url, let url = URL(string: urlString) {
            if UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                return
            }
        }
        
        // 如果深度链接失败，显示详情页面
        showingItemDetail = true
    }
}

// MARK: - 平台头部视图
struct PlatformHeaderView: View {
    let platform: PlatformContact
    @StateObject private var hotTrendsManager = HotTrendsManager.shared
    
    var body: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // 平台图标
                Image(systemName: platform.icon)
                    .font(.system(size: 32))
                    .foregroundColor(platform.color)
                    .frame(width: 50, height: 50)
                    .background(platform.color.opacity(0.1))
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(platform.name)
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text(platform.description)
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                    
                    // 更新时间
                    if let updateTime = hotTrendsManager.lastUpdateTime[platform.id] {
                        Text("更新时间: \(updateTime, formatter: timeFormatter)")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                // 状态指示器
                VStack(spacing: 4) {
                    Circle()
                        .fill(hotTrendsManager.isLoading[platform.id] == true ? Color.orange : Color.green)
                        .frame(width: 12, height: 12)
                    
                    Text(hotTrendsManager.isLoading[platform.id] == true ? "更新中" : "已更新")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
            .padding()
            
            Divider()
        }
        .background(Color(.systemBackground))
    }
    
    private var timeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "HH:mm"
        return formatter
    }
}

// MARK: - 热榜列表视图
struct HotTrendsListView: View {
    let trends: HotTrendsList
    let onItemTap: (HotTrendItem) -> Void
    
    var body: some View {
        List(trends.items) { item in
            HotTrendItemRow(item: item) {
                onItemTap(item)
            }
            .listRowInsets(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
        }
        .listStyle(PlainListStyle())
        .refreshable {
            await withCheckedContinuation { continuation in
                HotTrendsManager.shared.refreshHotTrends(for: trends.platform)

                // 等待加载完成
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    continuation.resume()
                }
            }
        }
    }
}

// MARK: - 热榜项目行视图
struct HotTrendItemRow: View {
    let item: HotTrendItem
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 12) {
                // 排名
                Text(item.displayRank)
                    .font(.headline)
                    .fontWeight(.bold)
                    .foregroundColor(item.isTopThree ? .orange : .secondary)
                    .frame(width: 30, alignment: .center)
                
                VStack(alignment: .leading, spacing: 4) {
                    // 标题
                    Text(item.title)
                        .font(.headline)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                        .lineLimit(2)
                    
                    // 描述
                    if let description = item.description {
                        Text(description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .lineLimit(1)
                    }
                    
                    // 底部信息
                    HStack {
                        if let category = item.category {
                            Text(category)
                                .font(.caption)
                                .padding(.horizontal, 8)
                                .padding(.vertical, 2)
                                .background(Color(.systemGray5))
                                .cornerRadius(4)
                        }
                        
                        Spacer()
                        
                        if let hotValue = item.hotValue {
                            Text(hotValue)
                                .font(.caption)
                                .foregroundColor(.orange)
                        }
                    }
                }
                
                Spacer()
                
                // 箭头指示器
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

// MARK: - 加载视图
struct LoadingView: View {
    var body: some View {
        VStack(spacing: 16) {
            ProgressView()
                .scaleEffect(1.5)
            
            Text("正在获取热榜数据...")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - 空状态视图
struct EmptyStateView: View {
    let platform: PlatformContact
    let onRetry: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("暂无热榜数据")
                .font(.headline)
            
            Text("请检查网络连接或稍后重试")
                .font(.subheadline)
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
            
            Button("重新加载") {
                onRetry()
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .padding()
    }
}

// MARK: - 热榜项目详情视图
struct HotTrendItemDetailView: View {
    let item: HotTrendItem
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // 排名和热度
                    HStack {
                        Text(item.displayRank)
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(item.isTopThree ? .orange : .secondary)

                        Spacer()

                        if let hotValue = item.hotValue {
                            Text(hotValue)
                                .font(.headline)
                                .foregroundColor(.orange)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 6)
                                .background(Color.orange.opacity(0.1))
                                .cornerRadius(8)
                        }
                    }

                    // 标题
                    Text(item.title)
                        .font(.title2)
                        .fontWeight(.bold)
                        .lineLimit(nil)

                    // 描述
                    if let description = item.description {
                        Text(description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineLimit(nil)
                    }

                    // 分类和时间
                    VStack(alignment: .leading, spacing: 8) {
                        if let category = item.category {
                            HStack {
                                Text("分类:")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)

                                Text(category)
                                    .font(.subheadline)
                                    .padding(.horizontal, 8)
                                    .padding(.vertical, 2)
                                    .background(Color(.systemGray5))
                                    .cornerRadius(4)
                            }
                        }

                        HStack {
                            Text("时间:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            Text(item.timestamp, formatter: detailTimeFormatter)
                                .font(.subheadline)
                        }

                        HStack {
                            Text("平台:")
                                .font(.subheadline)
                                .foregroundColor(.secondary)

                            if let platform = PlatformContact.allPlatforms.first(where: { $0.id == item.platform }) {
                                HStack(spacing: 4) {
                                    Image(systemName: platform.icon)
                                        .foregroundColor(platform.color)
                                    Text(platform.name)
                                }
                                .font(.subheadline)
                            } else {
                                Text(item.platform)
                                    .font(.subheadline)
                            }
                        }
                    }

                    // 操作按钮
                    VStack(spacing: 12) {
                        if let urlString = item.url, let url = URL(string: urlString) {
                            Button(action: {
                                UIApplication.shared.open(url)
                            }) {
                                HStack {
                                    Image(systemName: "link")
                                    Text("打开原链接")
                                }
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                            }
                        }

                        Button(action: {
                            shareContent()
                        }) {
                            HStack {
                                Image(systemName: "square.and.arrow.up")
                                Text("分享")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color(.systemGray5))
                            .foregroundColor(.primary)
                            .cornerRadius(10)
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .navigationTitle("热榜详情")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                trailing: Button("关闭") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }

    private var detailTimeFormatter: DateFormatter {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm"
        return formatter
    }

    private func shareContent() {
        let shareText = "\(item.title)\n\n\(item.description ?? "")"
        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let window = windowScene.windows.first {
            window.rootViewController?.present(activityVC, animated: true)
        }
    }
}
