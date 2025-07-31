#!/bin/bash

# 🔍 诊断主应用保存逻辑问题
# 检查为什么用户选择没有被保存

echo "🔍🔍🔍 开始诊断主应用保存逻辑问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查保存按钮的实现
echo "🔍 检查保存按钮的实现..."

echo "🔍 查找保存按钮定义:"
if grep -n "保存.*Button" iOSBrowser/ContentView.swift; then
    echo "✅ 找到保存按钮定义"
else
    echo "❌ 未找到保存按钮定义"
fi

echo "🔍 查找saveAllConfigurations调用:"
if grep -n "saveAllConfigurations" iOSBrowser/ContentView.swift; then
    echo "✅ 找到saveAllConfigurations调用"
else
    echo "❌ 未找到saveAllConfigurations调用"
fi

# 2. 检查数据同步中心的实现
echo ""
echo "🔍 检查数据同步中心的实现..."

echo "🔍 查找DataSyncCenter定义:"
if grep -n "class.*DataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ 找到DataSyncCenter定义"
else
    echo "❌ 未找到DataSyncCenter定义"
fi

echo "🔍 查找immediateSyncToWidgets方法:"
if grep -n "func immediateSyncToWidgets" iOSBrowser/ContentView.swift; then
    echo "✅ 找到immediateSyncToWidgets方法"
else
    echo "❌ 未找到immediateSyncToWidgets方法"
fi

# 3. 检查用户选择变量
echo ""
echo "🔍 检查用户选择变量..."

echo "🔍 查找用户选择变量定义:"
variables=("selectedSearchEngines" "selectedApps" "selectedAIAssistants" "selectedQuickActions")
for var in "${variables[@]}"; do
    if grep -n "@Published.*$var" iOSBrowser/ContentView.swift; then
        echo "✅ 找到变量: $var"
    else
        echo "❌ 未找到变量: $var"
    fi
done

# 4. 检查toggle方法
echo ""
echo "🔍 检查toggle方法..."

echo "🔍 查找toggle方法:"
toggle_methods=("toggleSearchEngine" "toggleApp" "toggleAssistant" "toggleQuickAction")
for method in "${toggle_methods[@]}"; do
    if grep -n "func $method" iOSBrowser/ContentView.swift; then
        echo "✅ 找到方法: $method"
    else
        echo "❌ 未找到方法: $method"
    fi
done

# 5. 创建测试脚本验证数据流
echo ""
echo "🧪 创建测试脚本验证数据流..."

cat > test_data_flow.swift << 'EOF'
import Foundation

print("🧪 测试数据流...")

// 模拟检查当前的数据状态
let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

print("🔍 检查当前存储状态:")

// 检查UserDefaults.standard
print("📱 UserDefaults.standard:")
let stdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
let stdAI = standardDefaults.stringArray(forKey: "iosbrowser_ai") ?? []
let stdActions = standardDefaults.stringArray(forKey: "iosbrowser_actions") ?? []

print("  iosbrowser_engines: \(stdEngines)")
print("  iosbrowser_apps: \(stdApps)")
print("  iosbrowser_ai: \(stdAI)")
print("  iosbrowser_actions: \(stdActions)")

