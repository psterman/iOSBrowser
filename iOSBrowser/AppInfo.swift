import SwiftUI

struct AppInfo: Identifiable, Codable {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let category: String
    let urlScheme: String
    let isInstalled: Bool
    
    enum CodingKeys: String, CodingKey {
        case id, name, icon, color, category, urlScheme, isInstalled
    }
    
    init(id: String = UUID().uuidString, name: String, icon: String, color: Color, category: String, urlScheme: String) {
        self.id = id
        self.name = name
        self.icon = icon
        self.color = color
        self.category = category
        self.urlScheme = urlScheme
        
        // 检查应用是否已安装
        if let url = URL(string: String(urlScheme.prefix(while: { $0 != ":" })) + "://") {
            self.isInstalled = UIApplication.shared.canOpenURL(url)
        } else {
            self.isInstalled = false
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        category = try container.decode(String.self, forKey: .category)
        urlScheme = try container.decode(String.self, forKey: .urlScheme)
        isInstalled = try container.decode(Bool.self, forKey: .isInstalled)
        
        // 解码颜色
        let colorData = try container.decode(Data.self, forKey: .color)
        if let uiColor = try NSKeyedUnarchiver.unarchivedObject(ofClass: UIColor.self, from: colorData) {
            color = Color(uiColor)
        } else {
            color = .green
        }
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(category, forKey: .category)
        try container.encode(urlScheme, forKey: .urlScheme)
        try container.encode(isInstalled, forKey: .isInstalled)
        
        // 编码颜色
        if let uiColor = UIColor(color) {
            let colorData = try NSKeyedArchiver.archivedData(withRootObject: uiColor, requiringSecureCoding: false)
            try container.encode(colorData, forKey: .color)
        }
    }
    
    // 获取搜索URL
    func getSearchURL(for query: String) -> URL? {
        let trimmedQuery = query.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuery.isEmpty else { return nil }
        
        let encodedQuery = trimmedQuery.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? trimmedQuery
        let searchURL = urlScheme + encodedQuery
        
        return URL(string: searchURL)
    }
} 