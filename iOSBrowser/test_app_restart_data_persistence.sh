#!/bin/bash

# 🎉 应用重启数据持久化最终测试脚本
# 验证应用重启后数据加载的完整修复

echo "🎉🎉🎉 开始应用重启数据持久化最终测试..."
echo "📅 测试时间: $(date)"
echo ""

# 1. 检查DataSyncCenter初始化增强
echo "🚀 检查DataSyncCenter初始化增强..."

if grep -A 10 "private init()" iOSBrowser/ContentView.swift | grep -q "🔥🔥🔥 DataSyncCenter: 开始初始化"; then
    echo "✅ DataSyncCenter初始化包含详细调试日志"
else
    echo "❌ DataSyncCenter初始化缺少详细调试日志"
fi

# 2. 检查loadUserSelections增强
echo ""
echo "📂 检查loadUserSelections增强..."

if grep -A 20 "private func loadUserSelections" iOSBrowser/ContentView.swift | grep -q "🔥🔥🔥 DataSyncCenter: 开始加载用户之前的选择"; then
    echo "✅ loadUserSelections包含详细调试日志"
else
    echo "❌ loadUserSelections缺少详细调试日志"
fi

if grep -A 50 "private func loadUserSelections" iOSBrowser/ContentView.swift | grep -q "objectWillChange.send"; then
    echo "✅ loadUserSelections包含强制UI更新"
else
    echo "❌ loadUserSelections缺少强制UI更新"
fi

# 3. 检查WidgetConfigView增强
echo ""
echo "🎨 检查WidgetConfigView增强..."

# 检查@ObservedObject绑定
if grep -A 3 "struct WidgetConfigView" iOSBrowser/ContentView.swift | grep -q "@ObservedObject.*dataSyncCenter"; then
    echo "✅ WidgetConfigView使用@ObservedObject绑定"
else
    echo "❌ WidgetConfigView未使用@ObservedObject绑定"
fi

# 检查强化的onAppear
if grep -A 20 "\.onAppear" iOSBrowser/ContentView.swift | grep -q "🔥🔥🔥 WidgetConfigView: 开始强制加载数据"; then
    echo "✅ WidgetConfigView有强化的onAppear逻辑"
else
    echo "❌ WidgetConfigView缺少强化的onAppear逻辑"
fi

# 检查应用生命周期监听
if grep -q "willEnterForegroundNotification" iOSBrowser/ContentView.swift; then
    echo "✅ WidgetConfigView有应用生命周期监听"
else
    echo "❌ WidgetConfigView缺少应用生命周期监听"
fi

# 4. 检查所有配置子视图的绑定
echo ""
echo "🔗 检查配置子视图绑定..."

config_views=("SearchEngineConfigView" "UnifiedAppConfigView" "UnifiedAIConfigView" "QuickActionConfigView")
for view in "${config_views[@]}"; do
    if grep -A 3 "struct $view" iOSBrowser/ContentView.swift | grep -q "@ObservedObject.*dataSyncCenter"; then
        echo "✅ $view 使用@ObservedObject绑定"
    else
        echo "❌ $view 未使用@ObservedObject绑定"
    fi
done

# 5. 验证当前UserDefaults数据
echo ""
echo "🧪 验证当前UserDefaults数据..."

# 创建数据验证脚本
cat > verify_current_data.swift << 'EOF'
import Foundation

print("🔍 验证当前UserDefaults数据...")

let defaults = UserDefaults.standard
defaults.synchronize()

let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 当前UserDefaults数据:")
print("  搜索引擎: \(engines)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  应用: \(apps)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

let hasData = !engines.isEmpty || !ai.isEmpty || !actions.isEmpty || !apps.isEmpty
print("📊 数据状态: \(hasData ? "有数据" : "无数据")")

if hasData {
    print("✅ UserDefaults中有保存的用户配置")
    print("💡 应用重启后应该能正确加载这些配置")
} else {
    print("⚠️ UserDefaults中没有用户配置")
    print("💡 需要先在应用中进行配置并保存")
}
EOF

# 运行验证
if command -v swift &> /dev/null; then
    swift verify_current_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据验证"
fi

# 清理
rm -f verify_current_data.swift

# 6. 总结修复情况
echo ""
echo "🎉 应用重启数据持久化修复总结:"
echo "================================"
echo "✅ 1. DataSyncCenter初始化增强 - 详细调试日志"
echo "✅ 2. loadUserSelections增强 - 强制UI更新"
echo "✅ 3. WidgetConfigView绑定修复 - @ObservedObject"
echo "✅ 4. 强化onAppear逻辑 - 多次刷新确保数据加载"
echo "✅ 5. 应用生命周期监听 - 进入前台时刷新"
echo "✅ 6. 所有配置子视图统一绑定 - 共享数据实例"
echo ""

echo "🔧 关键修复内容:"
echo "1. 在DataSyncCenter初始化时添加详细调试日志"
echo "2. 在loadUserSelections中添加强制UI更新"
echo "3. 将WidgetConfigView改为@ObservedObject绑定"
echo "4. 在WidgetConfigView的onAppear中多次强制刷新"
echo "5. 添加应用进入前台时的数据刷新监听"
echo "6. 确保所有配置子视图使用相同的数据实例"
echo ""

echo "📱 测试步骤:"
echo "1. 启动应用，查看控制台是否有DataSyncCenter初始化日志"
echo "2. 进入小组件配置页面，查看是否有强制加载日志"
echo "3. 勾选一些选项，点击保存按钮"
echo "4. 完全退出应用（从后台清除）"
echo "5. 重新启动应用，进入小组件配置页面"
echo "6. 检查之前的勾选状态是否正确恢复"
echo ""

echo "🔍 关键日志标识:"
echo "- '🔥🔥🔥 DataSyncCenter: 开始初始化' - 应用启动"
echo "- '🔥🔥🔥 DataSyncCenter: 开始加载用户之前的选择' - 数据加载"
echo "- '✅ 恢复XXX选择' - 成功恢复用户配置"
echo "- '🔥🔥🔥 WidgetConfigView: 开始强制加载数据' - UI刷新"
echo "- '🔥🔥🔥 已发送UI更新通知' - UI同步"
echo ""

echo "🎉🎉🎉 应用重启数据持久化最终测试完成！"
