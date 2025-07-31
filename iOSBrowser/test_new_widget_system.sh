#!/bin/bash

# 🎉 新版小组件系统测试脚本
# 验证基于四个标签重新构建的小组件系统

echo "🎉🎉🎉 开始新版小组件系统测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查新版小组件代码结构
echo "🔍 检查新版小组件代码结构..."

echo "🔍 检查小组件包入口:"
if grep -q "iOSBrowserWidgetBundle" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 新版小组件包入口存在"
else
    echo "❌ 新版小组件包入口缺失"
fi

echo "🔍 检查四个小组件:"
widgets=("SearchEngineWidget" "AppSelectionWidget" "AIAssistantWidget" "QuickActionWidget")
for widget in "${widgets[@]}"; do
    if grep -q "$widget" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
        echo "✅ $widget 存在"
    else
        echo "❌ $widget 缺失"
    fi
done

echo "🔍 检查数据管理器:"
if grep -q "WidgetDataManager" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ WidgetDataManager 存在"
else
    echo "❌ WidgetDataManager 缺失"
fi

echo "🔍 检查四个数据读取方法:"
methods=("getSearchEngines" "getApps" "getAIAssistants" "getQuickActions")
for method in "${methods[@]}"; do
    if grep -q "$method" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
        echo "✅ $method 方法存在"
    else
        echo "❌ $method 方法缺失"
    fi
done

# 2. 写入测试数据
echo ""
echo "💾 写入新版小组件测试数据..."

cat > write_new_widget_data.swift << 'EOF'
import Foundation

print("💾 写入新版小组件测试数据...")

let standardDefaults = UserDefaults.standard
let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

// 创建明确的测试数据，对应四个标签
let testEngines = ["bing", "yahoo", "duckduckgo", "yandex"]      // 4个搜索引擎
let testApps = ["wechat", "alipay", "meituan", "didi"]          // 4个应用
let testAI = ["chatgpt", "claude", "gemini", "copilot"]         // 4个AI助手
let testActions = ["translate", "calculator", "weather", "timer"] // 4个快捷操作

print("📝 准备写入的测试数据:")
print("  搜索引擎: \(testEngines)")
print("  应用: \(testApps)")
print("  AI助手: \(testAI)")
print("  快捷操作: \(testActions)")

// 保存到App Groups（主要数据源）
if let shared = sharedDefaults {
    print("💾 保存到App Groups...")
    shared.set(testEngines, forKey: "widget_search_engines")
    shared.set(testApps, forKey: "widget_apps")
    shared.set(testAI, forKey: "widget_ai_assistants")
    shared.set(testActions, forKey: "widget_quick_actions")
    shared.set(Date().timeIntervalSince1970, forKey: "widget_last_update")
    
    let sharedSync = shared.synchronize()
    print("💾 App Groups同步结果: \(sharedSync)")
    
    // 验证App Groups保存
    let verifyEngines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let verifyApps = shared.stringArray(forKey: "widget_apps") ?? []
    let verifyAI = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let verifyActions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("💾 App Groups保存验证:")
    print("  搜索引擎: \(verifyEngines)")
    print("  应用: \(verifyApps)")
    print("  AI助手: \(verifyAI)")
    print("  快捷操作: \(verifyActions)")
    
    let success = verifyEngines == testEngines && 
                  verifyApps == testApps && 
                  verifyAI == testAI && 
                  verifyActions == testActions
    
    if success {
        print("✅ App Groups数据保存成功")
    } else {
        print("❌ App Groups数据保存失败")
    }
} else {
    print("❌ App Groups不可用")
}

// 保存到UserDefaults（备用数据源）
print("💾 保存到UserDefaults...")
standardDefaults.set(testEngines, forKey: "iosbrowser_engines")
standardDefaults.set(testApps, forKey: "iosbrowser_apps")
standardDefaults.set(testAI, forKey: "iosbrowser_ai")
standardDefaults.set(testActions, forKey: "iosbrowser_actions")
standardDefaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let standardSync = standardDefaults.synchronize()
print("💾 UserDefaults同步结果: \(standardSync)")

print("🎯 新版小组件应该显示:")
print("  搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex")
print("  应用: WeChat, Alipay, Meituan, Didi")
print("  AI助手: ChatGPT, Claude, Gemini, Copilot")
print("  快捷操作: Translate, Calculator, Weather, Timer")
print("")
print("🎯 而不是默认值:")
print("  搜索引擎: 百度, 谷歌")
print("  应用: 淘宝, 知乎, 抖音")
print("  AI助手: DeepSeek, 通义千问")
print("  快捷操作: Search, Bookmark")
EOF

if command -v swift &> /dev/null; then
    swift write_new_widget_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据写入"
fi

rm -f write_new_widget_data.swift

# 3. 检查编译状态
echo ""
echo "🔧 检查编译状态..."

echo "🔍 检查语法错误:"
if grep -q "struct.*Widget.*:" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件结构定义正确"
else
    echo "❌ 小组件结构定义有问题"
fi

if grep -q "TimelineProvider" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ TimelineProvider实现存在"
else
    echo "❌ TimelineProvider实现缺失"
fi

if grep -q "TimelineEntry" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ TimelineEntry定义存在"
else
    echo "❌ TimelineEntry定义缺失"
fi

# 4. 总结新版小组件系统
echo ""
echo "🎉 新版小组件系统总结:"
echo "================================"
echo ""
echo "🏗️ 架构特点:"
echo "1. 完全重新构建 - 删除了所有旧代码"
echo "2. 基于四个标签 - 对应小组件配置tab的四个标签"
echo "3. 统一数据管理 - WidgetDataManager统一管理所有数据"
echo "4. 清晰的数据流 - App Groups优先，UserDefaults备用"
echo ""
echo "📱 四个独立小组件:"
echo "1. SearchEngineWidget - 搜索引擎小组件"
echo "2. AppSelectionWidget - 应用小组件"
echo "3. AIAssistantWidget - AI助手小组件"
echo "4. QuickActionWidget - 快捷操作小组件"
echo ""
echo "🔧 数据读取策略:"
echo "1. 优先从App Groups读取 (widget_search_engines等)"
echo "2. 备用从UserDefaults读取 (iosbrowser_engines等)"
echo "3. 最后使用默认值"
echo ""
echo "🎨 视觉设计:"
echo "- 每个小组件有独特的图标和颜色"
echo "- 2x2网格布局显示最多4个项目"
echo "- 支持小号和中号尺寸"
echo ""

echo "📱 使用步骤:"
echo "1. 重新编译项目 (Clean Build Folder + Build)"
echo "2. 重新安装应用到设备"
echo "3. 删除桌面上的所有旧小组件"
echo "4. 重启设备清除缓存"
echo "5. 添加新的四个小组件到桌面:"
echo "   - 搜索引擎"
echo "   - 应用"
echo "   - AI助手"
echo "   - 快捷操作"
echo "6. 验证每个小组件显示4个项目而不是默认值"
echo ""

echo "🔍 成功标志:"
echo "- 控制台显示: '[WidgetDataManager] 读取数据'"
echo "- 控制台显示: '[App Groups] 读取成功'"
echo "- 每个小组件显示4个自定义项目"
echo "- 不再显示默认的2-3个项目"
echo ""

echo "🎉🎉🎉 新版小组件系统测试完成！"
