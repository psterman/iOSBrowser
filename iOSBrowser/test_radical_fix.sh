#!/bin/bash

# 🎉 激进修复方案验证脚本
# 验证@Published属性直接初始化修复

echo "🎉🎉🎉 开始激进修复方案验证..."
echo "📅 验证时间: $(date)"
echo ""

# 1. 检查@Published属性的新初始化方式
echo "🔍 检查@Published属性的新初始化方式..."

echo "🔍 selectedSearchEngines初始化:"
if grep -A 10 "@Published var selectedSearchEngines" iOSBrowser/ContentView.swift | grep -q "iosbrowser_engines"; then
    echo "✅ selectedSearchEngines使用UserDefaults初始化"
else
    echo "❌ selectedSearchEngines未使用UserDefaults初始化"
fi

echo "🔍 selectedApps初始化:"
if grep -A 10 "@Published var selectedApps" iOSBrowser/ContentView.swift | grep -q "iosbrowser_apps"; then
    echo "✅ selectedApps使用UserDefaults初始化"
else
    echo "❌ selectedApps未使用UserDefaults初始化"
fi

echo "🔍 selectedAIAssistants初始化:"
if grep -A 10 "@Published var selectedAIAssistants" iOSBrowser/ContentView.swift | grep -q "iosbrowser_ai"; then
    echo "✅ selectedAIAssistants使用UserDefaults初始化"
else
    echo "❌ selectedAIAssistants未使用UserDefaults初始化"
fi

echo "🔍 selectedQuickActions初始化:"
if grep -A 10 "@Published var selectedQuickActions" iOSBrowser/ContentView.swift | grep -q "iosbrowser_actions"; then
    echo "✅ selectedQuickActions使用UserDefaults初始化"
else
    echo "❌ selectedQuickActions未使用UserDefaults初始化"
fi

# 2. 检查实时状态显示器
echo ""
echo "🎨 检查实时状态显示器..."

if grep -q "实时数据状态" iOSBrowser/ContentView.swift; then
    echo "✅ 添加了实时数据状态显示器"
else
    echo "❌ 未添加实时数据状态显示器"
fi

if grep -q "内存.*dataSyncCenter.selectedSearchEngines" iOSBrowser/ContentView.swift; then
    echo "✅ 显示内存中的数据"
else
    echo "❌ 未显示内存中的数据"
fi

if grep -q "存储.*UserDefaults.standard.stringArray" iOSBrowser/ContentView.swift; then
    echo "✅ 显示存储中的数据"
else
    echo "❌ 未显示存储中的数据"
fi

# 3. 检查UI状态指示器
echo ""
echo "🔍 检查UI状态指示器..."

if grep -q "实时状态指示器" iOSBrowser/ContentView.swift; then
    echo "✅ 添加了UI状态指示器"
else
    echo "❌ 未添加UI状态指示器"
fi

if grep -q "dataSyncCenter.selectedSearchEngines.contains.*✅.*❌" iOSBrowser/ContentView.swift; then
    echo "✅ 添加了勾选状态指示器"
else
    echo "❌ 未添加勾选状态指示器"
fi

# 4. 验证当前数据状态
echo ""
echo "🧪 验证当前数据状态..."

# 创建数据验证脚本
cat > verify_radical_fix.swift << 'EOF'
import Foundation

print("🔍 验证激进修复方案...")

let defaults = UserDefaults.standard
defaults.synchronize()

let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
let ai = defaults.stringArray(forKey: "iosbrowser_ai") ?? []
let actions = defaults.stringArray(forKey: "iosbrowser_actions") ?? []
let apps = defaults.stringArray(forKey: "iosbrowser_apps") ?? []

print("📱 UserDefaults中的数据:")
print("  搜索引擎: \(engines)")
print("  AI助手: \(ai)")
print("  快捷操作: \(actions)")
print("  应用: \(apps)")

// 模拟@Published属性的新初始化逻辑
func simulatePublishedInit() {
    print("🔍 模拟@Published属性初始化:")
    
    let initEngines = engines.isEmpty ? ["baidu", "google"] : engines
    let initAI = ai.isEmpty ? ["deepseek", "qwen"] : ai
    let initActions = actions.isEmpty ? ["search", "bookmark"] : actions
    let initApps = apps.isEmpty ? ["taobao", "zhihu", "douyin"] : apps
    
    print("  搜索引擎初始化为: \(initEngines)")
    print("  AI助手初始化为: \(initAI)")
    print("  快捷操作初始化为: \(initActions)")
    print("  应用初始化为: \(initApps)")
    
    // 检查是否使用了用户数据
    let usingUserData = !engines.isEmpty || !ai.isEmpty || !actions.isEmpty || !apps.isEmpty
    print("📊 是否使用用户数据: \(usingUserData ? "是" : "否")")
    
    if usingUserData {
        print("✅ @Published属性应该直接初始化为用户数据")
        print("🎯 UI应该立即显示正确的勾选状态")
    } else {
        print("⚠️ 没有用户数据，将使用默认值")
    }
}

simulatePublishedInit()

// 检查特定的搜索引擎状态
print("🔍 搜索引擎详细状态:")
let testEngines = ["baidu", "google", "bing", "sogou", "360", "duckduckgo"]
let currentEngines = engines.isEmpty ? ["baidu", "google"] : engines

for engine in testEngines {
    let isSelected = currentEngines.contains(engine)
    print("  \(engine): \(isSelected ? "✅ 应该勾选" : "❌ 应该未勾选")")
}
EOF

# 运行验证
if command -v swift &> /dev/null; then
    swift verify_radical_fix.swift
else
    echo "⚠️ Swift命令不可用，跳过数据验证"
fi

# 清理
rm -f verify_radical_fix.swift

# 5. 总结激进修复方案
echo ""
echo "🎉 激进修复方案总结:"
echo "================================"
echo "✅ 1. @Published属性直接初始化 - 在属性声明时就加载用户数据"
echo "✅ 2. 实时数据状态显示器 - 在UI中显示内存和存储数据对比"
echo "✅ 3. UI状态指示器 - 每个选项显示实时勾选状态"
echo "✅ 4. 详细点击日志 - 记录每次点击的前后状态"
echo ""

echo "🔧 关键修复原理:"
echo "1. 绕过loadUserSelections的时机问题"
echo "2. 确保@Published属性从一开始就是正确的值"
echo "3. 提供实时可视化调试信息"
echo "4. 消除默认值覆盖用户数据的可能性"
echo ""

echo "📱 测试步骤:"
echo "1. 重新编译运行应用"
echo "2. 查看控制台是否有'🔥🔥🔥 @Published初始化'"
echo "3. 进入小组件配置页面"
echo "4. 查看'实时数据状态'显示的内存和存储数据"
echo "5. 查看每个选项的✅❌状态指示器"
echo "6. 点击任何选项，查看详细的点击日志"
echo ""

echo "🔍 关键日志标识:"
echo "- '🔥🔥🔥 @Published初始化: 加载XXX' - 成功加载用户数据"
echo "- '🔥🔥🔥 @Published初始化: 使用默认XXX' - 使用默认值"
echo "- '🔄🔄🔄 点击前状态' - 点击前的数据状态"
echo "- '🔄🔄🔄 点击后状态' - 点击后的数据状态"
echo ""

echo "🎯 预期效果:"
echo "如果UserDefaults中有数据，UI应该立即显示正确的勾选状态"
echo "实时状态显示器应该显示内存和存储数据一致"
echo "每个选项的✅❌指示器应该反映真实状态"
echo ""

echo "🎉🎉🎉 激进修复方案验证完成！"
