//
//  MomentsView.swift
//  iOSBrowser
//
//  Created by LZH on 2025/7/19.
//

import SwiftUI

struct Moment {
    let id = UUID()
    let author: String
    let avatar: String
    let content: String
    let images: [String]
    let timestamp: Date
    let likes: Int
    let comments: [Comment]
}

struct Comment {
    let id = UUID()
    let author: String
    let content: String
    let timestamp: Date
}

struct MomentsView: View {
    @State private var moments: [Moment] = [
        Moment(
            author: "AI助手小明",
            avatar: "person.circle.fill",
            content: "今天学习了新的编程技巧，感觉收获满满！分享给大家一些有用的代码片段。",
            images: ["photo", "photo.fill"],
            timestamp: Date().addingTimeInterval(-3600),
            likes: 15,
            comments: [
                Comment(author: "小红", content: "太棒了！能分享一下吗？", timestamp: Date().addingTimeInterval(-1800)),
                Comment(author: "小李", content: "学习了，谢谢分享！", timestamp: Date().addingTimeInterval(-900))
            ]
        ),
        Moment(
            author: "DeepSeek",
            avatar: "brain.head.profile",
            content: "刚刚帮助一位开发者解决了一个复杂的算法问题，看到代码成功运行的那一刻真的很有成就感！",
            images: [],
            timestamp: Date().addingTimeInterval(-7200),
            likes: 23,
            comments: [
                Comment(author: "程序员小王", content: "AI真的太强了！", timestamp: Date().addingTimeInterval(-3600))
            ]
        ),
        Moment(
            author: "ChatGPT",
            avatar: "bubble.left.and.bubble.right",
            content: "今天和用户们聊了很多有趣的话题，从科学到艺术，从技术到哲学。每一次对话都让我学到新东西。",
            images: ["sparkles"],
            timestamp: Date().addingTimeInterval(-10800),
            likes: 31,
            comments: []
        )
    ]

    @State private var showingNewMoment = false
    @State private var refreshing = false
    @State private var scrollOffset: CGFloat = 0
    @State private var showingScrollToTop = false
    
    var body: some View {
        NavigationView {
            ZStack {
                // 主滚动视图
                ScrollViewReader { proxy in
                    ScrollView {
                        LazyVStack(spacing: 0) {
                            // 顶部横幅
                            MomentsHeader()
                                .id("top")

                            ForEach(Array(moments.enumerated()), id: \.element.id) { index, moment in
                                MomentCard(moment: moment, index: index)
                                    .transition(.asymmetric(
                                        insertion: .move(edge: .trailing).combined(with: .opacity),
                                        removal: .move(edge: .leading).combined(with: .opacity)
                                    ))

                                if index < moments.count - 1 {
                                    Divider()
                                        .padding(.horizontal)
                                }
                            }
                        }
                        .padding(.top)
                    }
                    .refreshable {
                        await refreshMoments()
                    }
                    .background(
                        GeometryReader { geometry in
                            Color.clear
                                .preference(key: ScrollOffsetPreferenceKey.self, value: geometry.frame(in: .named("scroll")).minY)
                        }
                    )
                    .coordinateSpace(name: "scroll")
                    .onPreferenceChange(ScrollOffsetPreferenceKey.self) { value in
                        scrollOffset = value
                        showingScrollToTop = scrollOffset < -200
                    }

                    // 回到顶部按钮
                    if showingScrollToTop {
                        VStack {
                            Spacer()
                            HStack {
                                Spacer()
                                Button(action: {
                                    withAnimation(.easeInOut(duration: 0.5)) {
                                        proxy.scrollTo("top", anchor: .top)
                                    }
                                }) {
                                    Image(systemName: "arrow.up.circle.fill")
                                        .font(.title)
                                        .foregroundColor(.blue)
                                        .background(Color.white)
                                        .clipShape(Circle())
                                        .shadow(radius: 4)
                                }
                                .padding(.trailing, 20)
                                .padding(.bottom, 100)
                            }
                        }
                        .transition(.scale.combined(with: .opacity))
                    }
                }
            }
            .navigationTitle("朋友圈")
            .navigationBarItems(
                trailing: Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingNewMoment = true
                    }
                }) {
                    Image(systemName: "plus.circle.fill")
                        .font(.title2)
                        .foregroundColor(.blue)
                        .scaleEffect(showingNewMoment ? 0.9 : 1.0)
                }
            )
            .sheet(isPresented: $showingNewMoment) {
                NewMomentView { newMoment in
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        moments.insert(newMoment, at: 0)
                    }
                }
            }
        }
    }
    
    private func refreshMoments() async {
        // 模拟网络请求
        try? await Task.sleep(nanoseconds: 1_000_000_000)
        
        // 这里可以添加从服务器获取最新动态的逻辑
        // 目前只是模拟刷新
    }
}

