import SwiftUI
import WebKit

struct WebView: UIViewRepresentable {
    @ObservedObject var viewModel: WebViewModel

    func makeCoordinator() -> Coordinator {
        Coordinator(viewModel: viewModel)
    }

    func makeUIView(context: Context) -> WKWebView {
        let webView = viewModel.webView
        webView.scrollView.delegate = context.coordinator

        // 禁用横向滚动
        webView.scrollView.showsHorizontalScrollIndicator = false
        webView.scrollView.alwaysBounceHorizontal = false

        // 设置内容适应屏幕宽度和隐藏广告
        let script = """
            // 设置viewport
            var meta = document.createElement('meta');
            meta.name = 'viewport';
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
            var head = document.getElementsByTagName('head')[0];
            head.appendChild(meta);

            // 隐藏常见的广告和弹窗元素
            function hideAds() {
                const selectors = [
                    // 通用广告选择器
                    '[class*="ad"]', '[id*="ad"]', '[class*="banner"]', '[id*="banner"]',
                    '[class*="popup"]', '[id*="popup"]', '[class*="modal"]', '[id*="modal"]',
                    '[class*="overlay"]', '[id*="overlay"]', '[class*="promotion"]',
                    // AI网站特定选择器
                    '.upgrade-banner', '.subscription-banner', '.trial-banner',
                    '.announcement', '.notice', '.alert-banner', '.promo',
                    // 常见弹窗类名
                    '.dialog', '.toast', '.notification-banner'
                ];

                selectors.forEach(selector => {
                    try {
                        const elements = document.querySelectorAll(selector);
                        elements.forEach(el => {
                            if (el && el.style) {
                                el.style.display = 'none !important';
                                el.style.visibility = 'hidden !important';
                            }
                        });
                    } catch(e) {}
                });
            }

            // 页面加载完成后执行
            if (document.readyState === 'loading') {
                document.addEventListener('DOMContentLoaded', hideAds);
            } else {
                hideAds();
            }

            // 定期检查新出现的广告
            setInterval(hideAds, 2000);
        """
        let userScript = WKUserScript(source: script, injectionTime: .atDocumentEnd, forMainFrameOnly: true)
        webView.configuration.userContentController.addUserScript(userScript)

        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {
        // The view model now handles all loading logic.
    }

    class Coordinator: NSObject, UIScrollViewDelegate {
        private var viewModel: WebViewModel
        private var lastContentOffset: CGFloat = 0

        init(viewModel: WebViewModel) {
            self.viewModel = viewModel
        }

        func scrollViewDidScroll(_ scrollView: UIScrollView) {
            // 禁用地址栏隐藏功能 - 地址栏始终显示
            DispatchQueue.main.async {
                if !self.viewModel.isUIVisible {
                    withAnimation { self.viewModel.isUIVisible = true }
                }
            }

            lastContentOffset = scrollView.contentOffset.y
        }
    }
} 