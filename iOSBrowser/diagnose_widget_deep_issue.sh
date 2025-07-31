#!/bin/bash

# 🚨 深度诊断小组件问题
# 彻底分析为什么小组件仍显示默认数据

echo "🚨🚨🚨 开始深度诊断小组件问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查App Groups权限和配置
echo "🔐 检查App Groups权限和配置..."

echo "🔍 检查主应用App Groups使用:"
if grep -q "group.com.iosbrowser.shared" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用使用App Groups"
    grep -n "group.com.iosbrowser.shared" iOSBrowser/ContentView.swift | head -3
else
    echo "❌ 主应用未使用App Groups"
fi

echo "🔍 检查小组件App Groups使用:"
if grep -q "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件使用App Groups"
    grep -n "group.com.iosbrowser.shared" iOSBrowserWidgets/iOSBrowserWidgets.swift | head -3
else
    echo "❌ 小组件未使用App Groups"
fi

# 2. 测试App Groups实际可用性
echo ""
echo "🧪 测试App Groups实际可用性..."

cat > test_app_groups_access.swift << 'EOF'
import Foundation

print("🧪 测试App Groups实际可用性...")

let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    print("✅ App Groups UserDefaults创建成功")
    
    // 测试写入
    let testKey = "test_access_\(Date().timeIntervalSince1970)"
    let testValue = "test_value"
    
    shared.set(testValue, forKey: testKey)
    let syncResult = shared.synchronize()
    print("📝 测试写入同步结果: \(syncResult)")
    
    // 测试读取
    let readValue = shared.string(forKey: testKey) ?? ""
    if readValue == testValue {
        print("✅ App Groups读写测试成功")
    } else {
        print("❌ App Groups读写测试失败")
        print("   写入: \(testValue)")
        print("   读取: \(readValue)")
    }
    
    // 清理测试数据
    shared.removeObject(forKey: testKey)
    shared.synchronize()
    
} else {
    print("❌ App Groups UserDefaults创建失败")
    print("❌ 这可能是权限问题或配置问题")
}
EOF

if command -v swift &> /dev/null; then
    swift test_app_groups_access.swift
else
    echo "⚠️ Swift命令不可用，跳过App Groups测试"
fi

rm -f test_app_groups_access.swift

# 3. 强制写入数据并立即验证
echo ""
echo "💾 强制写入数据并立即验证..."

cat > force_write_and_verify.swift << 'EOF'
import Foundation

print("💾 强制写入数据并立即验证...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 使用时间戳确保数据是新的
let timestamp = Int(Date().timeIntervalSince1970)
let testEngines = ["bing_\(timestamp)", "yahoo_\(timestamp)", "test_\(timestamp)"]
let testApps = ["wechat_\(timestamp)", "test_app_\(timestamp)"]

print("📝 写入带时间戳的测试数据:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")

// 1. 写入到所有可能的位置
print("💾 写入到所有可能的位置...")

// UserDefaults.standard
standardDefaults.set(testEngines, forKey: "iosbrowser_engines")
standardDefaults.set(testEngines, forKey: "widget_search_engines")
standardDefaults.set(testEngines, forKey: "widget_search_engines_v2")

standardDefaults.set(testApps, forKey: "iosbrowser_apps")
standardDefaults.set(testApps, forKey: "widget_apps")
standardDefaults.set(testApps, forKey: "widget_apps_v2")

let stdSync = standardDefaults.synchronize()
print("💾 UserDefaults同步: \(stdSync)")

// App Groups
if let shared = sharedDefaults {
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testEngines, forKey: "widget_ai_assistants")  // 复用测试
    shared.set(testApps, forKey: "widget_quick_actions")     // 复用测试
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步: \(sharedSync)")
}

// 2. 立即验证所有位置的数据
print("🔍 立即验证所有位置的数据...")

print("📱 UserDefaults验证:")
let stdEngines = standardDefaults.stringArray(forKey: "iosbrowser_engines") ?? []
let stdApps = standardDefaults.stringArray(forKey: "iosbrowser_apps") ?? []
print("  iosbrowser_engines: \(stdEngines)")
print("  iosbrowser_apps: \(stdApps)")

if let shared = sharedDefaults {
    print("📱 App Groups验证:")
    let sharedEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let sharedApps = shared.stringArray(forKey: "widget_apps") ?? []
    print("  widget_search_engines: \(sharedEngines)")
    print("  widget_apps: \(sharedApps)")
    
    // 检查数据一致性
    if sharedEngines == testEngines && sharedApps == testApps {
        print("✅ App Groups数据一致性验证成功")
    } else {
        print("❌ App Groups数据一致性验证失败")
    }
}

