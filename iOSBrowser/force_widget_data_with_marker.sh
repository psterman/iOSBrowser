#!/bin/bash

# 🔧 强制写入带标识的小组件数据
# 确保小组件能读取到明确的非默认数据

echo "🔧🔧🔧 开始强制写入带标识的小组件数据..."
echo "📅 操作时间: $(date)"
echo ""

# 创建带特殊标识的测试数据
cat > force_write_marked_data.swift << 'EOF'
import Foundation

print("🔧 强制写入带特殊标识的测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确不同于默认值的测试数据，包含特殊标识
let testEngines = ["bing", "yahoo", "duckduckgo", "yandex"]  // 4个引擎，明显不同于默认的2个
let testApps = ["wechat", "alipay", "meituan", "didi"]       // 4个应用，明显不同于默认的3个
let testAI = ["chatgpt", "claude", "gemini", "copilot"]      // 4个AI，明显不同于默认的2个
let testActions = ["translate", "calculator", "weather", "timer"]  // 4个操作，明显不同于默认的2个

print("📝 准备写入带标识的测试数据:")
print("  搜索引擎: \(testEngines) (数量: \(testEngines.count))")
print("  应用: \(testApps) (数量: \(testApps.count))")
print("  AI助手: \(testAI) (数量: \(testAI.count))")
print("  快捷操作: \(testActions) (数量: \(testActions.count))")

// 清除所有可能的旧数据
print("🧹 清除所有可能的旧数据...")
let allKeys = [
    "iosbrowser_engines", "widget_search_engines", "widget_search_engines_v2", "widget_search_engines_v3",
    "iosbrowser_apps", "widget_apps", "widget_apps_v2", "widget_apps_v3",
    "iosbrowser_ai", "widget_ai_assistants", "widget_ai_assistants_v2",
    "iosbrowser_actions", "widget_quick_actions", "widget_quick_actions_v2"
]

for key in allKeys {
    standardDefaults.removeObject(forKey: key)
}

if let shared = sharedDefaults {
    let sharedKeys = ["widget_search_engines", "widget_apps", "widget_ai_assistants", "widget_quick_actions"]
    for key in sharedKeys {
        shared.removeObject(forKey: key)
    }
}

print("🧹 旧数据清除完成")

// 保存到UserDefaults.standard的所有相关键
print("💾 保存到UserDefaults.standard...")
standardDefaults.set(testEngines, forKey: "iosbrowser_engines")
standardDefaults.set(testEngines, forKey: "widget_search_engines_v2")
standardDefaults.set(testEngines, forKey: "widget_search_engines_v3")

standardDefaults.set(testApps, forKey: "iosbrowser_apps")
standardDefaults.set(testApps, forKey: "widget_apps_v2")
standardDefaults.set(testApps, forKey: "widget_apps_v3")

standardDefaults.set(testAI, forKey: "iosbrowser_ai")
standardDefaults.set(testAI, forKey: "widget_ai_assistants_v2")

standardDefaults.set(testActions, forKey: "iosbrowser_actions")
standardDefaults.set(testActions, forKey: "widget_quick_actions_v2")

// 添加特殊标识
standardDefaults.set("2025-07-31-v3", forKey: "widget_data_version")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("💾 UserDefaults.standard同步结果: \(standardSync)")

// 保存到App Groups的所有相关键
if let shared = sharedDefaults {
    print("💾 保存到App Groups...")
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testAI, forKey: "widget_ai_assistants")
    shared.set(testActions, forKey: "widget_quick_actions")
    
    // 添加特殊标识
    shared.set("2025-07-31-v3", forKey: "widget_data_version")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步结果: \(sharedSync)")
    
    // 立即验证App Groups保存
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    let sharedVersion = shared.string(forKey: "widget_data_version") ?? ""
    
    print("💾 App Groups保存验证:")
    print("  搜索引擎: \(sharedEngines)")
    print("  应用: \(sharedApps)")
    print("  AI助手: \(sharedAI)")
    print("  快捷操作: \(sharedActions)")
    print("  数据版本: \(sharedVersion)")
    
    let allSuccess = sharedEngines == testEngines && 
                     sharedApps == testApps && 
                     sharedAI == testAI && 
                     sharedActions == testActions &&
                     sharedVersion == "2025-07-31-v3"
    
    if allSuccess {
        print("✅ 所有数据App Groups保存成功，包含版本标识")
    } else {
        print("❌ 部分数据App Groups保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 验证UserDefaults.standard保存
let verifyEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let verifyApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let verifyAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let verifyActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []
let verifyVersion = standardDefaults.string(forKey: "widget_data_version") ?? ""

print("💾 UserDefaults.standard保存验证:")
print("  搜索引擎: \(verifyEngines)")
print("  应用: \(verifyApps)")
print("  AI助手: \(verifyAI)")
print("  快捷操作: \(verifyActions)")
print("  数据版本: \(verifyVersion)")

let standardSuccess = verifyEngines == testEngines && 
                      verifyApps == testApps && 
                      verifyAI == testAI && 
                      verifyActions == testActions &&
                      verifyVersion == "2025-07-31-v3"

if standardSuccess {
    print("✅ 所有数据UserDefaults.standard保存成功，包含版本标识")
} else {
    print("❌ 部分数据UserDefaults.standard保存失败")
}

print("🎯 现在小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex (4个)")
print("  应用: WeChat, Alipay, Meituan, Didi (4个)")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot (4个)")
print("  快捷操作: Translate, Calculator, Weather, Timer (4个)")
print("")
print("🎯 而不是默认值:")
print("  搜索引擎: 百度, 谷歌 (2个)")
print("  应用: 淘宝, 知乎, 抖音 (3个)")
print("  AI助手: DeepSeek, 通义千问 (2个)")
print("  快捷操作: Search, Bookmark (2个)")
print("")
print("🔍 关键区别:")
print("- 数量不同：新数据都是4个项目，默认值是2-3个")
print("- 内容不同：完全不同的选项")
print("- 版本标识：2025-07-31-v3")
EOF

if command -v swift &> /dev/null; then
    swift force_write_marked_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据写入"
fi

rm -f force_write_marked_data.swift

echo ""
echo "🔧 下一步操作指南:"
echo "================================"
echo ""
echo "1. 🏗️ 重新编译项目:"
echo "   - 在Xcode中: Product → Clean Build Folder (Cmd+Shift+K)"
echo "   - 然后: Product → Build (Cmd+B)"
echo "   - 确保没有编译错误"
echo ""
echo "2. 📱 重新安装应用:"
echo "   - 从设备删除应用"
echo "   - 从Xcode重新安装"
echo ""
echo "3. 🔍 查看控制台日志:"
echo "   应该看到以下新版本标识:"
echo "   - '🔥🔥🔥 小组件开始多源搜索引擎数据读取... [版本2025-07-31-v3]'"
echo "   - '🔄🔄🔄 UserSearchProvider.getTimeline 被调用 [版本2025-07-31-v3]'"
echo ""
echo "4. 🧹 清除小组件缓存:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重启设备"
echo "   - 重新添加小组件"
echo ""
echo "5. ✅ 验证结果:"
echo "   小组件应该显示4个项目而不是2-3个默认项目"
echo "   如果仍显示默认值，查看日志中的🚨🚨🚨警告信息"
echo ""

echo "🔧🔧🔧 强制写入带标识的小组件数据完成！"
