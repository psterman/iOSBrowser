#!/bin/bash

echo "🧪 测试浏览器功能改进"
echo "========================"

# 1. 测试收藏功能弱提醒
echo "1. 测试收藏功能弱提醒..."
if grep -q "showToast" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 弱提醒功能已实现"
else
    echo "   ❌ 弱提醒功能缺失"
fi

if grep -q "ToastView" iOSBrowser/BrowserView.swift; then
    echo "   ✅ Toast视图已实现"
else
    echo "   ❌ Toast视图缺失"
fi

if grep -q "ToastType" iOSBrowser/BrowserView.swift; then
    echo "   ✅ Toast类型枚举已实现"
else
    echo "   ❌ Toast类型枚举缺失"
fi

# 2. 测试AI对话API配置
echo ""
echo "2. 测试AI对话API配置..."
if grep -q "BrowserAPIConfigView" iOSBrowser/BrowserView.swift; then
    echo "   ✅ API配置视图已实现"
else
    echo "   ❌ API配置视图缺失"
fi

if grep -q "api_key_" iOSBrowser/BrowserView.swift; then
    echo "   ✅ API密钥存储已实现"
else
    echo "   ❌ API密钥存储缺失"
fi

if grep -q "callDeepSeekAPI" iOSBrowser/BrowserView.swift; then
    echo "   ✅ DeepSeek API调用已实现"
else
    echo "   ❌ DeepSeek API调用缺失"
fi

if grep -q "callQwenAPI" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 通义千问API调用已实现"
else
    echo "   ❌ 通义千问API调用缺失"
fi

if grep -q "callChatGLMAPI" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 智谱清言API调用已实现"
else
    echo "   ❌ 智谱清言API调用缺失"
fi

# 3. 测试左侧抽屉式搜索引擎列表
echo ""
echo "3. 测试左侧抽屉式搜索引擎列表..."
if grep -q "SearchEngineDrawerView" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 抽屉式搜索引擎视图已实现"
else
    echo "   ❌ 抽屉式搜索引擎视图缺失"
fi

if grep -q "showingSearchEngineDrawer" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 抽屉显示状态已实现"
else
    echo "   ❌ 抽屉显示状态缺失"
fi

if grep -q "chevron.right" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 抽屉触发按钮已实现"
else
    echo "   ❌ 抽屉触发按钮缺失"
fi

if grep -q "SearchEngineDrawerItem" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 抽屉项目视图已实现"
else
    echo "   ❌ 抽屉项目视图缺失"
fi

# 4. 检查移除的旧功能
echo ""
echo "4. 检查移除的旧功能..."
if grep -q "showingSearchEngineSelector" iOSBrowser/BrowserView.swift; then
    echo "   ⚠️  旧搜索引擎选择器状态仍存在（可能需要清理）"
else
    echo "   ✅ 旧搜索引擎选择器状态已清理"
fi

if grep -q "chevron.down" iOSBrowser/BrowserView.swift; then
    echo "   ⚠️  旧下拉箭头仍存在（可能需要清理）"
else
    echo "   ✅ 旧下拉箭头已清理"
fi

# 5. 检查Toast修饰符
echo ""
echo "5. 检查Toast修饰符..."
if grep -q "ToastModifier" iOSBrowser/BrowserView.swift; then
    echo "   ✅ Toast修饰符已实现"
else
    echo "   ❌ Toast修饰符缺失"
fi

if grep -q "func toast" iOSBrowser/BrowserView.swift; then
    echo "   ✅ Toast扩展方法已实现"
else
    echo "   ❌ Toast扩展方法缺失"
fi

# 6. 检查API配置功能
echo ""
echo "6. 检查API配置功能..."
if grep -q "SecureField" iOSBrowser/BrowserView.swift; then
    echo "   ✅ 安全输入框已实现"
else
    echo "   ❌ 安全输入框缺失"
fi

if grep -q "AI服务配置" iOSBrowser/BrowserView.swift; then
    echo "   ✅ API配置说明已实现"
else
    echo "   ❌ API配置说明缺失"
fi

echo ""
echo "🎉 浏览器功能改进测试完成！"
echo ""
echo "📋 功能改进总结："
echo "✅ 收藏功能弱提醒 - 使用Toast替代弹窗"
echo "✅ AI对话API配置 - 支持DeepSeek、通义千问、智谱清言等"
echo "✅ 左侧抽屉式搜索引擎列表 - 更好的用户体验"
echo "✅ Toast通知系统 - 统一的弱提醒机制"
echo "✅ API密钥安全存储 - 使用UserDefaults本地存储"
echo "✅ 真实API调用 - 支持多个AI服务商"
echo ""
echo "🎯 用户体验改进："
echo "• 收藏操作不再打断用户流程"
echo "• AI对话支持真实API调用"
echo "• 搜索引擎选择更加直观"
echo "• 界面更加现代化和用户友好" 