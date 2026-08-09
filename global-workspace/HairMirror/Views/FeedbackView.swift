import SwiftUI

/// 意见反馈页：星级评分 + 问题类型 + 文字描述 → 系统邮件发送
struct FeedbackView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var rating = 5
    @State private var type: FeedbackService.FeedbackType = .suggestion
    @State private var message = ""
    @State private var includeStats = false
    @State private var showMailError = false

    var body: some View {
        NavigationStack {
            Form {
                Section("你觉得这个 App 怎么样？") {
                    // 星级评分
                    HStack(spacing: 12) {
                        ForEach(1...5, id: \.self) { star in
                            Button {
                                rating = star
                            } label: {
                                Image(systemName: star <= rating ? "star.fill" : "star")
                                    .font(.title2)
                                    .foregroundStyle(star <= rating ? .yellow : .secondary)
                            }
                            .buttonStyle(.plain)
                        }
                        Spacer()
                        Text("\(rating) 星")
                            .foregroundStyle(.secondary)
                    }
                }

                Section("问题类型") {
                    Picker("问题类型", selection: $type) {
                        ForEach(FeedbackService.FeedbackType.allCases) { t in
                            Text(t.rawValue).tag(t)
                        }
                    }
                    .pickerStyle(.menu)
                }

                Section("详细描述") {
                    TextField("请描述你遇到的问题或建议…", text: $message, axis: .vertical)
                        .lineLimit(4...8)
                }

                Section {
                    Toggle("附带匿名使用统计（不含照片）", isOn: $includeStats)
                    Text("开启后，邮件会附带本机匿名统计（分析次数、脸型分布等），帮助开发者改进推荐。可在\"我的\"页随时关闭。")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Section {
                    Button {
                        send()
                    } label: {
                        Label("发送反馈（打开系统邮件）", systemImage: "paperplane.fill")
                            .frame(maxWidth: .infinity)
                    }
                    .disabled(message.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                } footer: {
                    Text("反馈通过系统邮件发送到开发者邮箱，不经过任何第三方服务器；邮件中不包含你的照片。")
                }
            }
            .navigationTitle("意见反馈")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("取消") { dismiss() }
                }
            }
            .alert("无法打开邮件", isPresented: $showMailError) {
                Button("好", role: .cancel) {}
            } message: {
                Text("请先在系统\"设置 → 邮件\"中配置邮件账户，或手动把反馈内容发送到开发者邮箱。")
            }
        }
    }

    private func send() {
        let feedback = FeedbackService.Feedback(
            rating: rating,
            type: type,
            message: message,
            includeStats: includeStats
        )
        if FeedbackService.openMail(for: feedback) {
            UsageStats.shared.recordFeedback()
            dismiss()
        } else {
            showMailError = true
        }
    }
}

#Preview {
    FeedbackView()
}
