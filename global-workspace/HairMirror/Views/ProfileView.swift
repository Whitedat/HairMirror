import SwiftUI
import UIKit

/// "我的"页：隐私设置 + 意见反馈 + 数据导出 + 关于
struct ProfileView: View {
    /// 隐私设置无需订阅，普通引用即可
    private let privacy = PrivacyPreferences.shared
    @StateObject private var stats = UsageStats.shared

    /// 导出内容：仅匿名统计 JSON，不含照片
    private var exportText: String {
        stats.exportSummary()
    }

    var body: some View {
        NavigationStack {
            List {
                Section("隐私设置") {
                    Toggle(isOn: Binding(
                        get: { privacy.autoDeletePhoto },
                        set: { privacy.autoDeletePhoto = $0 }
                    )) {
                        Label("分析后自动删除照片", systemImage: "trash.slash")
                    }
                    .tint(.pink)

                    Toggle(isOn: Binding(
                        get: { stats.isEnabled },
                        set: { stats.setEnabled($0) }
                    )) {
                        Label("匿名使用统计", systemImage: "chart.bar.xaxis")
                    }
                    .tint(.pink)

                    if stats.isEnabled {
                        Text("仅记录分析次数、脸型分布、收藏数等计数，不含照片与身份信息，随时可关闭。")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }

                Section("反馈与数据") {
                    NavigationLink {
                        FeedbackView()
                    } label: {
                        Label("意见反馈", systemImage: "envelope")
                    }

                    ShareLink(item: exportText) {
                        Label("导出我的数据（不含照片）", systemImage: "square.and.arrow.up")
                    }
                } footer: {
                    Text("导出的数据为 JSON 文本，仅含匿名统计与脸型分布，绝不含照片。")
                }

                Section("数据管理") {
                    Button(role: .destructive) {
                        showResetConfirm = true
                    } label: {
                        Label("清空全部本地数据", systemImage: "trash")
                    }
                } footer: {
                    Text("将清除匿名统计与收藏记录。照片从不落盘，无需单独清理。")
                }

                Section("关于") {
                    LabeledContent("App 版本", value: AppInfo.version)
                    LabeledContent("设备", value: AppInfo.deviceModel)
                    NavigationLink {
                        PrivacyView()
                    } label: {
                        Label("隐私保护说明", systemImage: "lock.shield")
                    }
                }
            }
            .navigationTitle("我的")
            .confirmationDialog("确定清空全部本地数据？", isPresented: $showResetConfirm, titleVisibility: .visible) {
                Button("清空", role: .destructive) {
                    UsageStats.shared.resetAll()
                    FavoritesStore.shared.resetAll()
                    showResetDone = true
                }
                Button("取消", role: .cancel) {}
            } message: {
                Text("此操作不可撤销，将删除匿名统计与收藏记录。")
            }
            .alert("已清空", isPresented: $showResetDone) {
                Button("好", role: .cancel) {}
            } message: {
                Text("本地数据已全部清除。")
            }
        }
    }

    @State private var showResetConfirm = false
    @State private var showResetDone = false
}

#Preview {
    ProfileView()
}
