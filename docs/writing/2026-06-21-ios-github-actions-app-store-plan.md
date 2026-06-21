# 不纠结 iOS 项目：从 Windows、GitHub Actions 到 App Store - Writing Plan

> **For Claude:** REQUIRED SUB-SKILL: Use document-superpowers:executing-article-plan to write this article section-by-section.

**Date**: 2026-06-21

**Audience:** 完全不了解 GitHub、GitHub Actions 和 iOS 发布流程，主要使用 Windows 且没有 Mac 的应用作者。

**Goal:** 让读者能够理解、复现并维护“不纠结”应用从源码到 IPA、Release、iPhone 安装和 App Store 上架的完整流程。

**Total Length:** 约 5,500 字

**Tone:** 中文、友好、零基础、操作导向；解释术语但不堆砌术语。

**Core Message:** Windows 用户可以借助 GitHub Actions 构建和测试 iOS 应用，但正式上架仍需要 Apple Developer 会员、有效签名以及 macOS/Xcode 构建上传环境。

---

## Article Structure Overview

1. 项目成果与全流程地图（250 字）
2. 先认识工具和关键文件（350 字）
3. SwiftUI 项目如何组成（350 字）
4. Git 与 GitHub 的最低必备概念（350 字）
5. 第一次把项目放进 GitHub（350 字）
6. GitHub Actions 工作流逐行解释（550 字）
7. IPA、Artifact 与 Release 的区别（300 字）
8. Windows 上用 Sideloadly 安装（350 字）
9. 修改功能、图标并发布新版本（450 字）
10. 常见故障与排查顺序（350 字）
11. App Store 发布前的硬性条件（350 字）
12. Apple Developer 与 App Store Connect 配置（450 字）
13. 没有 Mac 时的签名、归档和上传方案（500 字）
14. TestFlight、商店资料与审核（450 字）
15. 上架后的版本更新与维护（250 字）
16. 最终检查清单（200 字）

总计：约 5,800 字，可在执行时压缩至约 5,500 字。

---

## Section 1: 项目成果与全流程地图（target: 250 words）

**Purpose:** 先让读者知道最终会得到什么，并建立源码到手机/App Store 的完整心智模型。

**Key Points:**
1. 当前应用包含快速选择、认真比较、历史记录和本地存储。
2. 用一条流程解释：Windows 源码 → GitHub → macOS Runner → IPA/Archive → iPhone 或 App Store。
3. 区分测试安装与正式上架两条路线。

**Supporting Evidence:** 当前仓库、Release 和已经成功安装的实测结果。

**Transitions:** 从全局地图进入工具与名词。

**Research Needed:** 无。

**Self-Check Questions:** 读者能否一眼区分“侧载”和“上架”？

## Section 2: 先认识工具和关键文件（target: 350 words）

**Purpose:** 用通俗语言解释 Swift、SwiftUI、Xcode、XcodeGen、GitHub Actions、IPA、签名和 Bundle ID。

**Key Points:**
1. 每个工具只解释它在本项目中的职责。
2. 解释 `.swift`、`project.yml`、`.github/workflows/*.yml`、`Assets.xcassets`。
3. 解释为什么 Windows 能编辑源码但不能本地运行 Xcode。

**Research Needed:** 核对 Apple 官方 Xcode 平台要求。

**Transitions:** 从工具进入项目目录。

**Self-Check Questions:** 是否避免把 IPA 描述成已经签名的 App Store 包？

## Section 3: SwiftUI 项目如何组成（target: 350 words）

**Purpose:** 解释本项目的界面、模型、存储和资源如何协作。

**Key Points:**
1. App 入口、RootView、QuickPickView、CompareView、HistoryView。
2. DecisionStore 使用 UserDefaults 保存历史和比较维度。
3. Assets.xcassets 与 AppIcon 的构建关系。

**Research Needed:** 无。

**Transitions:** 源码完成后需要版本管理。

**Self-Check Questions:** 文件职责是否与当前代码一致？

## Section 4: Git 与 GitHub 的最低必备概念（target: 350 words）

**Purpose:** 让零基础读者理解仓库、提交、分支、推送和远端。

**Key Points:**
1. Git 是本地版本记录，GitHub 是远端托管平台。
2. `add`、`commit`、`push` 的生活化比喻与准确含义。
3. main、commit SHA 和回滚概念。

**Research Needed:** GitHub 官方 Git 入门链接。

**Transitions:** 用这些概念完成首次上传。

**Self-Check Questions:** 是否明确 commit 不等于 push？

