import SwiftUI

/// 隐私保护说明页（App 内完整隐私承诺）
struct PrivacyView: View {
    var body: some View {
        List {
            Section("核心承诺") {
                Label("照片绝不上传", systemImage: "lock.shield.fill")
                Label("分析全部在本机完成", systemImage: "iphone")
                Label("不收集任何身份信息", systemImage: "person.slash")
                Label("可随时删除全部数据", systemImage: "trash")
            }

            Section("你的照片怎么处理") {
                Text("拍照或选图后，照片只存在于本机内存中，用于 Apple Vision 本地人脸分析。")
                Text("分析完成后，App 默认自动删除照片（可在\"我的 → 隐私设置\"中调整）。")
                Text("App 内不保存、不上传、不分享你的照片，也没有任何服务器接收它。")
            }

            Section("联网行为（可完全避免）") {
                Text("唯一的联网入口是结果页的\"在线搜更多\"按钮：它只向搜索引擎发送文字关键词（如\"圆脸 发型 推荐\"），绝不发送照片。不点击该按钮则完全离线。")
                Text("意见反馈通过系统邮件发送，邮件内容由你决定，默认不含照片。")
            }

            Section("本机保存的数据") {
                Text("· 脸型分析结果（仅几何比例特征，不含照片）\n· 收藏的发型 ID\n· 反馈偏好与匿名统计计数（默认关闭）\n\n以上全部保存在你手机的本地存储中，可随时删除。")
            }

            Section("你的权利") {
                Text("· 一键删除本地照片（预览页\"删除照片\"）\n· 关闭自动删除开关\n· 关闭匿名统计\n· 导出并带走你的数据（不含照片）\n· 卸载 App 即清除全部数据")
            }
        }
        .navigationTitle("隐私保护说明")
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    NavigationStack {
        PrivacyView()
    }
}