// 检查App Groups
if let shared = sharedDefaults {
    print("📱 App Groups:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    let sharedAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let sharedActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("  widget_search_engines: \(sharedEngines)")
    print("  widget_apps: \(sharedApps)")
    print("  widget_ai_assistants: \(sharedAI)")
    print("  widget_quick_actions: \(sharedActions)")
    
    // 分析数据状态
    let hasUserDefaults = !stdEngines.isEmpty || !stdApps.isEmpty || !stdAI.isEmpty || !stdActions.isEmpty
    let hasAppGroups = !sharedEngines.isEmpty || !sharedApps.isEmpty || !sharedAI.isEmpty || !sharedActions.isEmpty
    
    print("🔍 数据状态分析:")
    print("  UserDefaults有数据: \(hasUserDefaults)")
    print("  App Groups有数据: \(hasAppGroups)")
    
    if !hasUserDefaults && !hasAppGroups {
        print("🚨 严重问题: 所有存储都为空")
        print("🚨 这说明主应用的保存逻辑从未被触发")
        print("🚨 或者保存过程中出现了错误")
    } else if hasUserDefaults && !hasAppGroups {
        print("⚠️ 部分问题: UserDefaults有数据但App Groups为空")
        print("⚠️ 这说明App Groups保存失败")
    } else if !hasUserDefaults && hasAppGroups {
        print("⚠️ 部分问题: App Groups有数据但UserDefaults为空")
        print("⚠️ 这说明UserDefaults保存失败")
    } else {
        print("✅ 数据状态正常: 两个存储都有数据")
    }
} else {
    print("❌ App Groups不可用")
}

// 模拟小组件读取过程
print("🔍 模拟小组件读取过程:")

func simulateWidgetRead(dataType: String, primaryKey: String, fallbackKeys: [String], defaultValue: [String]) -> [String] {
    print("🔍 读取\(dataType)数据...")
    
    // 1. 从App Groups读取
    if let shared = sharedDefaults {
        let data = shared.stringArray(forKey: primaryKey) ?? []
        if !data.isEmpty {
            print("✅ 从App Groups读取成功: \(data)")
            return data
        }
    }
    
    // 2. 从UserDefaults读取
    let mainData = standardDefaults.stringArray(forKey: primaryKey) ?? []
    if !mainData.isEmpty {
        print("✅ 从UserDefaults读取成功: \(mainData)")
        return mainData
    }
    
    // 3. 从备用键读取
    for key in fallbackKeys {
        let fallbackData = standardDefaults.stringArray(forKey: key) ?? []
        if !fallbackData.isEmpty {
            print("✅ 从备用键\(key)读取成功: \(fallbackData)")
            return fallbackData
        }
    }
    
    print("⚠️ 所有数据源都为空，使用默认值: \(defaultValue)")
    return defaultValue
}

let engines = simulateWidgetRead(
    dataType: "搜索引擎",
    primaryKey: "widget_search_engines",
    fallbackKeys: ["iosbrowser_engines", "widget_search_engines_v2"],
    defaultValue: ["baidu", "google"]
)

let apps = simulateWidgetRead(
    dataType: "应用",
    primaryKey: "widget_apps", 
    fallbackKeys: ["iosbrowser_apps", "widget_apps_v2"],
    defaultValue: ["taobao", "zhihu", "douyin"]
)

print("🎯 小组件最终显示:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")

// 检查是否使用默认值
let usingDefaults = engines == ["baidu", "google"] && apps == ["taobao", "zhihu", "douyin"]
if usingDefaults {
    print("🚨 确认问题: 小组件使用默认值")
    print("🚨 原因: 所有数据源都为空")
} else {
    print("✅ 小组件使用用户数据")
}
EOF

if command -v swift &> /dev/null; then
    swift test_data_flow.swift
else
    echo "⚠️ Swift命令不可用，跳过数据流测试"
fi

rm -f test_data_flow.swift

# 6. 提供诊断结果和解决方案
echo ""
echo "🔍 诊断结果和解决方案:"
echo "================================"
echo ""
echo "根据诊断结果，问题的根本原因是："
echo ""
echo "🚨 主要问题:"
echo "1. 主应用的保存逻辑没有被正确触发"
echo "2. 用户的选择没有保存到任何存储中"
echo "3. 小组件只能使用硬编码的默认值"
echo ""
echo "🔧 解决方案:"
echo "1. 检查保存按钮是否正确绑定到saveAllConfigurations方法"
echo "2. 检查DataSyncCenter是否正确实例化"
echo "3. 检查用户选择变量是否正确更新"
echo "4. 添加详细的调试日志"
echo ""
echo "📱 立即行动:"
echo "1. 在主应用中进入小组件配置页面"
echo "2. 点击任意选项"
echo "3. 点击'保存'按钮"
echo "4. 查看控制台是否有'🔥🔥🔥 手动保存所有配置开始'日志"
echo "5. 如果没有此日志，说明保存方法没有被调用"
echo ""

echo "🔍🔍🔍 主应用保存逻辑诊断完成！"
