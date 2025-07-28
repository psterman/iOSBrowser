//
//  SimpleBatchView.swift
//  iOSBrowser
//
//  简化版批量操作功能
//

import SwiftUI

struct SimpleBatchView: View {
    let clipboardContent: String
    @State private var selectedEngines: Set<String> = ["google", "baidu"]
    @State private var selectedAIs: Set<String> = ["deepseek", "qwen"]
    @State private var isExecuting = false
    @Environment(\.presentationMode) var presentationMode
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 剪贴板内容
                VStack(alignment: .leading, spacing: 8) {
                    Text("剪贴板内容")
                        .font(.headline)
                    
                    Text(clipboardContent.isEmpty ? "暂无内容" : clipboardContent)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(maxHeight: 80)
                }
                
                // 搜索引擎选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择搜索引擎")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(searchEngines, id: \.0) { engine in
                            BatchToggleCard(
                                id: engine.0,
                                name: engine.1,
                                icon: engine.2,
                                color: engine.3,
                                isSelected: selectedEngines.contains(engine.0)
                            ) {
                                toggleEngine(engine.0)
                            }
                        }
                    }
                }
                
                // AI助手选择
                VStack(alignment: .leading, spacing: 12) {
                    Text("选择AI助手")
                        .font(.headline)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                        ForEach(aiAssistants, id: \.0) { ai in
                            BatchToggleCard(
                                id: ai.0,
                                name: ai.1,
                                icon: ai.2,
                                color: ai.3,
                                isSelected: selectedAIs.contains(ai.0)
                            ) {
                                toggleAI(ai.0)
                            }
                        }
                    }
                }
                
                // 执行按钮
                Button(action: executeBatch) {
                    HStack {
                        if isExecuting {
                            ProgressView()
                                .scaleEffect(0.8)
                        }
                        Text(isExecuting ? "执行中..." : "开始批量操作")
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(canExecute ? Color.blue : Color.gray)
                    .foregroundColor(.white)
                    .cornerRadius(10)
                }
                .disabled(!canExecute || isExecuting)
                
                Spacer()
            }
            .padding()
            .navigationTitle("批量操作")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarItems(
                leading: Button("取消") {
                    presentationMode.wrappedValue.dismiss()
                }
            )
        }
    }
    
    private let searchEngines = [
        ("google", "Google", "magnifyingglass", Color.blue),
        ("baidu", "百度", "globe.asia.australia", Color.blue),
        ("bing", "Bing", "globe", Color.green),
        ("duckduckgo", "DuckDuckGo", "shield", Color.orange)
    ]
    
    private let aiAssistants = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple),
        ("qwen", "通义千问", "cloud.fill", Color.cyan),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange)
    ]
    
    private var canExecute: Bool {
        !selectedEngines.isEmpty || !selectedAIs.isEmpty
    }
    
    private func toggleEngine(_ engineId: String) {
        if selectedEngines.contains(engineId) {
            selectedEngines.remove(engineId)
        } else {
            selectedEngines.insert(engineId)
        }
    }
    
    private func toggleAI(_ aiId: String) {
        if selectedAIs.contains(aiId) {
            selectedAIs.remove(aiId)
        } else {
            selectedAIs.insert(aiId)
        }
    }
    
    private func executeBatch() {
        isExecuting = true
        
        // 执行搜索操作
        for engine in selectedEngines {
            let url = "iosbrowser://clipboard-search?engine=\(engine)"
            if let searchURL = URL(string: url) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIApplication.shared.open(searchURL)
                }
            }
        }
        
        // 执行AI对话操作
        for ai in selectedAIs {
            let url = "iosbrowser://ai?assistant=\(ai)"
            if let aiURL = URL(string: url) {
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    UIApplication.shared.open(aiURL)
                }
            }
        }
        
        // 延迟关闭
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            isExecuting = false
            presentationMode.wrappedValue.dismiss()
        }
    }
}

// MARK: - 批量切换卡片
struct BatchToggleCard: View {
    let id: String
    let name: String
    let icon: String
    let color: Color
    let isSelected: Bool
    let onToggle: () -> Void
    
    var body: some View {
        Button(action: onToggle) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(color)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 8)
                    .fill(isSelected ? color.opacity(0.2) : Color(.systemGray6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(isSelected ? color : Color.clear, lineWidth: 2)
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}
