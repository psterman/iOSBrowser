import Foundation

// MARK: - 通知名称常量
extension Notification.Name {
    // 浏览器相关
    static let pasteToBrowserInput = Notification.Name("com.iosbrowser.notification.pasteToBrowserInput")
    static let browseWithClipboard = Notification.Name("com.iosbrowser.notification.browseWithClipboard")
    static let loadUrl = Notification.Name("com.iosbrowser.notification.loadUrl")
    static let startAIConversation = Notification.Name("com.iosbrowser.notification.startAIConversation")
    
    // 搜索相关
    static let switchSearchEngine = Notification.Name("com.iosbrowser.notification.switchSearchEngine")
    static let performSearch = Notification.Name("com.iosbrowser.notification.performSearch")
    static let browserClipboardSearch = Notification.Name("com.iosbrowser.notification.browserClipboardSearch")
    static let smartSearchWithClipboard = Notification.Name("com.iosbrowser.notification.smartSearchWithClipboard")
    static let appSearchWithClipboard = Notification.Name("com.iosbrowser.notification.appSearchWithClipboard")
    static let directAppSearch = Notification.Name("com.iosbrowser.notification.directAppSearch")
    static let loadSearchEngine = Notification.Name("com.iosbrowser.notification.loadSearchEngine")
    static let activateAppSearch = Notification.Name("com.iosbrowser.notification.activateAppSearch")
    
    // AI助手相关
    static let switchToAI = Notification.Name("com.iosbrowser.notification.switchToAI")
    static let sendPrompt = Notification.Name("com.iosbrowser.notification.sendPrompt")
    static let navigateToChat = Notification.Name("com.iosbrowser.notification.navigateToChat")
    static let sendPromptToActiveChat = Notification.Name("com.iosbrowser.notification.sendPromptToActiveChat")
    static let showBatchOperation = Notification.Name("com.iosbrowser.notification.showBatchOperation")
    static let openDirectChat = Notification.Name("com.iosbrowser.notification.openDirectChat")
    static let showAIAssistant = Notification.Name("com.iosbrowser.notification.showAIAssistant")
    
    // 应用相关
    static let searchInApp = Notification.Name("com.iosbrowser.notification.searchInApp")
} 