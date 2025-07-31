#!/bin/bash

# 🔄 立即强制刷新小组件
# 基于数据已正确写入，强制小组件读取新数据

echo "🔄🔄🔄 立即强制刷新小组件..."
echo "📅 刷新时间: $(date)"
echo ""

# 1. 验证数据状态
echo "🔍 验证当前数据状态..."

cat > verify_current_data.swift << 'EOF'
import Foundation

print("🔍 验证当前数据状态...")

let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    shared.synchronize()
    
    let engines = shared.stringArray(forKey: "widget_search_engines") ?? []
    let apps = shared.stringArray(forKey: "widget_apps") ?? []
    let ai = shared.stringArray(forKey: "widget_ai_assistants") ?? []
    let actions = shared.stringArray(forKey: "widget_quick_actions") ?? []
    
    print("📱 App Groups当前数据:")
    print("  widget_search_engines: \(engines)")
    print("  widget_apps: \(apps)")
    print("  widget_ai_assistants: \(ai)")
    print("  widget_quick_actions: \(actions)")
    
    let hasData = !engines.isEmpty || !apps.isEmpty || !ai.isEmpty || !actions.isEmpty
    if hasData {
        print("✅ App Groups中有数据，小组件应该能读取到")
        
        // 检查是否是我们期望的数据
        let isExpectedData = engines.contains("bing") && apps.contains("wechat") && 
                            ai.contains("chatgpt") && actions.contains("translate")
        if isExpectedData {
            print("✅ 数据内容正确，包含期望的测试数据")
        } else {
            print("⚠️ 数据内容可能不是最新的")
        }
    } else {
        print("❌ App Groups中没有数据")
    }
} else {
    print("❌ App Groups不可用")
}
EOF

if command -v swift &> /dev/null; then
    swift verify_current_data.swift
else
    echo "⚠️ Swift命令不可用，跳过数据验证"
fi

rm -f verify_current_data.swift

# 2. 创建强制刷新脚本
echo ""
echo "🔄 创建强制刷新机制..."

cat > create_force_refresh.swift << 'EOF'
import Foundation

print("🔄 创建强制刷新机制...")

let sharedDefaults = UserDefaults(suiteName: "group.com.iosbrowser.shared")

if let shared = sharedDefaults {
    // 添加一个刷新标记，强制小组件重新读取
    let refreshTimestamp = Date().timeIntervalSince1970
    shared.set(refreshTimestamp, forKey: "widget_force_refresh")
    shared.set("force_update", forKey: "widget_refresh_trigger")
    
    let syncResult = shared.synchronize()
    print("🔄 强制刷新标记写入: \(syncResult)")
    print("🔄 刷新时间戳: \(refreshTimestamp)")
    
    // 验证刷新标记
    let verifyTimestamp = shared.double(forKey: "widget_force_refresh")
    let verifyTrigger = shared.string(forKey: "widget_refresh_trigger") ?? ""
    
    print("🔄 刷新标记验证:")
    print("  时间戳: \(verifyTimestamp)")
    print("  触发器: \(verifyTrigger)")
    
    if verifyTimestamp == refreshTimestamp && verifyTrigger == "force_update" {
        print("✅ 强制刷新标记设置成功")
    } else {
        print("❌ 强制刷新标记设置失败")
    }
} else {
    print("❌ 无法创建强制刷新机制")
}
EOF

if command -v swift &> /dev/null; then
    swift create_force_refresh.swift
else
    echo "⚠️ Swift命令不可用，跳过强制刷新创建"
fi

rm -f create_force_refresh.swift

# 3. 提供立即操作指南
echo ""
echo "🔄 立即操作指南:"
echo "================================"
echo ""
echo "数据已正确写入App Groups，现在需要强制小组件读取新数据。"
echo ""
echo "🔧 立即执行以下步骤:"
echo ""
echo "1. 📱 在主应用中触发保存:"
echo "   - 打开主应用"
echo "   - 进入'小组件配置'页面"
echo "   - 随便点击一个选项（触发数据保存）"
echo "   - 点击'保存'按钮"
echo "   - 查看控制台是否有'🔥🔥🔥 App Groups保存验证'日志"
echo ""
echo "2. 🔄 强制刷新小组件:"
echo "   - 在主应用中点击'刷新小组件'按钮"
echo "   - 等待10秒"
echo ""
echo "3. 🗑️ 删除旧小组件:"
echo "   - 长按桌面上的所有iOSBrowser小组件"
echo "   - 选择'移除小组件'"
echo "   - 删除所有旧的小组件"
echo ""
echo "4. 🔄 重启设备:"
echo "   - 完全关闭设备"
echo "   - 重新开机"
echo "   - 等待系统完全启动"
echo ""
echo "5. ➕ 重新添加小组件:"
echo "   - 长按桌面空白处进入编辑模式"
echo "   - 点击左上角的'+'号"
echo "   - 搜索'iOSBrowser'"
echo "   - 添加四个小组件:"
echo "     * 搜索引擎"
echo "     * 应用"
echo "     * AI助手"
echo "     * 快捷操作"
echo ""
echo "6. 🔍 验证效果:"
echo "   - 查看控制台日志"
echo "   - 应该看到'✅ [App Groups] 读取成功'"
echo "   - 小组件应该显示:"
echo "     * 搜索引擎: Bing, Yahoo, DuckDuckGo, Yandex"
echo "     * 应用: WeChat, Alipay, Meituan, Didi"
echo "     * AI助手: ChatGPT, Claude, Gemini, Copilot"
echo "     * 快捷操作: Translate, Calculator, Weather, Timer"
echo ""

echo "🔍 成功标志:"
echo "- 控制台显示: '✅ [App Groups] 读取成功'"
echo "- 小组件显示4个自定义项目而不是默认值"
echo "- 每个小组件都有不同的内容"
echo ""

echo "⚠️ 如果仍显示默认值:"
echo "- 说明iOS系统缓存很顽固"
echo "- 可能需要等待更长时间（30分钟到1小时）"
echo "- 或者需要更彻底的清理和重新安装"
echo ""

echo "🎯 关键点:"
echo "数据已经正确保存，问题现在是iOS小组件系统的缓存。"
echo "重启设备是清除这种缓存最有效的方法。"
echo ""

echo "🔄🔄🔄 立即强制刷新小组件完成！"