## Section 5: 第一次把项目放进 GitHub（target: 350 words）

**Purpose:** 复盘本项目仓库创建、文件上传和远端关联。

**Key Points:**
1. 创建仓库及公开/私有选择。
2. 浏览器上传与命令行推送两种方法。
3. 检查 `.github` 隐藏目录和资源图片是否真的进入仓库。

**Research Needed:** GitHub 官方仓库创建与文件上传文档。

**Transitions:** 仓库中出现 workflow 后 Actions 自动运行。

**Self-Check Questions:** 是否覆盖 Windows 隐藏文件问题？

## Section 6: GitHub Actions 工作流逐行解释（target: 550 words）

**Purpose:** 彻底解释 build/publish YAML 的触发器、Runner、步骤、权限和产物。

**Key Points:**
1. `on.push`、`workflow_dispatch`、`runs-on: macos-15`。
2. checkout、安装 XcodeGen、生成项目、xcodebuild、关闭代码签名。
3. `Payload/*.app` 打包为 IPA。
4. 上传 Artifact 与使用 `GH_TOKEN` 更新 Release。
5. 新增 Assets.car/CFBundleIcon 构建校验的原因。

**Research Needed:** GitHub 官方 Actions、macOS Runner、GITHUB_TOKEN、Artifact 与 Release 文档。

**Transitions:** 工作流产生的两类文件去向不同。

**Self-Check Questions:** 是否解释 YAML 缩进和 secret 安全边界？

## Section 7: IPA、Artifact 与 Release 的区别（target: 300 words）

**Purpose:** 避免读者在 Actions 页面和 Release 页面之间迷路。

**Key Points:**
1. IPA 是应用包；Artifact 是某次运行的临时产物；Release 是公开/长期下载入口。
2. unsigned IPA 需要 Sideloadly 重新签名。
3. Release 标签 `unsigned-latest` 的覆盖更新逻辑。

**Research Needed:** GitHub 官方保留期限和 Release 文档。

**Transitions:** 获取 IPA 后进入 Windows 安装。

**Self-Check Questions:** 是否避免把 unsigned IPA 说成可以直接点开安装？

## Section 8: Windows 上用 Sideloadly 安装（target: 350 words）

**Purpose:** 汇总实际成功的 iPhone 安装步骤。

**Key Points:**
1. USB 信任、Apple Web 版组件、Local Anisette、Apple ID Sideload。
2. 免费账号七天有效期和自动刷新前提。
3. iPhone 开发者模式与信任开发者。

**Research Needed:** Sideloadly 官方 FAQ；Apple 开发者模式官方说明。

**Transitions:** 安装成功后进入迭代更新。

**Self-Check Questions:** 是否提醒用户不要在聊天中提交密码？

## Section 9: 修改功能、图标并发布新版本（target: 450 words）

**Purpose:** 用本次修改展示真实迭代流程。

**Key Points:**
1. 默认四个比较维度、自定义名称、新增、删除、保存、恢复默认。
2. AppIcon 1024×1024、无透明通道、Assets.xcassets 配置。
3. `project.yml` 资源排除错误的根因与修复。
4. 更新版本号、提交、推送、观察 Actions、覆盖 Release。

**Research Needed:** Apple App Icon 官方规范。

**Transitions:** 真实发布中可能出现故障。

**Self-Check Questions:** 是否清晰区分代码修改和重新签名安装？

## Section 10: 常见故障与排查顺序（target: 350 words）

**Purpose:** 给出从网络到签名、资源和设备的高效排查树。

**Key Points:**
1. 404/504、代理残留、No Anisette/Local Anisette。
2. DLL 与 iTunes/iCloud Web 版问题。
3. 无图标、无 Assets.car、设备未信任、签名过期。

**Research Needed:** Sideloadly 官方 FAQ 与更新日志。

**Transitions:** 侧载稳定后再讨论正式上架。

**Self-Check Questions:** 是否把实测诊断和官方要求明确区分？

## Section 11: App Store 发布前的硬性条件（target: 350 words）

**Purpose:** 提前讲清成本、身份、设备和内容要求。

**Key Points:**
1. Apple Developer Program 会员及当前费用。
2. Bundle ID、签名证书、描述文件、隐私政策与联系信息。
3. unsigned IPA 不能直接提交 App Store。

**Research Needed:** Apple 官方会员费用、注册资格与提交要求。

**Transitions:** 满足条件后配置后台。

**Self-Check Questions:** 所有费用和规则是否来自当日 Apple 官方来源？

