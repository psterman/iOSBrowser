#!/bin/bash

# 诊断数据初始化问题的脚本

echo "🔍🔍🔍 诊断数据初始化问题 🔍🔍🔍"

echo "📊 当前问题分析："
echo "❌ 小组件读取结果: iosbrowser_actions = []"
echo "❌ App Groups读取结果: widget_quick_actions = []"
echo "❌ 小组件使用默认数据: [\"search\", \"bookmark\"]"
echo ""
echo "🚨 问题：主应用的@Published变量初始化可能没有被执行"

echo ""
echo "1. 检查@Published变量初始化逻辑..."

# 检查selectedQuickActions的初始化
echo "1.1 检查selectedQuickActions初始化:"
if grep -A 15 "@Published var selectedQuickActions" iOSBrowser/ContentView.swift | grep -q "defaults.set.*iosbrowser_actions"; then
    echo "✅ selectedQuickActions有保存逻辑"
    grep -A 15 "@Published var selectedQuickActions" iOSBrowser/ContentView.swift | grep -A 3 "defaults.set.*iosbrowser_actions"
else
    echo "❌ selectedQuickActions缺少保存逻辑"
fi

echo ""
echo "1.2 检查其他@Published变量:"
for var in "selectedSearchEngines" "selectedApps" "selectedAIAssistants"; do
    if grep -A 15 "@Published var $var" iOSBrowser/ContentView.swift | grep -q "defaults.set"; then
        echo "✅ $var 有保存逻辑"
    else
        echo "❌ $var 缺少保存逻辑"
    fi
done

echo ""
echo "2. 可能的问题原因..."

echo "🔍 问题1: @Published变量初始化时机"
echo "   - @Published变量在DataSyncCenter创建时初始化"
echo "   - 如果DataSyncCenter没有被创建，初始化不会执行"
echo "   - 需要确保应用启动时创建DataSyncCenter实例"

echo ""
echo "🔍 问题2: 初始化顺序问题"
echo "   - 可能小组件在主应用初始化之前就被调用"
echo "   - 需要在应用启动时立即初始化数据"

echo ""
echo "🔍 问题3: UserDefaults同步问题"
echo "   - 数据可能保存了但没有同步"
echo "   - 需要强制同步UserDefaults"

echo ""
echo "3. 检查DataSyncCenter的创建..."

# 检查DataSyncCenter在ContentView中的使用
if grep -q "@StateObject.*dataSyncCenter.*DataSyncCenter" iOSBrowser/ContentView.swift; then
    echo "✅ DataSyncCenter作为@StateObject创建"
else
    echo "❌ DataSyncCenter创建方式有问题"
fi

echo ""
echo "4. 建议的修复方案..."

echo "💡 方案1: 在ContentView的onAppear中强制初始化"
echo "💡 方案2: 在DataSyncCenter的init方法中强制保存默认数据"
echo "💡 方案3: 添加应用启动时的数据检查和修复机制"
echo "💡 方案4: 在小组件中添加更智能的默认数据处理"

echo ""
echo "5. 立即修复建议..."

echo "🔧 修复步骤:"
echo "1. 在ContentView的onAppear中添加数据初始化检查"
echo "2. 如果UserDefaults为空，强制保存默认数据"
echo "3. 立即同步到小组件"
echo "4. 添加调试日志确认执行"

echo ""
echo "📱 测试方法:"
echo "1. 删除应用重新安装（清除所有数据）"
echo "2. 启动应用，观察控制台日志"
echo "3. 应该看到'@Published初始化: 已保存默认XXX到UserDefaults'"
echo "4. 添加小组件，检查是否显示正确数据"

echo ""
echo "🔍🔍🔍 诊断完成 🔍🔍🔍"
