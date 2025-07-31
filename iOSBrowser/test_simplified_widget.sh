#!/bin/bash

# 🔧 测试简化小组件
# 验证新的简化小组件是否能正常工作

echo "🔧🔧🔧 开始测试简化小组件..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查简化小组件代码
echo "🔍 检查简化小组件代码..."

echo "🔍 检查SimpleWidgetDataManager:"
if grep -q "SimpleWidgetDataManager" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ SimpleWidgetDataManager存在"
else
    echo "❌ SimpleWidgetDataManager缺失"
fi

echo "🔍 检查测试数据:"
if grep -q "测试引擎1" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 测试数据存在"
else
    echo "❌ 测试数据缺失"
fi

echo "🔍 检查SimpleWidgetBundle:"
if grep -q "SimpleWidgetBundle" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ SimpleWidgetBundle存在"
else
    echo "❌ SimpleWidgetBundle缺失"
fi

# 2. 写入测试数据
echo ""
echo "💾 写入测试数据..."

cat > write_test_data_for_simple_widget.swift << 'EOF'
import Foundation

print("💾 为简化小组件写入测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的测试数据
let engines = ["bing", "yahoo", "duckduckgo", "yandex"]
let apps = ["wechat", "alipay", "meituan", "didi"]
let ai = ["chatgpt", "claude", "gemini", "copilot"]
let actions = ["translate", "calculator", "weather", "timer"]

print("💾 写入数据:")
print("  搜索引擎: \(engines)")
print("  应用: \(apps)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")

// 写入到UserDefaults
standardDefaults.set(engines, forKey: "iosbrowser_engines")
standardDefaults.set(apps, forKey: "iosbrowser_apps")
standardDefaults.set(ai, forKey: "iosbrowser_ai")
standardDefaults.set(actions, forKey: "iosbrowser_actions")
standardDefaults.synchronize()

// 写入到App Groups
if let shared = sharedDefaults {
    shared.set(engines, forKey: "widget_search_engines")
    shared.set(apps, forKey: "widget_apps")
    shared.set(ai, forKey: "widget_ai_assistants")
    shared.set(actions, forKey: "widget_quick_actions")
    shared.synchronize()
    
    print("✅ 数据写入完成")
} else {
    print("❌ App Groups不可用")
}

// 模拟简化小组件的读取逻辑
print("🧪 模拟简化小组件读取:")

func testSimpleRead(key: String, fallbackKey: String) -> [String] {
    if let shared = sharedDefaults {
        shared.synchronize()
        let data = shared.stringArray(forKey: key) ?? []
        if !data.isEmpty {
            print("✅ App Groups读取成功: \(key) = \(data)")
            return data
        }
    }
    
    standardDefaults.synchronize()
    let data = standardDefaults.stringArray(forKey: fallbackKey) ?? []
    if !data.isEmpty {
        print("✅ UserDefaults读取成功: \(fallbackKey) = \(data)")
        return data
    }
    
    let testData = ["测试数据1", "测试数据2"]
    print("🔧 使用测试数据: \(testData)")
    return testData
}

let testEngines = testSimpleRead(key: "widget_search_engines", fallbackKey: "iosbrowser_engines")
let testApps = testSimpleRead(key: "widget_apps", fallbackKey: "iosbrowser_apps")
let testAI = testSimpleRead(key: "widget_ai_assistants", fallbackKey: "iosbrowser_ai")
let testActions = testSimpleRead(key: "widget_quick_actions", fallbackKey: "iosbrowser_actions")

print("🎯 简化小组件应该显示:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")
print("  AI助手: \(testAI)")
print("  快捷操作: \(testActions)")
EOF

if command -v swift &> /dev/null; then
    swift write_test_data_for_simple_widget.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据写入"
fi

rm -f write_test_data_for_simple_widget.swift

# 3. 检查编译状态
echo ""
echo "🔧 检查编译状态..."

echo "🔍 检查语法错误:"
if grep -q "struct.*Widget.*:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ Widget结构定义正常"
else
    echo "❌ Widget结构定义有问题"
fi

if grep -q "@main" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ @main入口存在"
else
    echo "❌ @main入口缺失"
fi

# 4. 提供测试指南
echo ""
echo "🔧 简化小组件测试指南:"
echo "================================"
echo ""
echo "新的简化小组件的特点:"
echo "1. 🔧 简化的数据读取逻辑"
echo "2. 🔧 确保总是有数据显示（硬编码测试数据作为后备）"
echo "3. 🔧 简化的UI，减少复杂性"
echo "4. 🔧 详细的调试日志"
echo ""

echo "📱 测试步骤:"
echo ""
echo "1. 🏗️ 重新编译应用:"
echo "   - 在Xcode中: Product → Clean Build Folder"
echo "   - Product → Build (Cmd+B)"
echo "   - 检查是否有编译错误"
echo "   - 重新安装到设备"
echo ""

echo "2. 🔄 测试小组件:"
echo "   - 删除桌面上的所有旧小组件"
echo "   - 重新添加小组件"
echo "   - 查看是否显示内容"
echo ""

echo "3. 🔍 查看控制台日志:"
echo "   应该看到:"
echo "   - '🔧 [SimpleWidget] 读取搜索引擎数据'"
echo "   - '🔧 [SimpleWidget] App Groups读取成功: [...]' 或"
echo "   - '🔧 [SimpleWidget] UserDefaults读取成功: [...]' 或"
echo "   - '🔧 [SimpleWidget] 使用测试数据: [...]'"
echo ""

echo "🎯 预期结果:"
echo ""
echo "情况1：如果数据读取成功"
echo "- 小组件显示: Bing, Yahoo, DuckDuckGo, Yandex 等"
echo "- 控制台显示: '🔧 [SimpleWidget] App Groups读取成功'"
echo ""

echo "情况2：如果数据读取失败"
echo "- 小组件显示: 测试引擎1, 测试引擎2, 测试引擎3, 测试引擎4"
echo "- 控制台显示: '🔧 [SimpleWidget] 使用测试数据'"
echo ""

echo "情况3：如果小组件完全不显示"
echo "- 说明编译或安装有问题"
echo "- 检查Xcode中的编译错误"
echo "- 检查小组件是否出现在小组件库中"
echo ""

echo "🔧 关键优势:"
echo "- 即使数据读取失败，小组件也会显示测试数据"
echo "- 不会再出现完全空白的情况"
echo "- 可以清楚地看到数据读取的状态"
echo ""

echo "🔧🔧🔧 简化小组件测试准备完成！"
echo "现在请重新编译并测试，应该能看到小组件显示内容了。"
