# 发型魔镜 HairMirror ✂️

一款**隐私优先**的 iOS 发型选择器：拍一张正面照，在手机本地分析脸型，推荐最适合你的发型。

> **核心承诺：照片只在你的手机里分析，绝不上传任何服务器。**

---

## 功能一览

| 功能 | 说明 |
| --- | --- |
| 📸 拍照 / 相册选图 | 两个大按钮，选完即分析 |
| 🧠 本地脸型分析 | Apple Vision 在设备端检测人脸关键点，规则分类 6 种脸型（鹅蛋 / 圆 / 方 / 长 / 心形 / 菱形），附置信度 |
| 💇 发型推荐 | 内置 80 款发型库，按「脸型 + 性别 + 风格 + 长度」打分排序，每款附推荐理由 |
| 🔍 在线搜更多 | 一键用文字关键词搜索最新发型图（**只发关键词，不发照片**） |
| ❤️ 收藏 / 搜索 / 筛选 | 发型库支持关键词搜索、风格/长度筛选、收藏 |
| 📮 意见反馈 | 星级 + 问题类型 + 描述，经**系统邮件**直达开发者（不经过第三方服务器） |
| 📊 匿名统计（默认关闭） | 可自愿开启：只记录分析次数、脸型分布等计数，可随反馈附带 |
| 🗑️ 一键删除 | 分析后自动删除照片（默认开），随时手动删除，不留痕迹 |

---

## 技术栈

- **SwiftUI**（iOS 17+，iPhone）
- **Vision 框架**：本地人脸检测与关键点提取（完全离线）
- 无任何第三方 SDK、无后端服务器、无数据收集

---

## 目录结构

```
HairMirror.xcodeproj      Xcode 工程（Mac 上双击即可打开）
HairMirror/
├── HairMirrorApp.swift    App 入口
├── ContentView.swift      三大 Tab（测脸型 / 发型库 / 我的）
├── Models/                脸型、发型、分析结果模型
├── Services/              分析、分类、推荐、统计、反馈等服务
├── Views/                 全部界面
├── Resources/
│   ├── hairstyles.json    内置发型库（80 款，可扩充）
│   └── HairImages/        发型图片目录（放入后自动显示）
└── Assets.xcassets        图标与主题色
HairMirrorTests/           单元测试（分类器 / 推荐引擎）
.github/workflows/         云构建工作流
```

---

## 三种运行方式（按你的情况选）

### 方式 A：没有 Mac → GitHub 云构建（推荐）

1. 注册 [GitHub](https://github.com) 账号，新建一个仓库，把本项目所有文件上传（或用 Git 推送）
2. 打开仓库的 **Actions** 页面，工作流 `iOS Build & Test` 会自动运行
3. 等几分钟看到绿色 ✅ 就说明**代码编译通过、测试全部通过**
4. 点进最新一次运行，底部 **Artifacts** 可下载编译好的 `HairMirror-Release.app`

> 注意：无签名的 .app 不能直接装进 iPhone。要把 App 装到自己的手机，请用方式 B（借一台 Mac）或 C（付费账号）。

### 方式 B：有 Mac（或借用一台 Mac）→ Xcode 直接跑

1. 安装 [Xcode 16+](https://apps.apple.com/cn/app/xcode/id497799835)（Mac App Store 免费）
2. 双击 `HairMirror.xcodeproj` 打开工程
3. 顶部选一个 iPhone 模拟器，按 ▶️ 运行即可体验
4. 连上自己的 iPhone，选真机运行（需登录 Apple ID，免费账号可运行 7 天）

### 方式 C：想长期使用 / 上架 App Store

需要 [Apple Developer 账号](https://developer.apple.com/programs/)（$99/年）：

1. 在 Xcode 中配置你的 Team（Signing & Capabilities）
2. Product → Archive → Distribute App 上传
3. 用 **TestFlight** 发给测试者，或提交 App Store 审核
4. 审核前请填好 App Store Connect 中的**隐私标签**（本 App 不收集任何数据，可如实勾选"不收集数据"）

---

## 自定义配置

### 1. 换成你的反馈邮箱 📮

打开 `HairMirror/Services/FeedbackService.swift`，把这一行改成你的邮箱：

```swift
static let feedbackEmail = "feedback@hairmirror.app"   // ← 改成你的邮箱
```

### 2. 替换发型图片 🖼️

1. 把图片（建议 1:1，如 800×800）放入 `HairMirror/Resources/HairImages/`
2. 在 `HairMirror/Resources/hairstyles.json` 中给对应款式加上字段：

```json
{ "id": "bob-classic", ..., "imageName": "HairImages/bob.jpg" }
```

> 图片文件放入 `Resources` 目录后会自动纳入工程（Xcode 16 同步文件夹），无需手动添加。

### 3. 扩充发型库 📚

直接编辑 `hairstyles.json`，按现有格式追加条目即可：

```json
{
  "id": "my-new-style",
  "name": "新发型",
  "nameEn": "New Style",
  "style": "甜美",
  "length": "中发",
  "gender": "女",
  "shapes": ["oval", "round"],
  "description": "这款发型的推荐理由…"
}
```

### 4. 修改 App 名称 / 图标

- 名称：工程设置 → `INFOPLIST_KEY_CFBundleDisplayName`
- 图标：替换 `HairMirror/Assets.xcassets/AppIcon.appiconset/AppIcon.png`（1024×1024）

---

## 隐私设计（为什么可以放心）

- ✅ 人脸分析用 Apple **Vision 框架在本机完成**，代码中不存在任何上传照片的网络请求
- ✅ 照片只存在于**内存**（`@State`），从不写入磁盘
- ✅ 分析完成后**自动删除**照片（可关闭）
- ✅ 唯一联网入口"在线搜更多"只发送**文字关键词**
- ✅ 反馈走**系统邮件**，内容由你决定
- ✅ 匿名统计**默认关闭**，只记录计数，不含照片与身份信息
- ✅ 卸载 App 即清除全部数据

> 想验证？全项目搜索 `URLSession` / `URL(string` 即可看到：唯一的网络使用是"在线搜更多"的文字搜索链接。

---

## 常见问题

**Q：分析结果不准？**
A：请使用正脸、光线明亮、无刘海遮挡、无眼镜的照片；置信度低于 60% 时建议重拍。当前分类器基于经典人脸比例规则，后续可通过"意见反馈"里的匿名统计持续调优。

**Q：提示"没有检测到人脸"？**
A：照片需包含完整正脸；多人合影、侧脸、遮挡都会导致失败。

**Q：Windows 上能直接编译吗？**
A：不能，iOS 工程只能在 macOS 上编译。请用方式 A（GitHub 云构建）验证代码，或借一台 Mac 运行。

**Q：发型图片为什么是占位图？**
A：正版发型照片涉及版权，无法随代码分发。数据结构已就绪（`imageName` 字段），拿到图片后按上文"自定义配置"放入即可。
