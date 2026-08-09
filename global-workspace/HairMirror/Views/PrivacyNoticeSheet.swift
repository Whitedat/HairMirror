import SwiftUI

/// 首次使用隐私说明弹窗：清晰告知用户照片只在本地处理
struct PrivacyNoticeSheet: View {
    var onConfirm: () -> Void

    private let points: [(icon: String, title: String, detail: String)] = [
        ("lock.shield.fill", "照片绝不上传",
         "照片只在你手机本地分析，不会发送到任何服务器，也不会被收集。"),
        ("checkmark.seal.fill", "只保存几何数据",
         "App 内仅保留分析出的脸型特征（比例数据），不保存你的照片。"),
        ("trash.fill", "随时一键删除",
         "你可以随时删除本地记录，不留任何痕迹。"),
    ]

    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "hand.raised.fill")
                .font(.system(size: 52))
                .foregroundStyle(.tint)

            Text("你的隐私，我们守护")
                .font(.title2.bold())

            VStack(alignment: .leading, spacing: 16) {
                ForEach(points, id: \.title) { point in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: point.icon)
                            .font(.title3)
                            .foregroundStyle(.tint)
                            .frame(width: 32)
                        VStack(alignment: .leading, spacing: 2) {
                            Text(point.title).font(.headline)
                            Text(point.detail).font(.footnote).foregroundStyle(.secondary)
                        }
                    }
                }
            }
            .padding(.horizontal, 8)

            Button {
                onConfirm()
            } label: {
                Text("我知道了")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 12)
            }
            .buttonStyle(.borderedProminent)
            .padding(.top, 8)
        }
        .padding(24)
        .presentationDetents([.medium])
    }
}

#Preview {
    PrivacyNoticeSheet {}
}
