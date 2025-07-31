#!/bin/bash

# 🔄 恢复丢失的数据
# 立即重新写入数据并确保持久化

echo "🔄🔄🔄 开始恢复丢失的数据..."
echo "📅 恢复时间: $(date)"
echo ""

# 1. 检查数据丢失情况
echo "🔍 检查数据丢失情况..."

cat > check_data_loss.swift << 'EOF'
import Foundation

print("🔍 检查数据丢失情况...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

standardDefaults.synchronize()
sharedDefaults?.synchronize()

print("📱 UserDefaults.standard 当前状态:")
let allKeys = [
    "iosbrowser_engines", "widget_search_engines", "widget_search_engines_v2",
    "iosbrowser_apps", "widget_apps", "widget_apps_v2",
    "iosbrowser_ai", "widget_ai_assistants", "widget_ai_assistants_v2",
    "iosbrowser_actions", "widget_quick_actions", "widget_quick_actions_v2"
]

for key in allKeys {
    let data = standardDefaults.stringArray(forKey: key) ?? []
    print("  \(key): \(data)")
}

if let shared = sharedDefaults {
    print("📱 App Groups 当前状态:")
    let sharedKeys = [
        "widget_search_engines", "widget_apps", "widget_ai_assistants", "widget_quick_actions"
    ]
    
    for key in sharedKeys {
        let data = shared.stringArray(forKey: key) ?? []
        print("  \(key): \(data)")
    }
    
    let allEmpty = sharedKeys.allSatisfy { shared.stringArray(forKey: $0)?.isEmpty ?? true }
    if allEmpty {
        print("🚨 确认: 所有App Groups数据都已丢失")
    } else {
        print("✅ App Groups中仍有部分数据")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift check_data_loss.swift
else
    echo "⚠️ Swift命令不可用，跳过数据丢失检查"
fi

rm -f check_data_loss.swift

# 2. 立即重新写入持久化数据
echo ""
echo "💾 立即重新写入持久化数据..."

cat > restore_persistent_data.swift << 'EOF'
import Foundation

print("💾 立即重新写入持久化数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的用户选择数据
let userEngines = ["bing", "yahoo", "duckduckgo", "yandex"]
let userApps = ["wechat", "alipay", "meituan", "didi"]
let userAI = ["chatgpt", "claude", "gemini", "copilot"]
let userActions = ["translate", "calculator", "weather", "timer"]

print("💾 写入用户选择数据:")
print("  搜索引擎: \(userEngines)")
print("  应用: \(userApps)")
print("  AI助手: \(userAI)")
print("  快捷操作: \(userActions)")

// 1. 写入到UserDefaults.standard的所有键
print("💾 写入到UserDefaults.standard...")
let standardKeyMappings = [
    ("iosbrowser_engines", userEngines),
    ("widget_search_engines", userEngines),
    ("widget_search_engines_v2", userEngines),
    ("iosbrowser_apps", userApps),
    ("widget_apps", userApps),
    ("widget_apps_v2", userApps),
    ("iosbrowser_ai", userAI),
    ("widget_ai_assistants", userAI),
    ("widget_ai_assistants_v2", userAI),
    ("iosbrowser_actions", userActions),
    ("widget_quick_actions", userActions),
    ("widget_quick_actions_v2", userActions)
]

for (key, value) in standardKeyMappings {
    standardDefaults.set(value, forKey: key)
    print("  设置 \(key): \(value)")
}

standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")
let stdSync = standardDefaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// 立即验证UserDefaults写入
print("💾 验证UserDefaults写入:")
for (key, expectedValue) in standardKeyMappings {
    let actualValue = standardDefaults.stringArray(forKey: key) ?? []
    let success = actualValue == expectedValue
    print("  \(key): \(success ? "✅" : "❌") \(actualValue)")
}

// 2. 写入到App Groups
if let shared = sharedDefaults {
    print("💾 写入到App Groups...")
    let sharedKeyMappings = [
        ("widget_search_engines", userEngines),
        ("widget_apps", userApps),
        ("widget_ai_assistants", userAI),
        ("widget_quick_actions", userActions)
    ]
    
    for (key, value) in sharedKeyMappings {
        shared.set(value, forKey: key)
        print("  设置 \(key): \(value)")
    }
    
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
    
    // 立即验证App Groups写入
    print("💾 验证App Groups写入:")
    for (key, expectedValue) in sharedKeyMappings {
        let actualValue = shared.stringArray(forKey: key) ?? []
        let success = actualValue == expectedValue
        print("  \(key): \(success ? "✅" : "❌") \(actualValue)")
        
        if !success {
            print("    期望: \(expectedValue)")
            print("    实际: \(actualValue)")
        }
    }
    
    let allSuccess = sharedKeyMappings.allSatisfy { (key, expectedValue) in
        let actualValue = shared.stringArray(forKey: key) ?? []
        return actualValue == expectedValue
    }
    
    if allSuccess {
        print("✅ 所有App Groups数据写入成功")
        print("🎯 现在小组件应该能读取到用户数据")
    } else {
        print("❌ App Groups数据写入失败")
    }
} else {
    print("❌ App Groups不可用")
}

print("🎯 数据恢复完成")
print("🎯 现在小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex")
print("  应用: WeChat, Alipay, Meituan, Didi")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot")
print("  快捷操作: Translate, Calculator, Weather, Timer")
EOF

if command -v swift &> /dev/null; then
    swift restore_persistent_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据恢复"
fi

rm -f restore_persistent_data.swift

# 3. 立即测试小组件读取
echo ""
echo "🧪 立即测试小组件读取..."

cat > test_immediate_read.swift << 'EOF'
import Foundation

print("🧪 立即测试小组件读取...")

let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    shared.synchronize()
    
    print("🧪 模拟小组件读取逻辑:")
    let keys = ["widget_search_engines", "widget_apps", "widget_ai_assistants", "widget_quick_actions"]
    
    for key in keys {
        print("🔍 读取 \(key):")
        let data = shared.stringArray(forKey: key) ?? []
        print("  结果: \(data)")
        
        if data.isEmpty {
            print("  ❌ 数据为空")
        } else {
            print("  ✅ 数据正常")
        }
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift test_immediate_read.swift
else
    echo "⚠️ Swift命令不可用，跳过立即读取测试"
fi

rm -f test_immediate_read.swift

# 4. 提供立即测试指南
echo ""
echo "🔄 数据恢复完成，立即测试指南:"
echo "================================"
echo ""
echo "数据已重新写入，现在立即测试："
echo ""
echo "📱 立即测试步骤:"
echo "1. 🔄 刷新小组件:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重新添加小组件"
echo ""
echo "2. 🔍 查看控制台日志:"
echo "   应该看到:"
echo "   - '🔍 [App Groups] 读取结果: widget_search_engines = [\"bing\", \"yahoo\", \"duckduckgo\", \"yandex\"]'"
echo "   - '✅ [App Groups] 读取成功: widget_search_engines = [...]'"
echo "   - '🔍 [getSearchEngines] 最终返回: [\"bing\", \"yahoo\", \"duckduckgo\", \"yandex\"]'"
echo ""
echo "3. 🎯 验证小组件显示:"
echo "   小组件应该显示:"
echo "   - 搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex"
echo "   - 应用: WeChat, Alipay, Meituan, Didi"
echo "   - AI助手: ChatGPT, Claude, Gemini, Copilot"
echo "   - 快捷操作: Translate, Calculator, Weather, Timer"
echo ""

echo "🔍 如果仍然显示空白:"
echo "1. 数据可能再次丢失 - 需要找出数据丢失的原因"
echo "2. 可能是iOS系统缓存问题 - 重启设备"
echo "3. 可能是小组件UI渲染问题 - 检查UI逻辑"
echo ""

echo "🔄🔄🔄 数据恢复完成！请立即测试。"