// 3. 模拟小组件读取（完全按照小组件代码逻辑）
print("🔍 模拟小组件读取（完全按照小组件代码逻辑）...")

func simulateWidgetRead() -> [String] {
    print("🔍 [WidgetDataManager] 读取数据: widget_search_engines")
    
    // 强制同步
    standardDefaults.synchronize()
    sharedDefaults?.synchronize()
    
    // 1. 优先从App Groups读取
    if let shared = sharedDefaults {
        let data = shared.stringArray(forKey: "widget_search_engines") ?? []
        if !data.isEmpty {
            print("✅ [App Groups] 读取成功: widget_search_engines = \(data)")
            return data
        } else {
            print("❌ [App Groups] widget_search_engines 为空")
        }
    } else {
        print("❌ [App Groups] UserDefaults创建失败")
    }
    
    // 2. 从标准UserDefaults读取主键
    let mainData = standardDefaults.stringArray(forKey: "widget_search_engines") ?? []
    if !mainData.isEmpty {
        print("✅ [UserDefaults] 读取成功: widget_search_engines = \(mainData)")
        return mainData
    } else {
        print("❌ [UserDefaults] widget_search_engines 为空")
    }
    
    // 3. 尝试备用键
    let fallbackKeys = ["iosbrowser_engines", "widget_search_engines_v2"]
    for key in fallbackKeys {
        let fallbackData = standardDefaults.stringArray(forKey: key) ?? []
        if !fallbackData.isEmpty {
            print("✅ [备用键] 读取成功: \(key) = \(fallbackData)")
            return fallbackData
        } else {
            print("❌ [备用键] \(key) 为空")
        }
    }
    
    print("⚠️ [默认值] 所有数据源都为空，使用默认值: [\"baidu\", \"google\"]")
    return ["baidu", "google"]
}

let result = simulateWidgetRead()
print("🎯 小组件模拟读取结果: \(result)")

if result.contains("baidu") || result.contains("google") {
    print("🚨 问题确认: 小组件仍将显示默认值")
    print("🚨 这说明数据读取链路有问题")
} else {
    print("✅ 成功: 小组件应该显示自定义数据")
}
EOF

if command -v swift &> /dev/null; then
    swift force_write_and_verify.swift
else
    echo "⚠️ Swift命令不可用，跳过强制写入验证"
fi

rm -f force_write_and_verify.swift

# 4. 检查小组件代码是否真的在运行
echo ""
echo "🔍 检查小组件代码是否真的在运行..."

echo "🔍 检查小组件日志特征:"
echo "如果您在控制台看到以下日志，说明新代码正在运行:"
echo "- '[WidgetDataManager] 读取数据'"
echo "- '[SearchEngineProvider] getTimeline 被调用'"
echo "- '[App Groups] 读取成功' 或 '[默认值] 所有数据源都为空'"
echo ""
echo "如果没有看到这些日志，说明:"
echo "1. 小组件扩展没有被重新编译"
echo "2. 系统仍在使用旧的小组件代码"
echo "3. 需要更彻底的清理和重新安装"

# 5. 提供彻底的解决方案
echo ""
echo "🔧 彻底的解决方案:"
echo "================================"
echo ""
echo "基于诊断结果，建议按以下步骤操作:"
echo ""
echo "1. 🧹 彻底清理项目:"
echo "   - 在Xcode中: Product → Clean Build Folder"
echo "   - 删除 ~/Library/Developer/Xcode/DerivedData 中的项目文件夹"
echo "   - 关闭Xcode"
echo ""
echo "2. 📱 完全重新安装:"
echo "   - 从设备上完全删除应用"
echo "   - 重启设备"
echo "   - 重新打开Xcode"
echo "   - 重新编译并安装应用"
echo ""
echo "3. 🔐 检查App Groups配置:"
echo "   - 在Xcode中检查主应用的App Groups权限"
echo "   - 检查小组件扩展的App Groups权限"
echo "   - 确保两者都包含 'group.com.iosbrowser.shared'"
echo ""
echo "4. 📊 验证数据流:"
echo "   - 运行应用后查看控制台"
echo "   - 应该看到 '[WidgetDataManager] 读取数据' 日志"
echo "   - 如果看到 '[默认值] 所有数据源都为空'，说明数据读取失败"
echo ""
echo "5. 🔄 强制刷新:"
echo "   - 在主应用中进入小组件配置"
echo "   - 点击任意选项"
echo "   - 点击'保存'按钮"
echo "   - 点击'刷新小组件'按钮"
echo "   - 删除并重新添加桌面小组件"
echo ""

echo "🚨🚨🚨 深度诊断小组件问题完成！"
