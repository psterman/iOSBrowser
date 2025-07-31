#!/bin/bash

# 测试增强调试版本的脚本

echo "🔍🔍🔍 测试增强调试版本 🔍🔍🔍"

echo "1. 验证增强调试功能..."

echo "1.1 检查toggleSearchEngine增强调试:"
if grep -A 10 "toggleSearchEngine.*调用完成" iOSBrowser/ContentView.swift | grep -q "验证保存结果"; then
    echo "✅ toggleSearchEngine已添加保存验证"
else
    echo "❌ toggleSearchEngine未添加保存验证"
fi

echo ""
echo "1.2 检查toggleApp增强调试:"
if grep -A 10 "toggleApp.*调用完成" iOSBrowser/ContentView.swift | grep -q "验证保存结果"; then
    echo "✅ toggleApp已添加保存验证"
else
    echo "❌ toggleApp未添加保存验证"
fi

echo ""
echo "2. 测试指南..."

echo "📱 详细测试步骤:"
echo ""
echo "步骤1: 准备测试环境"
echo "   1. 在Xcode中编译并运行应用"
echo "   2. 打开Xcode的控制台（View → Debug Area → Activate Console）"
echo "   3. 在控制台搜索框中输入 '🔥🔥🔥' 来过滤相关日志"

echo ""
echo "步骤2: 测试搜索引擎勾选"
echo "   1. 进入小组件配置页面"
echo "   2. 点击'搜索引擎'tab"
echo "   3. 点击一个搜索引擎进行勾选/取消勾选"
echo "   4. 观察控制台日志"

echo ""
echo "步骤3: 观察预期日志"
echo "   应该看到以下日志序列:"
echo "   🔥🔥🔥 toggleSearchEngine 被调用: [引擎名称]"
echo "   🔥🔥🔥 当前dataSyncCenter.selectedSearchEngines: [当前列表]"
echo "   🔥🔥🔥 添加/移除搜索引擎: [引擎名称], 新列表: [新列表]"
echo "   🔥🔥🔥 准备调用 dataSyncCenter.updateSearchEngineSelection: [新列表]"
echo "   🔥🔥🔥 dataSyncCenter.updateSearchEngineSelection 调用完成"
echo "   🔥 DataSyncCenter.updateSearchEngineSelection 被调用: [新列表]"
echo "   🔥 立即同步到小组件开始..."
echo "   🔥 数据已设置到UserDefaults，开始同步..."
echo "   🔥 UserDefaults同步结果: true"
echo "   🔥🔥🔥 验证保存结果: iosbrowser_engines = [保存的数据]"
echo "   🔥🔥🔥 ✅ 数据保存成功！"

echo ""
echo "步骤4: 测试应用勾选"
echo "   1. 点击'应用'tab"
echo "   2. 点击一个应用进行勾选/取消勾选"
echo "   3. 观察控制台日志"
echo "   4. 应该看到类似的日志序列，但是针对应用数据"

echo ""
echo "3. 问题诊断..."

echo "🔍 如果看不到任何日志:"
echo "   ❌ 问题: toggle方法没有被调用"
echo "   🔧 可能原因:"
echo "      - 按钮点击事件没有绑定到toggle方法"
echo "      - UI响应有问题"
echo "      - 应用崩溃或卡死"

echo ""
echo "🔍 如果看到toggle日志但没有update日志:"
echo "   ❌ 问题: DataSyncCenter.updateXXXSelection没有被调用"
echo "   🔧 可能原因:"
echo "      - dataSyncCenter实例有问题"
echo "      - 方法调用失败"

echo ""
echo "🔍 如果看到update日志但没有保存日志:"
echo "   ❌ 问题: immediateSyncToWidgets或保存方法有问题"
echo "   🔧 可能原因:"
echo "      - 保存方法内部错误"
echo "      - UserDefaults访问权限问题"

echo ""
echo "🔍 如果看到保存日志但验证失败:"
echo "   ❌ 问题: 数据保存了但读取不到"
echo "   🔧 可能原因:"
echo "      - UserDefaults同步延迟"
echo "      - 键名不匹配"
echo "      - 数据格式问题"

echo ""
echo "4. 成功标志..."

echo "✅ 成功的完整日志流程:"
echo "   1. 用户点击 → toggle方法被调用"
echo "   2. toggle方法 → updateXXXSelection被调用"
echo "   3. updateXXXSelection → immediateSyncToWidgets被调用"
echo "   4. immediateSyncToWidgets → saveToWidgetAccessibleLocationFromDataSyncCenter被调用"
echo "   5. 保存方法 → UserDefaults.synchronize()返回true"
echo "   6. 验证 → 读取到正确的保存数据"

echo ""
echo "✅ 如果所有步骤都成功:"
echo "   - 数据应该被正确保存到UserDefaults"
echo "   - 小组件应该能读取到用户选择的数据"
echo "   - 下次添加小组件时应该显示用户配置而不是默认数据"

echo ""
echo "5. 进一步测试..."

echo "📱 小组件验证:"
echo "   1. 在完成上述测试后"
echo "   2. 添加一个小组件到桌面"
echo "   3. 观察小组件是否显示用户选择的数据"
echo "   4. 如果仍显示默认数据，检查小组件的读取日志"

echo ""
echo "📱 数据持久性测试:"
echo "   1. 完全关闭应用"
echo "   2. 重新启动应用"
echo "   3. 检查用户的选择是否被保留"
echo "   4. 再次添加小组件验证"

echo ""
echo "🔍🔍🔍 测试指南完成 🔍🔍🔍"

echo ""
echo "💡 关键提示:"
echo "   这个增强调试版本会在每次用户操作后验证数据是否真正保存成功，"
echo "   通过观察日志可以精确定位问题出现在哪个环节，"
echo "   从而快速解决数据不保存的问题！"
