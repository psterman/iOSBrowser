#!/bin/bash

# 🔄 完整数据流测试脚本
# 测试从用户操作到数据保存的完整流程

echo "🔄🔄🔄 开始完整数据流测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 模拟写入测试数据到UserDefaults
echo "📝 模拟写入测试数据..."

# 创建一个简单的测试脚本来写入数据
cat > test_write_data.swift << 'EOF'
import Foundation

let defaults = UserDefaults.standard

// 写入测试数据
defaults.set(["google", "bing"], forKey: "iosbrowser_engines")
defaults.set(["deepseek", "claude"], forKey: "iosbrowser_ai")
defaults.set(["search", "history"], forKey: "iosbrowser_actions")
defaults.set(["taobao", "jd"], forKey: "iosbrowser_apps")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let syncResult = defaults.synchronize()
print("写入测试数据同步结果: \(syncResult)")

// 立即验证写入结果
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("验证写入结果:")
print("  搜索引擎: \(engines)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  应用: \(apps)")
EOF

# 运行测试脚本
echo "🔧 运行数据写入测试..."
if command -v swift &> /dev/null; then
    swift test_write_data.swift
    echo "✅ 测试数据写入完成"
else
    echo "⚠️ Swift命令不可用，跳过数据写入测试"
fi

# 清理测试文件
rm -f test_write_data.swift

# 2. 检查DataSyncCenter的初始化逻辑
echo ""
echo "🔍 检查DataSyncCenter初始化逻辑..."

# 检查init方法
if grep -A 5 "private init()" iOSBrowser/ContentView.swift | grep -q "loadAllData"; then
    echo "✅ 初始化时调用loadAllData"
else
    echo "❌ 初始化时未调用loadAllData"
fi

if grep -A 5 "private init()" iOSBrowser/ContentView.swift | grep -q "loadUserSelections"; then
    echo "✅ 初始化时调用loadUserSelections"
else
    echo "❌ 初始化时未调用loadUserSelections"
fi

# 3. 检查loadUserSelections的实现
echo ""
echo "📂 检查loadUserSelections实现..."

# 检查是否读取正确的键
read_keys=("iosbrowser_engines" "iosbrowser_ai" "iosbrowser_actions" "iosbrowser_apps")
for key in "${read_keys[@]}"; do
    if grep -A 20 "func loadUserSelections" iOSBrowser/ContentView.swift | grep -q "forKey.*\"$key\""; then
        echo "✅ loadUserSelections读取键: $key"
    else
        echo "❌ loadUserSelections未读取键: $key"
    fi
done

# 4. 检查保存逻辑的完整性
echo ""
echo "💾 检查保存逻辑完整性..."

# 检查saveToWidgetAccessibleLocationFromDataSyncCenter方法
if grep -A 30 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "iosbrowser_engines"; then
    echo "✅ 保存方法包含搜索引擎保存"
else
    echo "❌ 保存方法缺少搜索引擎保存"
fi

if grep -A 30 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "iosbrowser_ai"; then
    echo "✅ 保存方法包含AI助手保存"
else
    echo "❌ 保存方法缺少AI助手保存"
fi

if grep -A 30 "func saveToWidgetAccessibleLocationFromDataSyncCenter" iOSBrowser/ContentView.swift | grep -q "iosbrowser_actions"; then
    echo "✅ 保存方法包含快捷操作保存"
else
    echo "❌ 保存方法缺少快捷操作保存"
fi

# 5. 检查UI绑定
echo ""
echo "🔗 检查UI数据绑定..."

# 检查配置视图是否使用@ObservedObject
config_views=("SearchEngineConfigView" "UnifiedAIConfigView" "QuickActionConfigView")
for view in "${config_views[@]}"; do
    if grep -A 3 "struct $view" iOSBrowser/ContentView.swift | grep -q "@ObservedObject.*dataSyncCenter"; then
        echo "✅ $view 使用@ObservedObject绑定"
    else
        echo "❌ $view 未正确绑定DataSyncCenter"
    fi
done

# 6. 检查默认值设置
echo ""
echo "🎯 检查默认值设置..."

# 检查DataSyncCenter中的默认值
if grep -A 10 "class DataSyncCenter" iOSBrowser/ContentView.swift | grep -q "selectedSearchEngines.*="; then
    default_engines=$(grep -A 10 "class DataSyncCenter" iOSBrowser/ContentView.swift | grep "selectedSearchEngines.*=" | head -1)
    echo "✅ 搜索引擎默认值: $default_engines"
else
    echo "❌ 未找到搜索引擎默认值"
fi

# 7. 建议的修复方案
echo ""
echo "🔧 建议的修复方案:"
echo "================================"
echo "1. 确保DataSyncCenter.shared在应用启动时正确初始化"
echo "2. 在loadUserSelections中添加更多调试日志"
echo "3. 在saveToWidgetAccessibleLocationFromDataSyncCenter中添加立即验证"
echo "4. 检查UI视图的生命周期，确保onAppear正确触发"
echo "5. 添加手动触发数据保存的测试按钮"
echo ""

echo "📱 测试步骤:"
echo "1. 启动应用，查看控制台是否有DataSyncCenter初始化日志"
echo "2. 进入小组件配置页面，查看是否有数据加载日志"
echo "3. 勾选一个选项，查看是否有保存日志"
echo "4. 重启应用，查看数据是否恢复"
echo ""

echo "🔄🔄🔄 完整数据流测试完成！"
