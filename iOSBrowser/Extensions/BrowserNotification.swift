import Foundation

// MARK: - 通知名称常量
extension NSNotification.Name {
    // 浏览器相关
    static let pasteToBrowserInput = NSNotification.Name("pasteToBrowserInput")
    static let browseWithClipboard = NSNotification.Name("browseWithClipboard")
    static let loadUrl = NSNotification.Name("loadUrl")
    static let startAIConversation = NSNotification.Name("startAIConversation")
    
    // 搜索相关
    static let switchSearchEngine = NSNotification.Name("switchSearchEngine")
    static let performSearch = NSNotification.Name("performSearch")
    static let browserClipboardSearch = NSNotification.Name("browserClipboardSearch")
    static let smartSearchWithClipboard = NSNotification.Name("smartSearchWithClipboard")
    static let appSearchWithClipboard = NSNotification.Name("appSearchWithClipboard")
    static let directAppSearch = NSNotification.Name("directAppSearch")
    static let loadSearchEngine = NSNotification.Name("loadSearchEngine")
    static let activateAppSearch = NSNotification.Name("activateAppSearch")
    
    // AI助手相关
    static let switchToAI = NSNotification.Name("switchToAI")
    static let sendPrompt = NSNotification.Name("sendPrompt")
    static let navigateToChat = NSNotification.Name("navigateToChat")
    static let sendPromptToActiveChat = NSNotification.Name("sendPromptToActiveChat")
    static let showBatchOperation = NSNotification.Name("showBatchOperation")
    static let openDirectChat = NSNotification.Name("openDirectChat")
    static let showAIAssistant = NSNotification.Name("showAIAssistant")
    
    // 应用相关
    static let searchInApp = NSNotification.Name("searchInApp")
} 