## Section 12: Apple Developer 与 App Store Connect 配置（target: 450 words）

**Purpose:** 逐步建立可签名和可提交的应用记录。

**Key Points:**
1. 加入计划、协议/税务/银行信息适用范围。
2. 创建显式 Bundle ID、Distribution 证书与 App Store 描述文件。
3. App Store Connect 创建 App、SKU、主语言和权限。
4. 证书私钥与 `.p12` 的安全处理。

**Research Needed:** Apple Certificates、Profiles、App Store Connect Help 官方文档。

**Transitions:** 后台就绪后在 macOS 环境签名归档。

**Self-Check Questions:** 是否明确证书与私钥不可公开提交 GitHub？

## Section 13: 没有 Mac 时的签名、归档和上传方案（target: 500 words）

**Purpose:** 给出 Windows 用户真正可行且合规的上架路径。

**Key Points:**
1. 推荐路径：短期租用可信云 Mac，使用 Xcode Archive/Organizer 上传。
2. 进阶路径：GitHub Actions 配置加密 secrets、安装证书/描述文件、`xcodebuild archive`、导出并上传。
3. App Store Connect API Key 或 Apple 账号认证的安全边界。
4. 为什么当前 unsigned workflow 只能用于侧载，不能直接上架。

**Research Needed:** Apple 上传构建、Xcode Cloud/Transporter、GitHub encrypted secrets 官方文档；核对 App Store Connect API 上传支持。

**Transitions:** 构建上传后进入 TestFlight 和商店资料。

**Self-Check Questions:** 是否避免建议公开上传证书或密码？

## Section 14: TestFlight、商店资料与审核（target: 450 words）

**Purpose:** 解释构建上传后仍需完成的产品与合规工作。

**Key Points:**
1. 构建处理、内部测试、外部测试与 Beta 审核。
2. 应用名称、副标题、描述、关键词、分类、截图和支持网址。
3. App Privacy、年龄分级、出口合规、内容权利和审核备注。
4. 提交审核、常见驳回原因和发布方式。

**Research Needed:** App Store Connect Help、App Review Guidelines、隐私问卷与截图规范。

**Transitions:** 审核通过后进入持续更新。

**Self-Check Questions:** 是否注明隐私答案必须与代码实际行为一致？

## Section 15: 上架后的版本更新与维护（target: 250 words）

**Purpose:** 让读者知道首版上架只是开始。

**Key Points:**
1. 每次递增 Marketing Version 和 Build Number。
2. 数据兼容、TestFlight 回归、Release Notes、崩溃反馈。
3. 证书续期、账号续费和依赖/Runner 更新。

**Research Needed:** Apple 版本与构建号官方说明。

**Transitions:** 汇总为最终检查清单。

**Self-Check Questions:** 是否解释同版本构建号不可重复上传？

## Section 16: 最终检查清单（target: 200 words）

**Purpose:** 提供可直接逐项勾选的侧载与上架清单。

**Key Points:**
1. 源码/GitHub/Actions/Release 检查。
2. iPhone 侧载检查。
3. App Store 账号、签名、资料、测试、审核检查。

**Research Needed:** 汇总前述来源，不新增事实。

**Self-Check Questions:** 是否每一项都可执行、可验证？

---

## Research Summary

**Priority 1 (Must Have):**
- [ ] Apple Developer Program 当前费用与资格
- [ ] Apple 官方证书、描述文件、上传构建和 App Store Connect 流程
- [ ] GitHub Actions macOS Runner、GITHUB_TOKEN、Artifact、Release 与 Secrets
- [ ] App Review Guidelines、App Privacy、TestFlight

**Priority 2 (Should Have):**
- [ ] Sideloadly 官方 Local Anisette、免费账号和安装限制
- [ ] Apple 图标与截图规范

**Priority 3 (Nice to Have):**
- [ ] GitHub Actions 正式签名上传的进阶示例

## Style Guidelines

**Do:**
- 每一步说明操作、原因、成功标志和常见错误。
- 首次出现的英文术语立即给中文解释。
- 使用当前项目的真实文件名、工作流和错误案例。
- 对付费、签名、隐私和审核信息使用官方来源并注明日期。

**Avoid:**
- 假设读者已经会 Git 或 Xcode。
- 把侧载、Ad Hoc、TestFlight 和 App Store 发布混为一谈。
- 建议把密码、证书私钥或 API Key 提交到公开仓库。
- 用未经验证的第三方规则替代 Apple/GitHub 官方资料。
