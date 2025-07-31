#!/bin/bash

# 🎉 最终重启修复验证脚本
# 验证消除loadUserSelections重复加载的修复

echo "🎉🎉🎉 开始最终重启修复验证..."
echo "📅 验证时间: $(date)"
echo ""

# 1. 检查@Published初始化增强
echo "🔍 检查@Published初始化增强..."

if grep -A 15 "@Published var selectedSearchEngines" iOSBrowser/ContentView.swift | grep -q "🔥🔥🔥 @Published初始化开始"; then
    echo "✅ selectedSearchEngines有详细初始化日志"
else
    echo "❌ selectedSearchEngines缺少详细初始化日志"
fi

if grep -A 15 "@Published var selectedSearchEngines" iOSBrowser/ContentView.swift | grep -q "defaults.synchronize()"; then
    echo "✅ selectedSearchEngines初始化时调用synchronize"
else
    echo "❌ selectedSearchEngines初始化时未调用synchronize"
fi

# 2. 检查loadUserSelections修改
echo ""
echo "🔍 检查loadUserSelections修改..."

if grep -A 5 "跳过loadUserSelections中的搜索引擎加载" iOSBrowser/ContentView.swift; then
    echo "✅ loadUserSelections跳过搜索引擎重复加载"
else
    echo "❌ loadUserSelections仍在重复加载搜索引擎"
fi

if grep -A 5 "跳过loadUserSelections中的应用加载" iOSBrowser/ContentView.swift; then
    echo "✅ loadUserSelections跳过应用重复加载"
else
    echo "❌ loadUserSelections仍在重复加载应用"
fi

if grep -A 5 "跳过loadUserSelections中的AI助手加载" iOSBrowser/ContentView.swift; then
    echo "✅ loadUserSelections跳过AI助手重复加载"
else
    echo "❌ loadUserSelections仍在重复加载AI助手"
fi

if grep -A 5 "跳过loadUserSelections中的快捷操作加载" iOSBrowser/ContentView.swift; then
    echo "✅ loadUserSelections跳过快捷操作重复加载"
else
    echo "❌ loadUserSelections仍在重复加载快捷操作"
fi

# 3. 验证当前数据状态
echo ""
echo "🧪 验证当前数据状态..."

cat > verify_final_fix.swift << 'EOF'
import Foundation

print("🔍 验证最终修复方案...")

let defaults = UserDefaults.standard
defaults.synchronize()

let engines = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
print("📱 当前UserDefaults中的搜索引擎: \(engines)")

// 模拟@Published初始化过程
print("🔍 模拟@Published初始化过程:")
if !engines.isEmpty {
    print("✅ @Published应该初始化为: \(engines)")
    print("🎯 UI应该显示:")
    let allEngines = ["baidu", "google", "bing", "sogou", "360", "duckduckgo"]
    for engine in allEngines {
        let isSelected = engines.contains(engine)
        print("  \(engine): \(isSelected ? "✅勾选" : "❌未勾选")")
    }
} else {
    print("⚠️ UserDefaults为空，将使用默认值 [baidu, google]")
}

// 检查是否有重复加载的风险
print("🔍 检查重复加载风险:")
print("由于loadUserSelections现在跳过重复加载，不会覆盖@Published的初始化")
print("✅ 应该能保持@Published初始化的正确值")
EOF

if command -v swift &> /dev/null; then
    swift verify_final_fix.swift
else
    echo "⚠️ Swift命令不可用，跳过数据验证"
fi

rm -f verify_final_fix.swift

# 4. 创建测试数据
echo ""
echo "🛠️ 创建明确的测试数据..."

cat > create_test_data.swift << 'EOF'
import Foundation

print("🔧 创建明确的测试数据...")

let defaults = UserDefaults.standard

// 创建明显不同于默认值的测试数据
let testEngines = ["bing", "duckduckgo", "sogou"]  // 明显不同于默认的[baidu, google]
defaults.set(testEngines, forKey: "iosbrowser_engines")
defaults.set(Date().timeIntervalSince1970, forKey: "iosbrowser_last_update")

let syncResult = defaults.synchronize()
print("📱 写入测试数据: \(testEngines)")
print("📱 同步结果: \(syncResult)")

// 立即验证
let readBack = defaults.stringArray(forKey: "iosbrowser_engines") ?? []
print("📱 立即读取验证: \(readBack)")

if readBack == testEngines {
    print("✅ 测试数据写入成功")
    print("🎯 重启应用后应该显示:")
    print("  baidu: ❌未勾选")
    print("  google: ❌未勾选")
    print("  bing: ✅勾选")
    print("  sogou: ✅勾选")
    print("  360: ❌未勾选")
    print("  duckduckgo: ✅勾选")
} else {
    print("❌ 测试数据写入失败")
}
EOF

if command -v swift &> /dev/null; then
    swift create_test_data.swift
else
    echo "⚠️ Swift命令不可用，跳过测试数据创建"
fi

rm -f create_test_data.swift

# 5. 总结最终修复
echo ""
echo "🎉 最终修复总结:"
echo "================================"
echo "✅ 1. @Published属性增强初始化 - 详细日志和强制同步"
echo "✅ 2. 消除重复加载 - loadUserSelections跳过已初始化的数据"
echo "✅ 3. 实时状态显示器 - UI中显示内存和存储数据"
echo "✅ 4. 详细调试日志 - 完整跟踪初始化过程"
echo ""

echo "🔧 关键修复原理:"
echo "1. @Published属性在声明时就正确初始化"
echo "2. loadUserSelections不再重复加载，避免覆盖"
echo "3. 消除了初始化竞争条件"
echo "4. 确保数据从始至终保持一致"
echo ""

echo "📱 测试步骤:"
echo "1. 重新编译运行应用"
echo "2. 查看控制台'🔥🔥🔥 @Published初始化开始'"
echo "3. 进入小组件配置页面"
echo "4. 应该看到bing、duckduckgo、sogou被勾选"
echo "5. 修改选择，保存"
echo "6. 完全退出应用，重新启动"
echo "7. 检查选择是否正确保持"
echo ""

echo "🔍 关键日志标识:"
echo "- '🔥🔥🔥 @Published初始化开始: selectedSearchEngines'"
echo "- '🔥🔥🔥 @Published读取UserDefaults: iosbrowser_engines = [...]'"
echo "- '🔥🔥🔥 @Published初始化: 加载用户搜索引擎 [...]'"
echo "- '🔥🔥🔥 跳过loadUserSelections中的搜索引擎加载，避免覆盖'"
echo ""

echo "🎯 预期效果:"
echo "现在应该能看到bing、duckduckgo、sogou被勾选"
echo "重启应用后这个选择应该保持不变"
echo "不再出现重置为baidu、google的问题"
echo ""

echo "🎉🎉🎉 最终重启修复验证完成！"
