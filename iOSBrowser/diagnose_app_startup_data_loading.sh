#!/bin/bash

# 🔍 诊断应用启动时数据加载问题
# 检查为什么重新启动应用后配置数据重置

echo "🔍🔍🔍 开始诊断应用启动时数据加载问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 检查DataSyncCenter的初始化逻辑
echo "🚀 检查DataSyncCenter初始化逻辑..."

# 检查init方法是否调用loadUserSelections
if grep -A 10 "private init()" iOSBrowser/ContentView.swift | grep -q "loadUserSelections"; then
    echo "✅ DataSyncCenter初始化时调用loadUserSelections"
else
    echo "❌ DataSyncCenter初始化时未调用loadUserSelections"
fi

# 检查init方法的完整逻辑
echo ""
echo "📋 DataSyncCenter初始化方法内容:"
grep -A 10 "private init()" iOSBrowser/ContentView.swift | head -10

# 2. 检查loadUserSelections的实现
echo ""
echo "📂 检查loadUserSelections实现..."

# 检查是否读取正确的键
keys=("iosbrowser_engines" "iosbrowser_ai" "iosbrowser_actions" "iosbrowser_apps")
for key in "${keys[@]}"; do
    if grep -A 50 "func loadUserSelections" iOSBrowser/ContentView.swift | grep -q "forKey.*\"$key\""; then
        echo "✅ loadUserSelections读取键: $key"
    else
        echo "❌ loadUserSelections未读取键: $key"
    fi
done

# 3. 检查默认值设置
echo ""
echo "🎯 检查默认值设置..."

# 检查@Published属性的默认值
echo "📊 当前默认值设置:"
grep -A 5 "@Published var selected" iOSBrowser/ContentView.swift | grep "=" | head -4

# 4. 检查是否有多个DataSyncCenter实例
echo ""
echo "🔄 检查DataSyncCenter实例管理..."

# 检查shared实例的定义
if grep -q "static let shared = DataSyncCenter()" iOSBrowser/ContentView.swift; then
    echo "✅ DataSyncCenter有shared单例"
else
    echo "❌ DataSyncCenter缺少shared单例"
fi

# 检查视图中的绑定方式
binding_count=$(grep -c "@ObservedObject.*dataSyncCenter.*DataSyncCenter.shared" iOSBrowser/ContentView.swift)
echo "📊 @ObservedObject绑定数量: $binding_count"

# 5. 检查应用生命周期
echo ""
echo "🔄 检查应用生命周期处理..."

# 检查是否有onAppear刷新逻辑
if grep -q "onAppear.*refreshUserSelections" iOSBrowser/ContentView.swift; then
    echo "✅ 有onAppear刷新逻辑"
else
    echo "❌ 缺少onAppear刷新逻辑"
fi

# 检查WidgetConfigView的onAppear
if grep -A 10 "struct WidgetConfigView" iOSBrowser/ContentView.swift | grep -A 20 "onAppear" | grep -q "refreshUserSelections"; then
    echo "✅ WidgetConfigView有数据刷新"
else
    echo "❌ WidgetConfigView缺少数据刷新"
fi

# 6. 模拟数据读取测试
echo ""
echo "🧪 模拟数据读取测试..."

# 创建测试脚本
cat > test_data_reading.swift << 'EOF'
import Foundation

print("🔍 开始测试UserDefaults数据读取...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 读取所有相关键
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")

print("📱 UserDefaults中的数据:")
print("  搜索引擎: \(engines)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  应用: \(apps)")
print("  最后更新: \(Date(timeIntervalSince1970: lastUpdate))")

// 检查数据是否为空
let isEmpty = engines.isEmpty && ai.isEmpty && actions.isEmpty && apps.isEmpty
print("📊 数据状态: \(isEmpty ? "全部为空" : "有数据")")

if isEmpty {
    print("⚠️ 所有数据都为空，可能的原因:")
    print("  1. 数据从未被保存")
    print("  2. 保存的键名不正确")
    print("  3. UserDefaults被清除")
    print("  4. 应用沙盒发生变化")
}
EOF

# 运行测试
if command -v swift &> /dev/null; then
    echo "🔧 运行数据读取测试..."
    swift test_data_reading.swift
else
    echo "⚠️ Swift命令不可用，跳过数据读取测试"
fi

# 清理
rm -f test_data_reading.swift

# 7. 建议的修复方案
echo ""
echo "🔧 建议的修复方案:"
echo "================================"
echo "1. 增强loadUserSelections的调试日志"
echo "2. 在WidgetConfigView的onAppear中强制刷新数据"
echo "3. 添加应用生命周期监听，在进入前台时刷新"
echo "4. 检查UserDefaults的键名一致性"
echo "5. 添加数据加载失败的备用方案"
echo ""

echo "🔍 调试步骤:"
echo "1. 启动应用，查看控制台是否有'🔥 DataSyncCenter: 开始加载用户之前的选择'"
echo "2. 查看是否有'✅ 恢复XXX选择'的日志"
echo "3. 如果没有，说明loadUserSelections未被调用或数据为空"
echo "4. 进入小组件配置页面，查看onAppear是否触发数据刷新"
echo ""

echo "🔍🔍🔍 应用启动时数据加载问题诊断完成！"
