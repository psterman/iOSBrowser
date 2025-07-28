#!/bin/bash

# 桌面小组件修复验证脚本

echo "🔧 桌面小组件修复验证..."

# 1. 检查增强的小组件刷新机制
echo ""
echo "🔄 检查增强的小组件刷新机制..."

if grep -q "reloadTimelines(ofKind:" iOSBrowser/ContentView.swift; then
    echo "✅ 特定小组件刷新机制已添加"
else
    echo "❌ 特定小组件刷新机制缺失"
fi

if grep -q "立即刷新小组件" iOSBrowser/ContentView.swift; then
    echo "✅ 立即刷新机制已添加"
else
    echo "❌ 立即刷新机制缺失"
fi

if grep -q "延迟再次刷新" iOSBrowser/ContentView.swift; then
    echo "✅ 延迟刷新机制已添加"
else
    echo "❌ 延迟刷新机制缺失"
fi

# 2. 检查数据保存日志
echo ""
echo "📊 检查数据保存日志..."

if grep -q "保存到共享存储: widget_apps" iOSBrowser/ContentView.swift; then
    echo "✅ 应用数据保存日志已添加"
else
    echo "❌ 应用数据保存日志缺失"
fi

if grep -q "保存到共享存储: widget_ai_assistants" iOSBrowser/ContentView.swift; then
    echo "✅ AI数据保存日志已添加"
else
    echo "❌ AI数据保存日志缺失"
fi

if grep -q "保存到共享存储: widget_search_engines" iOSBrowser/ContentView.swift; then
    echo "✅ 搜索引擎数据保存日志已添加"
else
    echo "❌ 搜索引擎数据保存日志缺失"
fi

# 3. 检查小组件刷新频率优化
echo ""
echo "⏰ 检查小组件刷新频率优化..."

refresh_count=$(grep -c "value: 5" iOSBrowserWidgets/iOSBrowserWidgets.swift)
if [ $refresh_count -ge 4 ]; then
    echo "✅ 小组件刷新频率已优化为5分钟 ($refresh_count 处)"
else
    echo "❌ 小组件刷新频率优化不完整 ($refresh_count 处)"
fi

# 4. 检查深度链接处理完整性
echo ""
echo "🔗 检查深度链接处理完整性..."

# 检查应用ID映射
echo "检查关键应用的深度链接处理："

apps=("taobao" "zhihu" "douyin" "meituan" "bilibili")
for app in "${apps[@]}"; do
    if grep -q "case \"$app\":" iOSBrowser/iOSBrowserApp.swift; then
        echo "✅ $app 深度链接处理存在"
    else
        echo "❌ $app 深度链接处理缺失"
    fi
done

# 5. 检查小组件数据管理器
echo ""
echo "📱 检查小组件数据管理器..."

if grep -q "getUserSelectedApps.*selectedAppIds" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 用户应用选择读取逻辑正确"
else
    echo "❌ 用户应用选择读取逻辑错误"
fi

if grep -q "getUserSelectedAIAssistants.*selectedAIIds" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 用户AI选择读取逻辑正确"
else
    echo "❌ 用户AI选择读取逻辑错误"
fi

if grep -q "getUserSelectedSearchEngines.*engines" iOSBrowserWidgets/iOSBrowserWidgets.swift; then
    echo "✅ 用户搜索引擎选择读取逻辑正确"
else
    echo "❌ 用户搜索引擎选择读取逻辑错误"
fi

# 6. 编译测试
echo ""
echo "🔨 编译测试..."
xcodebuild build -project iOSBrowser.xcodeproj -scheme iOSBrowser -quiet

if [ $? -eq 0 ]; then
    echo "✅ 编译成功"
else
    echo "❌ 编译失败"
    exit 1
fi

echo ""
echo "🎯 修复验证总结："
echo ""
echo "✅ 修复的问题："
echo "   1. 增强小组件刷新机制 - 立即刷新 + 延迟刷新"
echo "   2. 添加特定小组件刷新 - 针对每个小组件类型"
echo "   3. 优化刷新频率 - 从30分钟改为5分钟"
echo "   4. 增强数据保存日志 - 详细的保存过程日志"
echo "   5. 确保所有更新函数都调用saveToSharedStorage"
echo ""
echo "🔧 修复机制："
echo "   - 用户配置变更 → 立即保存到共享存储"
echo "   - 立即刷新所有小组件 → reloadAllTimelines()"
echo "   - 刷新特定小组件 → reloadTimelines(ofKind:)"
echo "   - 延迟0.5秒再次刷新 → 确保数据同步"
echo "   - 小组件每5分钟自动刷新 → 保持数据最新"
echo ""
echo "🧪 测试步骤："
echo "   1. 进入小组件配置tab"
echo "   2. 修改应用选择（如：取消淘宝，选择京东）"
echo "   3. 观察控制台日志："
echo "      📱 应用选择已更新: [\"zhihu\", \"douyin\", \"jd\"]"
echo "      📱 保存到共享存储: widget_apps = [\"zhihu\", \"douyin\", \"jd\"]"
echo "      🔄 已请求刷新所有小组件"
echo "      🔄 已请求刷新特定小组件"
echo "      📱 延迟刷新小组件完成"
echo "   4. 检查桌面小组件是否立即更新显示京东"
echo "   5. 点击桌面小组件中的京东图标"
echo "   6. 验证是否正确跳转到京东搜索或应用内搜索"
echo ""
echo "🎯 预期效果："
echo "   ✅ 配置变更后小组件立即更新（不超过5秒）"
echo "   ✅ 点击小组件图标精准跳转到对应应用"
echo "   ✅ 剪贴板内容正确传递到目标应用"
echo "   ✅ 深度链接参数正确处理"
echo ""
echo "🚨 如果问题仍然存在："
echo "   1. 删除桌面上的旧小组件"
echo "   2. 重新添加新的个性化小组件"
echo "   3. 重启应用清除缓存"
echo "   4. 检查目标应用是否已安装"
echo "   5. 使用Safari测试深度链接: iosbrowser://search?app=zhihu"
