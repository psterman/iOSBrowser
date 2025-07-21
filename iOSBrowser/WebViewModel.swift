import SwiftUI
import WebKit
import Combine
import Foundation
import AVFoundation

// Define the data structure for an AI Provider
struct AIProvider {
    var id: String
    var name: String
    var model: String
    var endpoint: String
    var apiKey: String?
}

class WebViewModel: NSObject, ObservableObject, WKNavigationDelegate, WKScriptMessageHandler, WKUIDelegate, URLSessionDataDelegate {
    let webView: WKWebView
    private var cancellables = Set<AnyCancellable>()

    @Published var urlString: String?
    @Published var canGoBack: Bool = false
    @Published var canGoForward: Bool = false
    @Published var isLoading: Bool = false
    @Published var isUIVisible: Bool = true

    private var urlSession: URLSession!
    private var streamingMessageContent: String = ""
    private var streamingMessageId: String = ""

    // Define the AI providers/engines
    private var providers: [String: AIProvider] = [
        "deepseek": AIProvider(id: "deepseek", name: "DeepSeek", model: "deepseek-chat", endpoint: "https://api.deepseek.com/chat/completions"),
        "openai": AIProvider(id: "openai", name: "OpenAI", model: "gpt-4o", endpoint: "https://api.openai.com/v1/chat/completions"),
        "groq": AIProvider(id: "groq", name: "Groq", model: "llama3-70b-8192", endpoint: "https://api.groq.com/openai/v1/chat/completions")
    ]

    private var activeStreamingSession: (URLSessionDataTask, String)?

    override init() {
        let preferences = WKPreferences()
        preferences.javaScriptCanOpenWindowsAutomatically = true
        
        let configuration = WKWebViewConfiguration()
        configuration.preferences = preferences
        
        self.webView = WKWebView(frame: .zero, configuration: configuration)
        super.init()

        self.urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: nil)

        // Set delegates
        self.webView.navigationDelegate = self
        self.webView.uiDelegate = self
        
        // Setup message handlers
        let contentController = self.webView.configuration.userContentController
        contentController.add(self, name: "apiKeyHandler")
        contentController.add(self, name: "apiRequestHandler")
        contentController.add(self, name: "permissionHandler")
        
        // Load API Keys from UserDefaults
        loadApiKeys()
        
        setupBindings()
        
