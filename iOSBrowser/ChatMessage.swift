import Foundation

struct ChatMessage: Identifiable, Codable {
    let id: String
    let content: String
    let isFromUser: Bool
    let timestamp: Date
    let status: MessageStatus
    let actions: [MessageAction]
    let isHistorical: Bool
    let aiSource: String?
    let isStreaming: Bool
    let avatar: String?
    let isFavorited: Bool
    let isEdited: Bool
    
    enum MessageStatus: String, Codable {
        case sending
        case sent
        case failed
    }
    
    enum MessageAction: String, Codable {
        case copy
        case edit
        case delete
        case retry
        case favorite
        case share
        case forward
    }
    
    init(id: String = UUID().uuidString,
         content: String,
         isFromUser: Bool,
         timestamp: Date = Date(),
         status: MessageStatus = .sent,
         actions: [MessageAction] = [],
         isHistorical: Bool = false,
         aiSource: String? = nil,
         isStreaming: Bool = false,
         avatar: String? = nil,
         isFavorited: Bool = false,
         isEdited: Bool = false) {
        self.id = id
        self.content = content
        self.isFromUser = isFromUser
        self.timestamp = timestamp
        self.status = status
        self.actions = actions
        self.isHistorical = isHistorical
        self.aiSource = aiSource
        self.isStreaming = isStreaming
        self.avatar = avatar
        self.isFavorited = isFavorited
        self.isEdited = isEdited
    }
} 