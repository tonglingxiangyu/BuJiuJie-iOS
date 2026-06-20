# 不纠结 iOS

「不纠结」是一款给选择困难用户使用的原生 iPhone App。它完全离线运行，不上传选择内容，也不需要注册账号。

## 已有功能

- **快速替我选**：输入 2～10 个候选项，通过随机动画给出结果。
- **认真比一比**：调整四个判断标准的重要程度，再为每个候选项评分。
- **决定记录**：自动保存结果、时间和候选项，可以分享或删除。
- **隐私友好**：全部数据保存在 iPhone 本机的 `UserDefaults` 中。
- **系统适配**：支持深色模式、动态字体和中文系统界面。

## 你最终会得到什么

GitHub 会使用官方 macOS 构建机把本项目编译为 `BuJiuJie-unsigned.ipa`。然后使用 Windows 上的 Sideloadly，以你的免费 Apple ID 临时签名并通过 USB 安装到 iPhone。

这是独立 App：安装后直接点击「不纠结」图标运行，不需要 Expo Go，也不需要浏览器。

## 准备工作

- Windows 10 或 Windows 11 电脑
- iOS 16 或更高版本的 iPhone
- 能传输数据的 USB 线
- 一个 GitHub 账号：https://github.com/signup
- 一个 Apple ID；建议专门创建一个用于侧载的备用 Apple ID
- Git for Windows：https://git-scm.com/download/win

## 第一步：在 Windows 上生成 IPA

### 1. 创建空的 GitHub 仓库

1. 登录 GitHub，打开 https://github.com/new 。
2. Repository name 填写 `BuJiuJie-iOS`。
3. 可选择 Public；项目中没有个人数据或密钥。Private 也可以，但会使用账户的 Actions 时长额度。
4. 不要勾选 README、`.gitignore` 或 License，保持仓库为空。
5. 点击 **Create repository**，复制仓库 HTTPS 地址，例如：

   `https://github.com/你的用户名/BuJiuJie-iOS.git`

### 2. 一键上传源码

在本项目文件夹空白处按住 Shift 并单击鼠标右键，选择“在终端中打开”，运行：

```powershell
powershell -ExecutionPolicy Bypass -File .\publish-to-github.ps1 -RepoUrl "https://github.com/你的用户名/BuJiuJie-iOS.git"
```

首次上传时，Git 可能弹出浏览器要求登录 GitHub。登录后允许访问即可。

### 3. 下载 IPA

1. 打开刚创建的 GitHub 仓库。
2. 点击顶部 **Actions**。
3. 点击左侧 **Build unsigned IPA**。
4. 等待构建显示绿色对勾，通常需要数分钟。
5. 打开这次运行记录，在页面底部 **Artifacts** 区域下载 `BuJiuJie-unsigned-IPA`。
6. 解压下载的 ZIP，得到 `BuJiuJie-unsigned.ipa`。

如果 GitHub 要求启用 Actions，点击 **I understand my workflows, go ahead and enable them**。

## 第二步：使用 Sideloadly 安装到 iPhone

### 1. 安装 Windows 组件

1. 从 Sideloadly 官方网站下载安装：https://sideloadly.io/
2. 按官网“Before you install”说明安装网页版 iTunes 和 iCloud。不要使用 Microsoft Store 版本，否则可能识别不到设备。
3. 启动 iTunes，用 USB 连接 iPhone。
4. iPhone 弹出“要信任此电脑吗？”时点击 **信任**，并输入锁屏密码。

### 2. 安装 IPA

1. 打开 Sideloadly，确认顶部设备列表中出现你的 iPhone。
2. 把 `BuJiuJie-unsigned.ipa` 拖进 Sideloadly。
3. 在 Apple account 一栏填写用于侧载的 Apple ID。
4. 点击 **Start**。
5. 如果 Apple 开启了双重认证，按提示输入发送到受信任设备的验证码。
6. 等待 Sideloadly 显示 `Done`。

### 3. 在 iPhone 上允许运行

1. 打开 **设置 → 隐私与安全性 → 开发者模式**。
2. 开启开发者模式，按提示重启 iPhone 并再次确认。
3. 如果首次打开仍提示开发者不受信任，前往 **设置 → 通用 → VPN 与设备管理**，找到对应 Apple ID 并点击信任。
4. 返回主屏幕，点击「不纠结」图标即可使用。

## 免费签名的 7 天续签

免费 Apple ID 签名的 App 有效期是 7 天。App 到期后不会自动删除，但在重新签名前无法打开。

最省事的设置：

1. 第一次 USB 安装成功后，在 Sideloadly 中启用 **Automatic App Refresh / Sideloadly Daemon**。
2. 让电脑和 iPhone 定期连接到同一个 Wi-Fi，电脑保持开机并运行后台续签服务。
3. 建议至少每 5～6 天让两台设备同时在线一次。

如果自动续签失败，只需再次连接 USB，把同一个 IPA 拖入 Sideloadly 并点击 Start。使用相同 Apple ID 和相同 IPA 覆盖安装，通常会保留 App 内的决定记录。重要内容仍建议先使用“分享结果”保存到备忘录。

## 常见问题

### Sideloadly 看不到 iPhone

- 更换确认支持数据传输的 USB 线或 USB 接口。
- 解锁 iPhone，重新点击“信任此电脑”。
- 确认安装的是 Sideloadly 官网链接提供的 iTunes/iCloud，而不是 Microsoft Store 版。
- 重启 Apple Mobile Device Service、Sideloadly 和 iPhone。

### GitHub 构建显示红色叉号

打开失败的构建，展开红色步骤查看日志。源项目已经固定使用 iOS 16 和无签名设备构建；如果是 GitHub 临时服务故障，点击 **Re-run jobs** 重试。

### 提示达到 App ID 或 App 数量限制

免费 Apple ID 的侧载数量有限。删除暂时不用的侧载 App，等待旧 App ID 到期，或换一个专门用于测试的 Apple ID。

### App 提示不再可用

这是 7 天免费签名到期。重新用 Sideloadly 覆盖安装即可，不需要卸载旧 App。

## 修改 App 后重新构建

修改源码后，在项目目录再次运行 `publish-to-github.ps1`。每次推送到 `main` 分支都会自动生成新的 IPA。在 Sideloadly 中覆盖安装即可更新。

## 工程结构

```text
App/                         SwiftUI 原生应用源码
  Models/                    决策记录数据模型
  Services/                  本地持久化
  Views/                     首页、随机选择、比较和记录界面
  Resources/Assets.xcassets  图标与强调色
.github/workflows/           GitHub 云端 IPA 构建脚本
project.yml                  XcodeGen 工程配置
publish-to-github.ps1        Windows 一键上传脚本
```

## 隐私说明

本应用不请求网络、位置、相机、通讯录或通知权限。所有决策数据只保存在 App 沙盒中。卸载 App 会清除这些本地数据。

