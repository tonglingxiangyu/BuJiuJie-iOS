# 不纠结 iOS 项目完整开发与发布指南 - Article Brief

**Date**: 2026-06-21

## Audience

第一次接触 GitHub、GitHub Actions 和 iOS 发布流程，主要使用 Windows、没有 Mac 的应用作者。

## Purpose

帮助读者理解并复现“不纠结”应用从本地源码、GitHub 云端构建、IPA 发布与安装，到最终提交 App Store 审核的完整流程。

## Core Message

Windows 用户可以借助 GitHub Actions 构建和测试 iOS 应用，但 App Store 正式发布还需要 Apple Developer 会员、有效签名与 macOS/Xcode 云端构建环境。

## Key Points

1. 解释项目文件、SwiftUI、XcodeGen、IPA、签名与 Bundle ID 的作用。
2. 逐步解释 GitHub 仓库、提交、Actions 工作流、Artifact 和 Release 的关系。
3. 说明 Windows + Sideloadly 的安装、七天签名限制与更新方式。
4. 说明 Apple Developer、App Store Connect、证书、描述文件、隐私资料、TestFlight 和审核发布流程。

## Tone & Style

中文、友好、零基础、按步骤操作；每个阶段说明“做什么、为什么、成功标志和常见错误”。

## Constraints

- **Length**: 以完整可操作为准，不刻意限制字数。
- **Format**: 项目内 Markdown 技术指南。
- **Platform**: 优先覆盖 Windows、GitHub Actions、iPhone；明确无 Mac 条件下的限制与云端替代方案。
- **Implementation**: 同步记录可自定义比较维度、图标资源修复、新版 IPA 与 Release 更新。

## References

- 当前 GitHub 仓库：https://github.com/tonglingxiangyu/BuJiuJie-iOS
- Apple Developer 与 App Store Connect 官方文档
- GitHub Actions 官方文档
- Sideloadly 官方文档
