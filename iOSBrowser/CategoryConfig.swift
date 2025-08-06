import SwiftUI

struct CategoryConfig: Identifiable, Codable {
    let id = UUID()
    var name: String
    var color: Color
    var icon: String
    var order: Int
    var isCustom: Bool = false
    
    // 颜色编码支持
    enum CodingKeys: String, CodingKey {
        case name, icon, order, isCustom
        case colorRed, colorGreen, colorBlue, colorAlpha
    }
    
    init(name: String, color: Color, icon: String, order: Int, isCustom: Bool = false) {
        self.name = name
        self.color = color
        self.icon = icon
        self.order = order
        self.isCustom = isCustom
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        name = try container.decode(String.self, forKey: .name)
        icon = try container.decode(String.self, forKey: .icon)
        order = try container.decode(Int.self, forKey: .order)
        isCustom = try container.decodeIfPresent(Bool.self, forKey: .isCustom) ?? false
        
        let red = try container.decode(Double.self, forKey: .colorRed)
        let green = try container.decode(Double.self, forKey: .colorGreen)
        let blue = try container.decode(Double.self, forKey: .colorBlue)
        let alpha = try container.decode(Double.self, forKey: .colorAlpha)
        color = Color(.sRGB, red: red, green: green, blue: blue, opacity: alpha)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(name, forKey: .name)
        try container.encode(icon, forKey: .icon)
        try container.encode(order, forKey: .order)
        try container.encode(isCustom, forKey: .isCustom)
        
        // 正确的颜色编码 - 提取实际的RGB值
        let uiColor = UIColor(color)
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        
        uiColor.getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        
        try container.encode(Double(red), forKey: .colorRed)
        try container.encode(Double(green), forKey: .colorGreen)
        try container.encode(Double(blue), forKey: .colorBlue)
        try container.encode(Double(alpha), forKey: .colorAlpha)
    }
} 