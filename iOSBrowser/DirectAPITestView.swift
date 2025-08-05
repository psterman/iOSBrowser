//
//  DirectAPITestView.swift
//  iOSBrowser
//
//  直接测试DeepSeek API调用
//

import SwiftUI

struct DirectAPITestView: View {
    @StateObject private var apiManager = APIConfigManager.shared
    @State private var testMessage = "你好，请介绍一下你自己"
    @State private var apiResponse = ""
    @State private var isLoading = false
    @State private var testResults: [String] = []
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 20) {
                    // 标题
                    VStack(spacing: 12) {
                        Image(systemName: "network")
                            .font(.system(size: 60))
                            .foregroundColor(.blue)
                        
                        Text("🔧 直接API测试")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                        
                        Text("绕过所有中间层，直接测试DeepSeek API")
                            .font(.headline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .background(Color.blue.opacity(0.1))
                    .cornerRadius(16)
                    
                    // API配置状态
                    VStack(alignment: .leading, spacing: 12) {
                        Text("🔑 API配置")
                            .font(.headline)
                        
                        HStack {
                            Text("DeepSeek API密钥:")
                            Spacer()
                            if apiManager.hasAPIKey(for: "deepseek") {
                                Text("✅ 已配置")
                                    .foregroundColor(.green)
                            } else {
                                Text("❌ 未配置")
                                    .foregroundColor(.red)
                            }
                        }
                        
                        if let apiKey = apiManager.getAPIKey(for: "deepseek") {
                            Text("密钥预览: \(apiKey.prefix(10))...")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // 测试输入
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📝 测试消息")
                            .font(.headline)
                        
                        TextField("输入测试消息", text: $testMessage, axis: .vertical)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .lineLimit(3...6)
                        
                        Button(action: {
                            directAPITest()
                        }) {
                            HStack {
                                if isLoading {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "play.circle.fill")
                                }
                                Text("直接调用DeepSeek API")
                            }
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(apiManager.hasAPIKey(for: "deepseek") ? Color.blue : Color.gray)
                            .foregroundColor(.white)
                            .cornerRadius(10)
                        }
                        .disabled(!apiManager.hasAPIKey(for: "deepseek") || isLoading)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    
                    // API响应
                    if !apiResponse.isEmpty {
                        VStack(alignment: .leading, spacing: 12) {
                            Text("📥 API响应")
                                .font(.headline)
                            
                            ScrollView {
                                Text(apiResponse)
                                    .font(.subheadline)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                                    .background(Color(.systemGray5))
                                    .cornerRadius(8)
                            }
                            .frame(maxHeight: 200)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 测试日志
                    if !testResults.isEmpty {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("📋 测试日志")
                                .font(.headline)
                            
                            ScrollView {
                                VStack(alignment: .leading, spacing: 4) {
                                    ForEach(testResults, id: \.self) { result in
                                        Text(result)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                    }
                                }
                            }
                            .frame(maxHeight: 150)
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .cornerRadius(12)
                    }
                    
                    // 历史记录测试
                    VStack(alignment: .leading, spacing: 12) {
                        Text("📚 历史记录测试")
                            .font(.headline)
                        
                        Button("测试历史记录保存") {
                            testHistoryRecord()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("查看DeepSeek历史记录") {
                            viewHistoryRecord()
                        }
                        .buttonStyle(.bordered)
                        
                        Button("清除历史记录") {
                            clearHistoryRecord()
                        }
                        .buttonStyle(.bordered)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                }
                .padding()
            }
            .navigationTitle("API直接测试")
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            addTestResult("🔧 直接API测试界面已加载")
        }
    }
    
    private func directAPITest() {
        guard let apiKey = apiManager.getAPIKey(for: "deepseek"), !apiKey.isEmpty else {
            addTestResult("❌ 没有找到DeepSeek API密钥")
            return
        }
        
        isLoading = true
        apiResponse = ""
        addTestResult("🚀 开始直接API测试...")
        addTestResult("🔑 使用API密钥: \(apiKey.prefix(10))...")
        addTestResult("📤 发送消息: \(testMessage)")
        
        guard let url = URL(string: "https://api.deepseek.com/v1/chat/completions") else {
            addTestResult("❌ 无效的API端点")
            isLoading = false
            return
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        
        let requestBody: [String: Any] = [
            "model": "deepseek-chat",
            "messages": [
                ["role": "user", "content": testMessage]
            ],
            "stream": false
        ]
        
        addTestResult("📋 请求体: \(requestBody)")
        
        do {
            request.httpBody = try JSONSerialization.data(withJSONObject: requestBody)
            addTestResult("✅ 请求体编码成功")
        } catch {
            addTestResult("❌ 请求体编码失败: \(error)")
            isLoading = false
            return
        }
        
        addTestResult("🌐 发送网络请求...")
        
        URLSession.shared.dataTask(with: request) { [weak self] data, response, error in
            DispatchQueue.main.async {
                self?.isLoading = false
                
                if let error = error {
                    self?.addTestResult("❌ 网络错误: \(error.localizedDescription)")
                    return
                }
                
                if let httpResponse = response as? HTTPURLResponse {
                    self?.addTestResult("📊 HTTP状态码: \(httpResponse.statusCode)")
                }
                
                guard let data = data else {
                    self?.addTestResult("❌ 未收到响应数据")
                    return
                }
                
                self?.addTestResult("📄 响应数据大小: \(data.count) bytes")
                
                if let responseString = String(data: data, encoding: .utf8) {
                    self?.addTestResult("📄 原始响应: \(responseString)")
                    
                    // 解析响应
                    do {
                        if let json = try JSONSerialization.jsonObject(with: data) as? [String: Any] {
                            if let error = json["error"] as? [String: Any],
                               let message = error["message"] as? String {
                                self?.addTestResult("❌ API错误: \(message)")
                                self?.apiResponse = "API错误: \(message)"
                            } else if let choices = json["choices"] as? [[String: Any]],
                                      let firstChoice = choices.first,
                                      let message = firstChoice["message"] as? [String: Any],
                                      let content = message["content"] as? String {
                                self?.addTestResult("✅ API响应成功")
                                self?.apiResponse = content
                            } else {
                                self?.addTestResult("❌ 响应格式错误")
                                self?.apiResponse = responseString
                            }
                        }
                    } catch {
                        self?.addTestResult("❌ JSON解析失败: \(error)")
                        self?.apiResponse = responseString
                    }
                }
            }
        }.resume()
    }
    
    private func testHistoryRecord() {
        addTestResult("📚 测试历史记录保存...")
        
        let testMessage = ChatMessage(
            id: UUID().uuidString,
            content: "这是一条测试消息",
            isFromUser: true,
            timestamp: Date(),
            status: .sent,
            actions: [],
            isHistorical: false,
            aiSource: nil
        )
        
        let key = "chat_history_deepseek"
        if let data = try? JSONEncoder().encode([testMessage]) {
            UserDefaults.standard.set(data, forKey: key)
            UserDefaults.standard.synchronize()
            addTestResult("✅ 历史记录保存成功")
            
            // 验证读取
            if let savedData = UserDefaults.standard.data(forKey: key),
               let savedMessages = try? JSONDecoder().decode([ChatMessage].self, from: savedData) {
                addTestResult("✅ 历史记录读取成功，共 \(savedMessages.count) 条")
            } else {
                addTestResult("❌ 历史记录读取失败")
            }
        } else {
            addTestResult("❌ 历史记录保存失败")
        }
    }
    
    private func viewHistoryRecord() {
        let key = "chat_history_deepseek"
        if let data = UserDefaults.standard.data(forKey: key),
           let messages = try? JSONDecoder().decode([ChatMessage].self, from: data) {
            addTestResult("📚 DeepSeek历史记录: \(messages.count) 条消息")
            for (index, message) in messages.enumerated() {
                addTestResult("  \(index + 1). \(message.isFromUser ? "用户" : "AI"): \(message.content.prefix(30))...")
            }
        } else {
            addTestResult("📚 没有找到DeepSeek历史记录")
        }
    }
    
    private func clearHistoryRecord() {
        let key = "chat_history_deepseek"
        UserDefaults.standard.removeObject(forKey: key)
        UserDefaults.standard.synchronize()
        addTestResult("🗑️ 已清除DeepSeek历史记录")
    }
    
    private func addTestResult(_ result: String) {
        testResults.append(result)
        print(result)
    }
}

struct DirectAPITestView_Previews: PreviewProvider {
    static var previews: some View {
        DirectAPITestView()
    }
}
