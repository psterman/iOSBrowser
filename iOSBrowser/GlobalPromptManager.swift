import Foundation

struct Prompt: Codable {
    let id: String
    let content: String
    let category: String
    let timestamp: Date
}

class GlobalPromptManager: ObservableObject {
    static let shared = GlobalPromptManager()
    
    @Published var currentPrompt: Prompt?
    @Published var recentPrompts: [Prompt] = []
    
    private let maxRecentPrompts = 10
    private let userDefaults = UserDefaults.standard
    private let promptsKey = "recent_prompts"
    
    private init() {
        loadRecentPrompts()
    }
    
    func setCurrentPrompt(_ prompt: Prompt) {
        currentPrompt = prompt
        addToRecentPrompts(prompt)
    }
    
    func clearCurrentPrompt() {
        currentPrompt = nil
    }
    
    private func addToRecentPrompts(_ prompt: Prompt) {
        // 移除重复的提示
        recentPrompts.removeAll { $0.id == prompt.id }
        
        // 添加新提示到开头
        recentPrompts.insert(prompt, at: 0)
        
        // 保持最大数量限制
        if recentPrompts.count > maxRecentPrompts {
            recentPrompts.removeLast()
        }
        
        saveRecentPrompts()
    }
    
    private func loadRecentPrompts() {
        if let data = userDefaults.data(forKey: promptsKey),
           let prompts = try? JSONDecoder().decode([Prompt].self, from: data) {
            recentPrompts = prompts
        }
    }
    
    private func saveRecentPrompts() {
        if let data = try? JSONEncoder().encode(recentPrompts) {
            userDefaults.set(data, forKey: promptsKey)
        }
    }
    
    func clearRecentPrompts() {
        recentPrompts.removeAll()
        saveRecentPrompts()
    }
} 