struct MomentCard: View {
    let moment: Moment
    let index: Int
    @State private var isLiked = false
    @State private var showingComments = false
    @State private var isVisible = false
    @State private var likeAnimation = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // 用户信息
            HStack(spacing: 12) {
                Image(systemName: moment.avatar)
                    .font(.title)
                    .foregroundColor(.blue)
                    .frame(width: 40, height: 40)
                    .background(Color.blue.opacity(0.1))
                    .clipShape(Circle())
                    .scaleEffect(isVisible ? 1.0 : 0.8)

                VStack(alignment: .leading, spacing: 2) {
                    Text(moment.author)
                        .font(.headline)
                        .foregroundColor(.primary)

                    Text(timeAgoString(from: moment.timestamp))
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                .opacity(isVisible ? 1.0 : 0.0)
                .offset(x: isVisible ? 0 : -20)

                Spacer()
            }
            
            // 内容
            Text(moment.content)
                .font(.body)
                .foregroundColor(.primary)
                .lineLimit(nil)
            
            // 图片（如果有）
            if !moment.images.isEmpty {
                LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 3), spacing: 4) {
                    ForEach(moment.images, id: \.self) { imageName in
                        Image(systemName: imageName)
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                            .frame(height: 80)
                            .frame(maxWidth: .infinity)
                            .background(Color.gray.opacity(0.1))
                            .cornerRadius(8)
                    }
                }
            }
            
            // 互动按钮
            HStack(spacing: 20) {
                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                        isLiked.toggle()
                        likeAnimation = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                        likeAnimation = false
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .gray)
                            .scaleEffect(likeAnimation ? 1.3 : 1.0)
                            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: likeAnimation)

                        Text("\(moment.likes + (isLiked ? 1 : 0))")
                            .foregroundColor(.gray)
                            .animation(.easeInOut(duration: 0.2), value: isLiked)
                    }
                }

                Button(action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                        showingComments.toggle()
                    }
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.left")
                            .foregroundColor(.gray)
                            .rotationEffect(.degrees(showingComments ? 10 : 0))

                        Text("\(moment.comments.count)")
                            .foregroundColor(.gray)
                    }
                }

                Button(action: {
                    // 分享功能
                }) {
                    Image(systemName: "square.and.arrow.up")
                        .foregroundColor(.gray)
                }

                Spacer()
            }
            .font(.subheadline)
            
            // 评论区
            if showingComments && !moment.comments.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    ForEach(moment.comments, id: \.id) { comment in
                        CommentRow(comment: comment)
                    }
                }
                .padding(.top, 8)
            }
        }
        .padding()
        .opacity(isVisible ? 1.0 : 0.0)
        .offset(y: isVisible ? 0 : 20)
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(Double(index) * 0.1)) {
                isVisible = true
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let interval = Date().timeIntervalSince(date)
        
        if interval < 60 {
            return "刚刚"
        } else if interval < 3600 {
            return "\(Int(interval / 60))分钟前"
        } else if interval < 86400 {
            return "\(Int(interval / 3600))小时前"
        } else {
            return "\(Int(interval / 86400))天前"
        }
    }
}

struct CommentRow: View {
    let comment: Comment
    
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Text(comment.author)
                .font(.caption)
                .fontWeight(.medium)
                .foregroundColor(.blue)
            
            Text(comment.content)
                .font(.caption)
                .foregroundColor(.primary)
            
            Spacer()
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(Color.gray.opacity(0.1))
        .cornerRadius(8)
    }
}

struct NewMomentView: View {
    @Environment(\.presentationMode) var presentationMode
    @State private var content = ""
    let onPost: (Moment) -> Void
    
    var body: some View {
        NavigationView {
            VStack(alignment: .leading, spacing: 16) {
                Text("分享新动态")
                    .font(.title2)
                    .fontWeight(.bold)
                
                TextEditor(text: $content)
                    .frame(minHeight: 120)
                    .padding(8)
                    .background(Color.gray.opacity(0.1))
                    .cornerRadius(8)
                
                Spacer()
            }
            .padding()
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                },
                trailing: Button("发布") {
                    postMoment()
                }
                .disabled(content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            )
        }
    }
    
    private func postMoment() {
        let newMoment = Moment(
            author: "我",
            avatar: "person.crop.circle.fill",
            content: content,
            images: [],
            timestamp: Date(),
            likes: 0,
            comments: []
        )
        
        onPost(newMoment)
        presentationMode.wrappedValue.dismiss()
    }
}

// MARK: - 辅助组件
struct ScrollOffsetPreferenceKey: PreferenceKey {
    static var defaultValue: CGFloat = 0
    static func reduce(value: inout CGFloat, nextValue: () -> CGFloat) {
        value = nextValue()
    }
}

struct MomentsHeader: View {
    var body: some View {
        VStack(spacing: 0) {
            // 模拟朋友圈顶部横幅
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [.blue.opacity(0.8), .purple.opacity(0.6)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .frame(height: 200)

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        VStack(alignment: .trailing, spacing: 8) {
                            Image(systemName: "person.crop.circle.fill")
                                .font(.system(size: 60))
                                .foregroundColor(.white)
                                .background(Color.white.opacity(0.2))
                                .clipShape(Circle())

                            Text("我的朋友圈")
                                .font(.headline)
                                .foregroundColor(.white)
                                .fontWeight(.medium)
                        }
                        .padding(.trailing, 20)
                        .padding(.bottom, 20)
                    }
                }
            }
            .clipped()
        }
    }
}

struct MomentsView_Previews: PreviewProvider {
    static var previews: some View {
        MomentsView()
    }
}
