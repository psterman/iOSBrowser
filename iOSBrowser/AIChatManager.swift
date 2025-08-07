//
//  AIChatManager.swift
//  iOSBrowser
//
//  AI对话管理器 - 管理AI对话和历史记录
//

import SwiftUI
import Foundation

// MARK: - AI对话消息
struct AIChatMessage: Identifiable, Codable {
    let id = UUID()
    let content: String
    let isUser: Bool
    let timestamp: Date
    let aiService: String
}

// MARK: - AI对话会话
struct AIChatSession: Identifiable, Codable {
    let id = UUID()
    let aiService: String
    let title: String
    let messages: [AIChatMessage]
    let createdAt: Date
    let lastUpdated: Date
}

// MARK: - AI对话管理器
class AIChatManager: ObservableObject {
    static let shared = AIChatManager()
    
    @Published var currentSession: AIChatSession?
    @Published var chatSessions: [AIChatSession] = []
    @Published var isChatActive = false
    
    private let userDefaults = UserDefaults.standard
    private let chatSessionsKey = "AIChatSessions"
    
    init() {
        loadChatSessions()
    }
    
    // MARK: - 会话管理
    
    func startNewChat(with aiService: AIService) {
        let newSession = AIChatSession(
            aiService: aiService.id,
            title: "与 \(aiService.name) 的对话",
            messages: [],
            createdAt: Date(),
            lastUpdated: Date()
        )
        
        currentSession = newSession
        isChatActive = true
        
        // 添加到会话列表
        chatSessions.insert(newSession, at: 0)
        saveChatSessions()
    }
    
    func continueChat(session: AIChatSession) {
        currentSession = session
        isChatActive = true
    }
    
    func closeChat() {
        isChatActive = false
        currentSession = nil
    }
    
    // MARK: - 消息管理
    
    func sendMessage(_ content: String) {
        guard let session = currentSession, !content.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        let userMessage = AIChatMessage(
            content: content,
            isUser: true,
            timestamp: Date(),
            aiService: session.aiService
        )
        
        // 添加用户消息
        var updatedMessages = session.messages
        updatedMessages.append(userMessage)
        
        // 创建AI回复（模拟）
        let aiReply = AIChatMessage(
            content: generateAIResponse(for: content, aiService: session.aiService),
            isUser: false,
            timestamp: Date(),
            aiService: session.aiService
        )
        
        updatedMessages.append(aiReply)
        
        // 更新会话
        let updatedSession = AIChatSession(
            id: session.id,
            aiService: session.aiService,
            title: session.title,
            messages: updatedMessages,
            createdAt: session.createdAt,
            lastUpdated: Date()
        )
        
        currentSession = updatedSession
        
        // 更新会话列表
        if let index = chatSessions.firstIndex(where: { $0.id == session.id }) {
            chatSessions[index] = updatedSession
        }
        
        saveChatSessions()
    }
    
    func deleteSession(_ session: AIChatSession) {
        chatSessions.removeAll { $0.id == session.id }
        saveChatSessions()
    }
    
    // MARK: - 数据持久化
    
    private func saveChatSessions() {
        if let data = try? JSONEncoder().encode(chatSessions) {
            userDefaults.set(data, forKey: chatSessionsKey)
        }
    }
    
    private func loadChatSessions() {
        if let data = userDefaults.data(forKey: chatSessionsKey),
           let sessions = try? JSONDecoder().decode([AIChatSession].self, from: data) {
            chatSessions = sessions
        }
    }
    
    // MARK: - AI响应生成（模拟）
    
    private func generateAIResponse(for message: String, aiService: String) -> String {
        // 这里应该调用真实的AI API
        // 目前使用模拟响应
        let responses = [
            "我理解您的问题。让我为您提供详细的解答...",
            "这是一个很好的问题。根据我的分析...",
            "我可以帮您解决这个问题。建议您...",
            "基于您提供的信息，我认为...",
            "让我为您分析一下这个情况..."
        ]
        
        let randomResponse = responses.randomElement() ?? "我收到了您的消息，正在处理中..."
        
        // 根据AI服务添加特定前缀
        switch aiService {
        case "deepseek":
            return "🤖 DeepSeek: \(randomResponse)"
        case "kimi":
            return "🌙 Kimi: \(randomResponse)"
        case "doubao":
            return "💬 豆包: \(randomResponse)"
        case "wenxin":
            return "📄 文心一言: \(randomResponse)"
        case "yuanbao":
            return "💎 元宝: \(randomResponse)"
        case "chatglm":
            return "💡 智谱清言: \(randomResponse)"
        case "tongyi":
            return "☁️ 通义千问: \(randomResponse)"
        case "claude":
            return "✨ Claude: \(randomResponse)"
        case "chatgpt":
            return "🧠 ChatGPT: \(randomResponse)"
        default:
            return "🤖 AI助手: \(randomResponse)"
        }
    }
    
    // MARK: - 会话统计
    
    func getSessionCount(for aiService: String) -> Int {
        return chatSessions.filter { $0.aiService == aiService }.count
    }
    
    func getRecentSessions(for aiService: String, limit: Int = 5) -> [AIChatSession] {
        return chatSessions
            .filter { $0.aiService == aiService }
            .sorted { $0.lastUpdated > $1.lastUpdated }
            .prefix(limit)
            .map { $0 }
    }
} 