import SwiftUI

struct AIContact: Identifiable, Codable {
    let id: String
    let name: String
    let description: String
    let model: String
    let avatar: String
    let isOnline: Bool
    let apiEndpoint: String
    let requiresApiKey: Bool
    let supportedFeatures: Set<AIFeature>
    let color: Color
    
    enum AIFeature: String, Codable {
        case textGeneration
        case codeGeneration
        case translation
        case summarization
        case hotTrends
    }
    
    enum CodingKeys: String, CodingKey {
        case id, name, description, model, avatar, isOnline, apiEndpoint, requiresApiKey, supportedFeatures
        case color
    }
    
    init(id: String, name: String, description: String, model: String, avatar: String, isOnline: Bool, apiEndpoint: String, requiresApiKey: Bool, supportedFeatures: Set<AIFeature>, color: Color) {
        self.id = id
        self.name = name
        self.description = description
        self.model = model
        self.avatar = avatar
        self.isOnline = isOnline
        self.apiEndpoint = apiEndpoint
        self.requiresApiKey = requiresApiKey
        self.supportedFeatures = supportedFeatures
        self.color = color
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        description = try container.decode(String.self, forKey: .description)
        model = try container.decode(String.self, forKey: .model)
        avatar = try container.decode(String.self, forKey: .avatar)
        isOnline = try container.decode(Bool.self, forKey: .isOnline)
        apiEndpoint = try container.decode(String.self, forKey: .apiEndpoint)
        requiresApiKey = try container.decode(Bool.self, forKey: .requiresApiKey)
        supportedFeatures = try container.decode(Set<AIFeature>.self, forKey: .supportedFeatures)
        
        // 解码颜色
        let colorData = try container.decode(Data.self, forKey: .color)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .gray
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(description, forKey: .description)
        try container.encode(model, forKey: .model)
        try container.encode(avatar, forKey: .avatar)
        try container.encode(isOnline, forKey: .isOnline)
        try container.encode(apiEndpoint, forKey: .apiEndpoint)
        try container.encode(requiresApiKey, forKey: .requiresApiKey)
        try container.encode(supportedFeatures, forKey: .supportedFeatures)
        
        // 编码颜色
        if let uiColor = UIColor(color) {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            try container.encode(colorData, forKey: .color)
        }
    }
} 