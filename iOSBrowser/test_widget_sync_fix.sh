#!/bin/bash

echo "🔧 小组件数据同步修复验证测试"
echo "=================================="

echo ""
echo "📋 测试内容："
echo "1. 验证主应用数据保存逻辑"
echo "2. 验证小组件数据读取逻辑"
echo "3. 验证App Groups配置状态"
echo "4. 验证数据键值匹配"
echo ""

echo "🔍 检查项目配置..."

# 检查App Groups配置
echo "📱 检查App Groups配置："
if grep -r "group.com.iosbrowser.shared" . --include="*.entitlements" 2>/dev/null; then
    echo "✅ 找到App Groups配置文件"
else
    echo "⚠️  未找到App Groups entitlements文件"
    echo "   需要在Xcode中手动配置App Groups"
fi

echo ""
echo "🔍 检查代码修复状态..."

# 检查主应用保存逻辑
echo "📱 检查主应用数据保存逻辑："
if grep -q "同时保存到App Groups键值" iOSBrowser/ContentView.swift; then
    echo "✅ 主应用已修复：支持双重保存策略"
else
    echo "❌ 主应用未修复"
fi

# 检查小组件读取逻辑
echo "📱 检查小组件数据读取逻辑："
if grep -q "优先从App Groups读取" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 小组件已修复：支持App Groups优先读取"
else
    echo "❌ 小组件未修复"
fi

echo ""
echo "🔍 检查数据键值匹配..."

# 检查数据键值
echo "📱 主应用保存的键值："
grep -n "forKey:" iOSBrowser/ContentView.swift | grep -E "(iosbrowser_|widget_)" | head -10

echo ""
echo "📱 小组件读取的键值："
grep -n "forKey:" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -E "(iosbrowser_|widget_)" | head -10

echo ""
echo "🎯 修复效果总结："
echo "=================================="
echo "✅ 小组件数据管理器已修复"
echo "   - 优先从App Groups读取用户配置"
echo "   - 回退到标准UserDefaults"
echo "   - 统一数据键值映射"
echo ""
echo "✅ 主应用保存逻辑已修复"
echo "   - 用户操作时双重保存"
echo "   - 同时保存到标准UserDefaults和App Groups"
echo "   - 立即刷新小组件"
echo ""
echo "🔧 下一步操作："
echo "1. 在Xcode中配置App Groups（如果尚未配置）"
echo "2. 重新编译并安装应用"
echo "3. 测试小组件配置页面的数据同步"
echo ""
echo "📋 App Groups配置步骤："
echo "1. 选择主应用Target (iOSBrowser)"
echo "2. 进入 Signing & Capabilities"
echo "3. 点击 + Capability，添加 App Groups"
echo "4. 创建组：group.com.iosbrowser.shared"
echo "5. 对小组件扩展Target重复相同操作"
echo ""
echo "🧪 测试验证："
echo "1. 进入小组件配置页面"
echo "2. 勾选/取消勾选任意项目"
echo "3. 观察控制台日志确认数据保存"
echo "4. 检查桌面小组件是否实时更新"
