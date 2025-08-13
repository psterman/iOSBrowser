// MARK: - 新的聊天状态管理（替代AIChatManager.shared）
class SimpleChatState: ObservableObject {
    @Published var isChatActive = false
    @Published var currentService: String = ""
    
    func startNewChat(with service: String) {
        currentService = service
        isChatActive = true
    }
    
    func closeChat() {
        isChatActive = false
        currentService = ""
    }
}
