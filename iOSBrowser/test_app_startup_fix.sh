#!/bin/bash

# 测试应用启动数据初始化修复的脚本

echo "🚀🚀🚀 测试应用启动数据初始化修复 🚀🚀🚀"

echo "1. 验证编译修复..."

echo "1.1 检查iOSBrowserApp.swift的init方法:"
if grep -A 3 "init()" iOSBrowser/iOSBrowserApp.swift | grep -q "Self.initializeWidgetData"; then
    echo "✅ init方法正确调用Self.initializeWidgetData()"
else
    echo "❌ init方法调用有问题"
fi

echo ""
echo "1.2 检查static方法定义:"
if grep -q "static func initializeWidgetData" iOSBrowser/iOSBrowserApp.swift; then
    echo "✅ initializeWidgetData定义为static方法"
else
    echo "❌ initializeWidgetData不是static方法"
fi

echo ""
echo "1.3 检查方法定义数量:"
method_count=$(grep -c "func initializeWidgetData" iOSBrowser/iOSBrowserApp.swift)
if [ "$method_count" -eq 1 ]; then
    echo "✅ initializeWidgetData方法只定义了一次"
else
    echo "❌ initializeWidgetData方法定义了${method_count}次"
fi

echo ""
echo "2. 验证简化的数据同步..."

echo "2.1 检查简化的toggle方法:"
if grep -A 15 "toggleSearchEngine.*被调用" iOSBrowser/ContentView.swift | grep -q "UserDefaults.standard.set"; then
    echo "✅ toggleSearchEngine直接保存到UserDefaults"
else
    echo "❌ toggleSearchEngine未直接保存"
fi

if grep -A 15 "toggleApp.*被调用" iOSBrowser/ContentView.swift | grep -q "UserDefaults.standard.set"; then
    echo "✅ toggleApp直接保存到UserDefaults"
else
    echo "❌ toggleApp未直接保存"
fi

echo ""
echo "2.2 检查简化的小组件读取:"
if grep -A 5 "getSearchEngines" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "UserDefaults.standard.stringArray.*baidu.*google"; then
    echo "✅ 小组件直接从UserDefaults读取搜索引擎"
else
    echo "❌ 小组件搜索引擎读取未简化"
fi

if grep -A 5 "getQuickActions" iOSBrowserWidgets/iOSBrowserWidgets.swift | grep -q "UserDefaults.standard.stringArray.*search.*bookmark"; then
    echo "✅ 小组件直接从UserDefaults读取快捷操作"
else
    echo "❌ 小组件快捷操作读取未简化"
fi

echo ""
echo "3. 简化方案总结..."

echo "🎯 关键改进:"
echo "   1. 应用启动时立即初始化 - 不依赖用户操作"
echo "   2. 用户操作直接保存 - 去除复杂中间层"
echo "   3. 小组件简化读取 - 直接从UserDefaults读取"
echo "   4. 明确的调试日志 - 每个步骤都可追踪"

echo ""
echo "🎯 数据流简化:"
echo "   之前: 用户操作 → toggle → DataSyncCenter.update → immediateSyncToWidgets → saveToWidgetAccessibleLocation → UserDefaults"
echo "   现在: 用户操作 → toggle → 直接保存UserDefaults"

echo ""
echo "4. 测试步骤..."

echo "📱 第一步：编译测试"
echo "   1. 在Xcode中编译项目"
echo "   2. 应该没有'Cannot find initializeWidgetData in scope'错误"
echo "   3. 应用能正常启动"

echo ""
echo "📱 第二步：应用启动测试"
echo "   1. 完全关闭应用"
echo "   2. 重新启动应用"
echo "   3. 观察控制台，应该立即看到："
echo "      🚨🚨🚨 ===== 应用启动，立即初始化数据 ====="
echo "      🚀🚀🚀 开始初始化小组件数据..."
echo "      🚀 初始化搜索引擎: [\"baidu\", \"google\"]"
echo "      🚀 初始化应用: [\"taobao\", \"zhihu\", \"douyin\"]"
echo "      🚀 初始化AI助手: [\"deepseek\", \"qwen\"]"
echo "      🚀 初始化快捷操作: [\"search\", \"bookmark\"]"
echo "      🚨🚨🚨 ===== 应用数据初始化完成 ====="

echo ""
echo "📱 第三步：用户操作测试"
echo "   1. 进入小组件配置页面"
echo "   2. 点击一个搜索引擎进行勾选/取消勾选"
echo "   3. 观察控制台，应该看到："
echo "      🚨🚨🚨 toggleSearchEngine 被调用: [引擎名]"
echo "      🚨 已保存搜索引擎到UserDefaults，同步结果: true"
echo "      🚨 ✅ 搜索引擎数据保存成功！"

echo ""
echo "📱 第四步：小组件测试"
echo "   1. 添加一个小组件到桌面"
echo "   2. 观察控制台，应该看到："
echo "      🔧 [SimpleWidget] 读取搜索引擎数据"
echo "      🔧 [SimpleWidget] 搜索引擎数据: [用户选择的数据]"
echo "   3. 小组件应该显示用户选择的数据，不是空数据"

echo ""
echo "5. 成功标志..."

echo "✅ 完全成功的标志:"
echo "   1. 编译没有错误"
echo "   2. 应用启动时有明确的初始化日志"
echo "   3. 用户操作时有明确的保存日志"
echo "   4. 小组件读取时有明确的数据日志"
echo "   5. 小组件显示正确的数据，不是空数据或测试数据"

echo ""
echo "6. 故障排除..."

echo "🔍 如果编译失败:"
echo "   - 检查static方法定义是否正确"
echo "   - 确认方法调用语法是否正确"
echo "   - 检查是否有重复定义"

echo ""
echo "🔍 如果应用启动没有日志:"
echo "   - 检查init方法是否被调用"
echo "   - 确认print语句是否正确"
echo "   - 检查控制台过滤设置"

echo ""
echo "🔍 如果用户操作没有保存:"
echo "   - 检查toggle方法是否被调用"
echo "   - 确认UserDefaults.set是否执行"
echo "   - 检查同步结果是否为true"

echo ""
echo "🔍 如果小组件仍显示空数据:"
echo "   - 检查UserDefaults中是否有数据"
echo "   - 确认小组件读取的键名是否正确"
echo "   - 尝试重新添加小组件"

echo ""
echo "🚀🚀🚀 测试指南完成 🚀🚀🚀"

echo ""
echo "💡 关键提示:"
echo "   这个修复彻底简化了数据同步逻辑，"
echo "   应用启动时立即初始化默认数据，"
echo "   用户操作直接保存到UserDefaults，"
echo "   小组件直接读取，确保数据同步的可靠性！"
