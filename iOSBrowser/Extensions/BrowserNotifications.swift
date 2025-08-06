import Foundation

extension Notification.Name {
    // 浏览器相关
    static let pasteToBrowserInput = Notification.Name("pasteToBrowserInput")
    static let browseWithClipboard = Notification.Name("browseWithClipboard")
    static let loadUrl = Notification.Name("loadUrl")
    static let startAIConversation = Notification.Name("startAIConversation")
    
    // 搜索相关
    static let switchSearchEngine = Notification.Name("switchSearchEngine")
    static let performSearch = Notification.Name("performSearch")
    static let browserClipboardSearch = Notification.Name("browserClipboardSearch")
    static let smartSearchWithClipboard = Notification.Name("smartSearchWithClipboard")
    static let appSearchWithClipboard = Notification.Name("appSearchWithClipboard")
    static let directAppSearch = Notification.Name("directAppSearch")
    static let loadSearchEngine = Notification.Name("loadSearchEngine")
    static let activateAppSearch = Notification.Name("activateAppSearch")
    
    // AI助手相关
    static let switchToAI = Notification.Name("switchToAI")
    static let sendPrompt = Notification.Name("sendPrompt")
    static let navigateToChat = Notification.Name("navigateToChat")
    static let sendPromptToActiveChat = Notification.Name("sendPromptToActiveChat")
    static let showBatchOperation = Notification.Name("showBatchOperation")
    static let openDirectChat = Notification.Name("openDirectChat")
    static let showAIAssistant = Notification.Name("showAIAssistant")
    
    // 应用相关
    static let searchInApp = Notification.Name("searchInApp")
} 