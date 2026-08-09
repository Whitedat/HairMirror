import Foundation

/// 隐私偏好：全部存储在本机 UserDefaults，绝不上传
final class PrivacyPreferences {
    static let shared = PrivacyPreferences()

    private let defaults = UserDefaults.standard

    private enum Key {
        static let didShowFirstTimeNotice = "privacy.didShowFirstTimeNotice"
        static let autoDeletePhoto = "privacy.autoDeletePhoto"
    }

    /// 是否已展示过首次隐私说明
    var didShowFirstTimeNotice: Bool {
        get { defaults.bool(forKey: Key.didShowFirstTimeNotice) }
        set { defaults.set(newValue, forKey: Key.didShowFirstTimeNotice) }
    }

    /// 分析完成后是否自动删除本地照片（默认开启，隐私优先）
    var autoDeletePhoto: Bool {
        get {
            // 默认值 true：未设置过时视为开启
            if defaults.object(forKey: Key.autoDeletePhoto) == nil { return true }
            return defaults.bool(forKey: Key.autoDeletePhoto)
        }
        set { defaults.set(newValue, forKey: Key.autoDeletePhoto) }
    }
}
