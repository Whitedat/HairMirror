import SafariServices
import SwiftUI

/// Safari 浏览器包装：用于"在线搜更多"。
/// 注意：只向搜索引擎发送文字关键词（脸型+发型名），绝不发送照片。
struct SafariWebView: UIViewControllerRepresentable {
    let url: URL

    func makeUIViewController(context: Context) -> SFSafariViewController {
        SFSafariViewController(url: url)
    }

    func updateUIViewController(_ uiViewController: SFSafariViewController, context: Context) {}
}
