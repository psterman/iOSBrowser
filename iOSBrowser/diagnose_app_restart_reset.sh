#!/bin/bash

# 🔍 诊断应用重启后重置问题
# 专门分析为什么重启后又变回百度和谷歌

echo "🔍🔍🔍 开始诊断应用重启后重置问题..."
echo "📅 诊断时间: $(date)"
echo ""

# 1. 验证当前UserDefaults中的数据
echo "🧪 验证当前UserDefaults中的数据..."

cat > check_userdefaults.swift << 'EOF'
import Foundation

print("🔍 检查UserDefaults中的实际数据...")

let defaults = UserDefaults.standard
defaults.synchronize()

// 检查所有相关的键
let keys = ["iosbrowser_engines", "widget_search_engines_v2", "widget_search_engines_v3"]

print("📱 搜索引擎相关的所有键:")
for key in keys {
    let value = defaults.stringArray(forKey: key) ?? []
    print("  \(key): \(value)")
}

// 检查最后更新时间
let lastUpdate = defaults.double(forKey: "iosbrowser_last_update")
print("📅 最后更新时间: \(Date(timeIntervalSince1970: lastUpdate))")

// 检查是否有其他可能的键
let allKeys = defaults.dictionaryRepresentation().keys.filter { $0.contains("engine") || $0.contains("search") }
print("🔍 所有包含'engine'或'search'的键:")
for key in allKeys {
    let value = defaults.object(forKey: key)
    print("  \(key): \(value ?? "nil")")
}

// 模拟@Published初始化逻辑
print("🔍 模拟@Published初始化逻辑:")
let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
if !engines.isEmpty {
    print("✅ 应该加载用户数据: \(engines)")
} else {
    print("❌ 数据为空，将使用默认值: [\"baidu\", \"google\"]")
}
EOF

if command -v swift &> /dev/null; then
    swift check_userdefaults.swift
else
    echo "⚠️ Swift命令不可用，跳过UserDefaults检查"
fi

rm -f check_userdefaults.swift

# 2. 检查@Published初始化代码
echo ""
echo "🔍 检查@Published初始化代码..."

echo "📋 当前的selectedSearchEngines初始化代码:"
grep -A 10 "@Published var selectedSearchEngines" iOSBrowser/ContentView.swift | head -10

# 3. 检查是否有其他地方重新设置了默认值
echo ""
echo "🚨 检查可能重新设置默认值的地方..."

echo "🔍 查找所有设置为[\"baidu\", \"google\"]的地方:"
grep -n "baidu.*google" iOSBrowser/ContentView.swift | while read line; do
    line_num=$(echo "$line" | cut -d: -f1)
    echo "第 $line_num 行: $line"
done

# 4. 检查loadUserSelections是否被调用
echo ""
echo "🔄 检查loadUserSelections调用..."

echo "🔍 查找loadUserSelections的调用位置:"
grep -n "loadUserSelections" iOSBrowser/ContentView.swift

# 5. 检查refreshUserSelections是否被调用
echo ""
echo "🔄 检查refreshUserSelections调用..."

echo "🔍 查找refreshUserSelections的调用位置:"
grep -n "refreshUserSelections" iOSBrowser/ContentView.swift

# 6. 创建测试数据写入脚本
echo ""
echo "🛠️ 创建测试数据写入..."

cat > write_test_data.swift << 'EOF'
import Foundation

print("🔧 写入测试数据...")

let defaults = UserDefaults.standard

// 写入明确的测试数据
let testEngines = ["google", "bing", "duckduckgo"]
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let syncResult = defaults.synchronize()
print("📱 写入测试数据: \(testEngines)")
print("📱 同步结果: \(syncResult)")

// 立即验证写入结果
let readBack = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
print("📱 立即读取验证: \(readBack)")

if readBack == testEngines {
    print("✅ 数据写入成功")
} else {
    print("❌ 数据写入失败")
}
EOF

if command -v swift &> /dev/null; then
    swift write_test_data.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据写入"
fi

rm -f write_test_data.swift

# 7. 分析可能的问题
echo ""
echo "🚨 可能的问题分析:"
echo "================================"
echo "基于您的描述，问题可能是："
echo ""
echo "1. @Published初始化时机问题"
echo "   - 可能在UserDefaults数据可用之前就初始化了"
echo "   - 或者UserDefaults.synchronize()没有正确工作"
echo ""
echo "2. 数据保存问题"
echo "   - 用户选择可能没有正确保存到UserDefaults"
echo "   - 或者保存到了错误的键"
echo ""
echo "3. 初始化顺序问题"
echo "   - DataSyncCenter可能在@Published属性之后才加载数据"
echo "   - loadUserSelections可能覆盖了@Published的初始化"
echo ""
echo "4. 应用沙盒问题"
echo "   - 应用重启后可能使用了不同的沙盒"
echo "   - UserDefaults可能被系统清理"
echo ""

echo "🔧 建议的调试步骤:"
echo "1. 在应用中选择google、bing、duckduckgo"
echo "2. 查看实时状态显示器确认数据正确"
echo "3. 完全退出应用"
echo "4. 重新启动应用"
echo "5. 查看控制台的'🔥🔥🔥 @Published初始化'日志"
echo "6. 检查实时状态显示器显示的数据"
echo ""

echo "🔍🔍🔍 应用重启后重置问题诊断完成！"
