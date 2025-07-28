//
//  BatchOperationView.swift
//  iOSBrowser
//
//  批量操作功能 - 支持多引擎搜索和多AI对话
//

import SwiftUI

struct BatchOperationView: View {
    let clipboardContent: String
    @State private var selectedSearchEngines: Set<String> = []
    @State private var selectedAIAssistants: Set<String> = []
    @State private var operationType: BatchOperationType = .search
    @State private var isExecuting = false
    @State private var results: [BatchResult] = []
    @Environment(\.presentationMode) var presentationMode
    
    enum BatchOperationType: String, CaseIterable {
        case search = "多引擎搜索"
        case ai = "多AI对话"
        case mixed = "混合操作"
    }
    
    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                // 剪贴板内容显示
                VStack(alignment: .leading, spacing: 8) {
                    Text("剪贴板内容")
                        .font(.headline)
                    
                    Text(clipboardContent)
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(8)
                        .frame(maxHeight: 100)
                }
                
                // 操作类型选择
                Picker("操作类型", selection: $operationType) {
                    ForEach(BatchOperationType.allCases, id: \.self) { type in
                        Text(type.rawValue).tag(type)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())
                
                // 搜索引擎选择
                if operationType == .search || operationType == .mixed {
                    SearchEngineSelectionView(selectedEngines: $selectedSearchEngines)
                }
                
                // AI助手选择
                if operationType == .ai || operationType == .mixed {
                    AIAssistantSelectionView(selectedAssistants: $selectedAIAssistants)
                }
                
                // 执行按钮
                Button(action: executeBatchOperation) {
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
                
                // 结果显示
                if !results.isEmpty {
                    BatchResultsView(results: results)
                }
                
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
    
    private var canExecute: Bool {
        switch operationType {
        case .search:
            return !selectedSearchEngines.isEmpty
        case .ai:
            return !selectedAIAssistants.isEmpty
        case .mixed:
            return !selectedSearchEngines.isEmpty || !selectedAIAssistants.isEmpty
        }
    }
    
    private func executeBatchOperation() {
        isExecuting = true
        results.removeAll()
        
        Task {
            // 执行搜索操作
            if operationType == .search || operationType == .mixed {
                await executeSearchOperations()
            }
            
            // 执行AI对话操作
            if operationType == .ai || operationType == .mixed {
                await executeAIOperations()
            }
            
            DispatchQueue.main.async {
                isExecuting = false
            }
        }
    }
    
    private func executeSearchOperations() async {
        for engineId in selectedSearchEngines {
            let result = await performSearch(engine: engineId, query: clipboardContent)
            DispatchQueue.main.async {
                results.append(result)
            }
        }
    }
    
    private func executeAIOperations() async {
        for assistantId in selectedAIAssistants {
            let result = await performAIChat(assistant: assistantId, prompt: clipboardContent)
            DispatchQueue.main.async {
                results.append(result)
            }
        }
    }
    
    private func performSearch(engine: String, query: String) async -> BatchResult {
        // 模拟搜索操作
        try? await Task.sleep(nanoseconds: 1_000_000_000) // 1秒延迟
        
        let url = "iosbrowser://search?engine=\(engine)&query=\(query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // 实际执行搜索
        DispatchQueue.main.async {
            if let searchURL = URL(string: url) {
                NotificationCenter.default.post(name: .openURL, object: searchURL)
            }
        }
        
        return BatchResult(
            type: .search,
            target: getEngineName(engine),
            status: .success,
            url: url,
            timestamp: Date()
        )
    }
    
    private func performAIChat(assistant: String, prompt: String) async -> BatchResult {
        // 模拟AI对话操作
        try? await Task.sleep(nanoseconds: 1_500_000_000) // 1.5秒延迟
        
        let url = "iosbrowser://ai?assistant=\(assistant)&prompt=\(prompt.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")"
        
        // 实际执行AI对话
        DispatchQueue.main.async {
            if let chatURL = URL(string: url) {
                NotificationCenter.default.post(name: .openURL, object: chatURL)
            }
        }
        
        return BatchResult(
            type: .ai,
            target: getAssistantName(assistant),
            status: .success,
            url: url,
            timestamp: Date()
        )
    }
    
    private func getEngineName(_ id: String) -> String {
        let mapping = ["google": "Google", "baidu": "百度", "bing": "Bing", "duckduckgo": "DuckDuckGo"]
        return mapping[id] ?? id
    }
    
    private func getAssistantName(_ id: String) -> String {
        let mapping = ["deepseek": "DeepSeek", "qwen": "通义千问", "chatglm": "智谱清言", "moonshot": "Kimi"]
        return mapping[id] ?? id
    }
}

// MARK: - 搜索引擎选择视图
struct SearchEngineSelectionView: View {
    @Binding var selectedEngines: Set<String>
    
