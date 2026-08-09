import Foundation
import UIKit

/// 反馈发送服务：通过系统邮件一键生成草稿，不经过任何第三方服务器。
/// 开发者邮箱在 FeedbackService.feedbackEmail 配置（见 README 说明）。
enum FeedbackService {
    /// 开发者反馈邮箱（占位符——交付文档会教你怎么换成自己的邮箱）
    static let feedbackEmail = "feedback@hairmirror.app"

    /// 反馈类型
    enum FeedbackType: String, CaseIterable, Identifiable {
        case inaccurate = "推荐不准"
        case hardToUse = "不好用"
        case crash = "崩溃/闪退"
        case suggestion = "功能建议"
        case other = "其他"

        var id: String { rawValue }
    }

    struct Feedback {
        var rating: Int = 5          // 1~5 星
        var type: FeedbackType = .suggestion
        var message: String = ""
        var includeStats: Bool = false
    }

    /// 构造邮件草稿 URL（主题/正文均 URL 编码）
    @MainActor
    static func mailURL(for feedback: Feedback) -> URL? {
        var body = "评分：\(stars(feedback.rating))\n"
        body += "反馈类型：\(feedback.type.rawValue)\n"
        body += "App 版本：\(AppInfo.version) (\(AppInfo.build))\n"
        body += "设备：\(AppInfo.deviceModel)\n\n"
        body += "反馈内容：\n\(feedback.message)\n"

        if feedback.includeStats {
            body += "\n\n—— 匿名使用统计（自愿附带，不含照片）——\n"
            body += UsageStats.shared.exportSummary()
        }

        let subject = "发型魔镜 用户反馈"
        var comps = URLComponents(string: "mailto:\(feedbackEmail)")
        comps?.queryItems = [
            URLQueryItem(name: "subject", value: subject),
            URLQueryItem(name: "body", value: body),
        ]
        return comps?.url
    }

    /// 打开系统邮件（若设备未配置邮件账户，会提示）
    @MainActor
    static func openMail(for feedback: Feedback) -> Bool {
        guard let url = mailURL(for: feedback) else { return false }
        UIApplication.shared.open(url)
        return true
    }

    private static func stars(_ rating: Int) -> String {
        String(repeating: "★", count: max(1, min(rating, 5)))
            + String(repeating: "☆", count: max(0, 5 - max(1, min(rating, 5))))
    }
}