        // Load the local chat.html file by default
        loadChatFile()
    }

    private func setupBindings() {
        webView.publisher(for: \.canGoBack)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canGoBack)

        webView.publisher(for: \.canGoForward)
            .receive(on: DispatchQueue.main)
            .assign(to: &$canGoForward)
        
        webView.publisher(for: \.isLoading)
            .receive(on: DispatchQueue.main)
            .assign(to: &$isLoading)
        
        webView.publisher(for: \.url)
            .receive(on: DispatchQueue.main)
            .map { $0?.absoluteString }
            .assign(to: &$urlString)
    }

    func loadUrl(_ urlString: String?) {
        guard let urlString = urlString, let url = URL(string: urlString) else {
            self.urlString = nil
            return
        }
        let request = URLRequest(url: url)
        webView.load(request)
    }

    private func loadChatFile() {
        guard let url = Bundle.main.url(forResource: "chat", withExtension: "html") else {
            print("Error: chat.html not found in bundle.")
            return
        }
        webView.loadFileURL(url, allowingReadAccessTo: url.deletingLastPathComponent())
    }

    func goBack() {
        webView.goBack()
    }

    func goForward() {
        webView.goForward()
    }
    
    // MARK: - WKScriptMessageHandler
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        guard let body = message.body as? [String: Any] else {
            print("Could not parse message body")
            return
        }

        switch message.name {
        case "apiKeyHandler":
            guard let engineId = body["engineId"] as? String,
                  let apiKey = body["apiKey"] as? String else { return }
            
            if providers[engineId] != nil {
                UserDefaults.standard.set(apiKey, forKey: "apiKey_\(engineId)")
                providers[engineId]?.apiKey = apiKey // Update local cache
                print("API Key for \(engineId) saved.")
            }

        case "apiRequestHandler":
            guard let engineId = body["engineId"] as? String,
                  let messages = body["messages"] as? [[String: String]] else {
                DispatchQueue.main.async { self.callJavaScript(function: "renderErrorMessage", args: "Invalid request format from JS.") }
                return
            }

            guard let provider = providers[engineId],
                  let apiKey = UserDefaults.standard.string(forKey: "apiKey_\(engineId)"), !apiKey.isEmpty else {
                DispatchQueue.main.async { self.callJavaScript(function: "renderErrorMessage", args: "API Key for \(engineId) not found.") }
                return
            }

            performApiRequest(provider: provider, apiKey: apiKey, messages: messages)

        case "permissionHandler":
            guard let type = body["type"] as? String else { return }
            if type == "requestMicPermission" {
                requestMicrophonePermission()
            }
            
        default:
            break
        }
    }
    
    private func requestMicrophonePermission() {
        AVAudioSession.sharedInstance().requestRecordPermission { granted in
            let status = granted ? "granted" : "denied"
            self.callJavaScript(function: "setMicPermissionStatus", args: status)
        }
    }
    
    private func performApiRequest(provider: AIProvider, apiKey: String, messages: [[String: String]]) {
        guard let url = URL(string: provider.endpoint) else {
            DispatchQueue.main.async { self.callJavaScript(function: "renderErrorMessage", args: "Invalid API endpoint.") }
            return
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.addValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")

        var body: [String: Any] = [
            "model": provider.model,
            "messages": messages,
            "stream": true
        ]

        if provider.name == "DeepSeek" {
            var messagesWithSystemPrompt = [[String: String]]()
            messagesWithSystemPrompt.append(["role": "system", "content": "You are a helpful assistant. Please use professional and concise language, and avoid using emojis."])
            messagesWithSystemPrompt.append(contentsOf: messages)
            body["messages"] = messagesWithSystemPrompt
        }

        guard let httpBody = try? JSONSerialization.data(withJSONObject: body) else {
            DispatchQueue.main.async { self.callJavaScript(function: "renderErrorMessage", args: "Failed to serialize request body.") }
            return
        }
        request.httpBody = httpBody

        self.callJavaScript(function: "addTypingIndicator")
        let task = urlSession.dataTask(with: request)
        task.resume()
    }
    
    private func callJavaScript(function: String, args: String...) {
        let joinedArgs = args.map { "'\($0.replacingOccurrences(of: "'", with: "\\'"))'" }.joined(separator: ", ")
        let script = "\(function)(\(joinedArgs));"
        
        DispatchQueue.main.async {
            self.webView.evaluateJavaScript(script)
        }
    }

    // MARK: - URLSessionDataDelegate
    func urlSession(_ session: URLSession, dataTask: URLSessionDataTask, didReceive data: Data) {
        let responseString = String(data: data, encoding: .utf8) ?? ""
        let chunks = responseString.components(separatedBy: "\n\n")

        for chunk in chunks where chunk.hasPrefix("data: ") {
            let jsonString = String(chunk.dropFirst(6))
            
            if jsonString.trimmingCharacters(in: .whitespacesAndNewlines) == "[DONE]" {
                self.callJavaScript(function: "finishBotMessage", args: self.streamingMessageId, self.streamingMessageContent)
                self.streamingMessageContent = ""
                return
            }
            
            guard let jsonData = jsonString.data(using: .utf8) else { continue }

            do {
                if let json = try JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let choices = json["choices"] as? [[String: Any]], let firstChoice = choices.first,
                   let delta = firstChoice["delta"] as? [String: Any], let token = delta["content"] as? String {
                    
                    if self.streamingMessageContent.isEmpty {
                        self.streamingMessageId = "msg_\(Date().timeIntervalSince1970)"
                        self.callJavaScript(function: "startBotMessage", args: self.streamingMessageId)
                    }
                    
                    self.streamingMessageContent += token
                    self.callJavaScript(function: "appendTokenToMessage", args: self.streamingMessageId, token)
                }
            } catch {
                print("Error parsing stream chunk: \(error.localizedDescription)")
            }
        }
    }

    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        DispatchQueue.main.async {
            if let error = error {
                self.callJavaScript(function: "renderErrorMessage", args: "Stream error: \(error.localizedDescription)")
            } else if !self.streamingMessageContent.isEmpty {
                self.callJavaScript(function: "finishBotMessage", args: self.streamingMessageId, self.streamingMessageContent)
                self.streamingMessageContent = ""
            }
        }
    }
    
    // MARK: - WKNavigationDelegate
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // After chat.html has loaded, configure the AI engines
        if let url = webView.url, url.isFileURL, url.lastPathComponent == "chat.html" {
            configureWebViewWithApiKeys()
        }
    }
    
    private func configureWebViewWithApiKeys() {
        for (id, provider) in providers {
            if let key = provider.apiKey {
                let endpoint = provider.endpoint
                let model = provider.model
                // Pass the saved API key to the webview
                self.callJavaScript(function: "configureEngine", args: id, key, endpoint, model)
            }
        }
    }

    // MARK: - WKUIDelegate
    func webView(_ webView: WKWebView, runJavaScriptAlertPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping () -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in completionHandler() }))
        
        // Use modern API to find the window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true, completion: nil)
        } else {
            completionHandler() // Fallback
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptConfirmPanelWithMessage message: String, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (Bool) -> Void) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in completionHandler(true) })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in completionHandler(false) })
        
        // Use modern API to find the window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
        } else {
            completionHandler(false) // Fallback
        }
    }

    func webView(_ webView: WKWebView, runJavaScriptTextInputPanelWithPrompt prompt: String, defaultText: String?, initiatedByFrame frame: WKFrameInfo, completionHandler: @escaping (String?) -> Void) {
        let alert = UIAlertController(title: nil, message: prompt, preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = defaultText
        }
        alert.addAction(UIAlertAction(title: "OK", style: .default) { _ in
            completionHandler(alert.textFields?.first?.text)
        })
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionHandler(nil)
        })

        // Use modern API to find the window scene
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.first?.rootViewController?.present(alert, animated: true)
        } else {
            completionHandler(nil) // Fallback
        }
    }

    private func loadApiKeys() {
        for (id, _) in providers {
            if let apiKey = UserDefaults.standard.string(forKey: "apiKey_\(id)") {
                providers[id]?.apiKey = apiKey
            }
        }
    }
} 