    private let engines = [
        ("google", "Google", "magnifyingglass", Color.blue),
        ("baidu", "百度", "globe.asia.australia", Color.blue),
        ("bing", "Bing", "globe", Color.green),
        ("duckduckgo", "DuckDuckGo", "shield", Color.orange)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("选择搜索引擎")
                    .font(.headline)
                Spacer()
                Button(selectedEngines.count == engines.count ? "取消全选" : "全选") {
                    if selectedEngines.count == engines.count {
                        selectedEngines.removeAll()
                    } else {
                        selectedEngines = Set(engines.map { $0.0 })
                    }
                }
                .font(.caption)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(engines, id: \.0) { engine in
                    BatchSelectionCard(
                        id: engine.0,
                        name: engine.1,
                        icon: engine.2,
                        color: engine.3,
                        isSelected: selectedEngines.contains(engine.0)
                    ) {
                        if selectedEngines.contains(engine.0) {
                            selectedEngines.remove(engine.0)
                        } else {
                            selectedEngines.insert(engine.0)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - AI助手选择视图
struct AIAssistantSelectionView: View {
    @Binding var selectedAssistants: Set<String>
    
    private let assistants = [
        ("deepseek", "DeepSeek", "brain.head.profile", Color.purple),
        ("qwen", "通义千问", "cloud.fill", Color.cyan),
        ("chatglm", "智谱清言", "lightbulb.fill", Color.yellow),
        ("moonshot", "Kimi", "moon.stars.fill", Color.orange)
    ]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("选择AI助手")
                    .font(.headline)
                Spacer()
                Button(selectedAssistants.count == assistants.count ? "取消全选" : "全选") {
                    if selectedAssistants.count == assistants.count {
                        selectedAssistants.removeAll()
                    } else {
                        selectedAssistants = Set(assistants.map { $0.0 })
                    }
                }
                .font(.caption)
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 8) {
                ForEach(assistants, id: \.0) { assistant in
                    BatchSelectionCard(
                        id: assistant.0,
                        name: assistant.1,
                        icon: assistant.2,
                        color: assistant.3,
                        isSelected: selectedAssistants.contains(assistant.0)
                    ) {
                        if selectedAssistants.contains(assistant.0) {
                            selectedAssistants.remove(assistant.0)
                        } else {
                            selectedAssistants.insert(assistant.0)
                        }
                    }
                }
            }
        }
    }
}

// MARK: - 批量选择卡片
struct BatchSelectionCard: View {
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
                    .font(.system(size: 20))
                    .foregroundColor(color)
                
                Text(name)
                    .font(.caption)
                    .fontWeight(.medium)
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

// MARK: - 批量结果视图
struct BatchResultsView: View {
    let results: [BatchResult]
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("执行结果")
                .font(.headline)
            
            ScrollView {
                LazyVStack(spacing: 4) {
                    ForEach(results, id: \.id) { result in
                        BatchResultRow(result: result)
                    }
                }
            }
            .frame(maxHeight: 200)
        }
    }
}

struct BatchResultRow: View {
    let result: BatchResult
    
    var body: some View {
        HStack {
            Image(systemName: result.type == .search ? "magnifyingglass" : "brain.head.profile")
                .foregroundColor(result.status == .success ? .green : .red)
            
            VStack(alignment: .leading, spacing: 2) {
                Text(result.target)
                    .font(.caption)
                    .fontWeight(.medium)
                
                Text(result.status == .success ? "成功" : "失败")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            Text(DateFormatter.timeFormatter.string(from: result.timestamp))
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 4)
        .background(Color(.systemGray6))
        .cornerRadius(6)
    }
}

// MARK: - 数据模型
struct BatchResult {
    let id = UUID()
    let type: BatchOperationType
    let target: String
    let status: BatchStatus
    let url: String
    let timestamp: Date
    
    enum BatchOperationType {
        case search
        case ai
    }
    
    enum BatchStatus {
        case success
        case failure
    }
}

// MARK: - 扩展
extension DateFormatter {
    static let timeFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.timeStyle = .short
        return formatter
    }()
}

extension Notification.Name {
    static let openURL = Notification.Name("openURL")
}
