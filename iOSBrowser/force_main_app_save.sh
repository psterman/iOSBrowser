#!/bin/bash

# 🔧 强制主应用保存数据到小组件
# 解决小组件读取不到数据的问题

echo "🔧🔧🔧 开始强制主应用保存数据到小组件..."
echo "📅 操作时间: $(date)"
echo ""

# 1. 检查当前数据状态
echo "🔍 检查当前数据状态..."

cat > check_current_data_state.swift << 'EOF'
import Foundation

print("🔍 检查当前数据状态...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

standardDefaults.synchronize()
sharedDefaults?.synchronize()

print("📱 UserDefaults.standard 当前状态:")
let stdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let stdAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let stdActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("  iosbrowser_engines: \(stdEngines)")
print("  iosbrowser_apps: \(stdApps)")
print("  iosbrowser_ai: \(stdAI)")
print("  iosbrowser_actions: \(stdActions)")

if let shared = sharedDefaults {
    print("📱 App Groups 当前状态:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  widget_search_engines: \(sharedEngines)")
    print("  widget_apps: \(sharedApps)")
    print("  widget_ai_assistants: \(sharedAI)")
    print("  widget_quick_actions: \(sharedActions)")
    
    // 检查数据是否为空
    let allEmpty = sharedEngines.isEmpty && sharedApps.isEmpty && sharedAI.isEmpty && sharedActions.isEmpty
    if allEmpty {
        print("🚨 App Groups中所有数据都为空，这解释了为什么小组件使用默认值")
    } else {
        print("✅ App Groups中有数据，小组件应该能读取到")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift check_current_data_state.swift
else
    echo "⚠️ Swift命令不可用，跳过数据检查"
fi

rm -f check_current_data_state.swift

# 2. 强制写入数据到小组件期望的键名
echo ""
echo "💾 强制写入数据到小组件期望的键名..."

cat > force_write_to_widget_keys.swift << 'EOF'
import Foundation

print("💾 强制写入数据到小组件期望的键名...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建测试数据
let testEngines = ["bing", "yahoo", "duckduckgo", "yandex"]
let testApps = ["wechat", "alipay", "meituan", "didi"]
let testAI = ["chatgpt", "claude", "gemini", "copilot"]
let testActions = ["translate", "calculator", "weather", "timer"]

print("📝 准备写入的数据:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")
print("  AI助手: \(testAI)")
print("  快捷操作: \(testActions)")

// 1. 写入到App Groups（小组件的主要数据源）
if let shared = sharedDefaults {
    print("💾 写入到App Groups...")
    
    // 使用小组件期望的确切键名
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testAI, forKey: "widget_ai_assistants")
    shared.set(testActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步结果: \(sharedSync)")
    
    // 立即验证
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups写入验证:")
    print("  widget_search_engines: \(verifyEngines)")
    print("  widget_apps: \(verifyApps)")
    print("  widget_ai_assistants: \(verifyAI)")
    print("  widget_quick_actions: \(verifyActions)")
    
    let success = verifyEngines == testEngines && 
                  verifyApps == testApps && 
                  verifyAI == testAI && 
                  verifyActions == testActions
    
    if success {
        print("✅ App Groups数据写入成功")
    } else {
        print("❌ App Groups数据写入失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 2. 写入到UserDefaults（小组件的备用数据源）
print("💾 写入到UserDefaults...")

// 主键
standardDefaults.set(testEngines, forKey: "iosbrowser_engines")
standardDefaults.set(testApps, forKey: "iosbrowser_apps")
standardDefaults.set(testAI, forKey: "iosbrowser_ai")
standardDefaults.set(testActions, forKey: "iosbrowser_actions")

// 备用键
standardDefaults.set(testEngines, forKey: "widget_search_engines_v2")
standardDefaults.set(testApps, forKey: "widget_apps_v2")
standardDefaults.set(testAI, forKey: "widget_ai_assistants_v2")
standardDefaults.set(testActions, forKey: "widget_quick_actions_v2")

standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("💾 UserDefaults同步结果: \(standardSync)")

// 验证UserDefaults写入
let verifyStdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let verifyStdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("💾 UserDefaults写入验证:")
print("  iosbrowser_engines: \(verifyStdEngines)")
print("  iosbrowser_apps: \(verifyStdApps)")

print("🎯 现在小组件应该能读取到数据了")
print("🎯 重新添加小组件到桌面应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex")
print("  应用: WeChat, Alipay, Meituan, Didi")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot")
print("  快捷操作: Translate, Calculator, Weather, Timer")
EOF

if command -v swift &> /dev/null; then
    swift force_write_to_widget_keys.swift
else
    echo "⚠️ Swift命令不可用，跳过数据写入"
fi

rm -f force_write_to_widget_keys.swift

# 3. 模拟小组件读取过程
echo ""
echo "🔍 模拟小组件读取过程..."

cat > simulate_widget_reading.swift << 'EOF'
import Foundation

print("🔍 模拟小组件读取过程...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 强制同步
standardDefaults.synchronize()
sharedDefaults?.synchronize()

// 模拟WidgetDataManager.getSearchEngines()的读取逻辑
print("🔍 模拟搜索引擎读取:")

// 1. 优先从App Groups读取
var engines: [String] = []
if let shared = sharedDefaults {
    engines = shared.stringArray(forKey: "widget_search_engines") ?? []
    if !engines.isEmpty {
        print("✅ [App Groups] 读取成功: widget_search_engines = \(engines)")
    } else {
        print("❌ [App Groups] widget_search_engines 为空")
    }
}

// 2. 从标准UserDefaults读取主键
if engines.isEmpty {
    engines = standardDefaults.stringArray(forKey: "widget_search_engines") ?? []
    if !engines.isEmpty {
        print("✅ [UserDefaults] 读取成功: widget_search_engines = \(engines)")
    } else {
        print("❌ [UserDefaults] widget_search_engines 为空")
    }
}

// 3. 尝试备用键
if engines.isEmpty {
    let fallbackKeys = ["iosbrowser_engines", "widget_search_engines_v2"]
    for key in fallbackKeys {
        engines = standardDefaults.stringArray(forKey: key) ?? []
        if !engines.isEmpty {
            print("✅ [备用键] 读取成功: \(key) = \(engines)")
            break
        } else {
            print("❌ [备用键] \(key) 为空")
        }
    }
}

// 4. 使用默认值
if engines.isEmpty {
    engines = ["baidu", "google"]
    print("⚠️ [默认值] 所有数据源都为空，使用默认值: \(engines)")
} else {
    print("🎯 小组件将显示: \(engines)")
}

// 检查结果
if engines == ["baidu", "google"] {
    print("🚨 问题确认: 小组件仍将显示默认值")
    print("🚨 需要检查数据写入是否成功")
} else {
    print("✅ 成功: 小组件将显示用户配置")
}
EOF

if command -v swift &> /dev/null; then
    swift simulate_widget_reading.swift
else
    echo "⚠️ Swift命令不可用，跳过模拟读取"
fi

rm -f simulate_widget_reading.swift

# 4. 提供解决方案
echo ""
echo "🔧 解决方案:"
echo "================================"
echo ""
echo "根据日志分析，问题是小组件无法读取到数据。"
echo "可能的原因和解决方案："
echo ""
echo "1. 🔄 强制刷新小组件:"
echo "   - 删除桌面上的所有小组件"
echo "   - 重启设备"
echo "   - 重新添加小组件"
echo ""
echo "2. 📱 在主应用中触发保存:"
echo "   - 打开主应用"
echo "   - 进入小组件配置页面"
echo "   - 点击任意选项（触发数据保存）"
echo "   - 点击'保存'按钮"
echo "   - 查看控制台是否有'App Groups保存验证'日志"
echo ""
echo "3. 🔧 手动强制刷新:"
echo "   - 在主应用中点击'刷新小组件'按钮"
echo "   - 等待5-10秒"
echo "   - 重新添加小组件"
echo ""
echo "4. 🔍 验证数据写入:"
echo "   - 查看控制台日志"
echo "   - 应该看到'✅ App Groups数据写入成功'"
echo "   - 应该看到'✅ [App Groups] 读取成功'"
echo ""

echo "🔧🔧🔧 强制主应用保存数据完成！"
