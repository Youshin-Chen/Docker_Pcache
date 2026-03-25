# PCache 文档导航

这份文档放在仓库根目录，作用只有一个：给后来接手这个项目的人一个清晰入口，知道应该去哪里看对应的说明。

原始项目地址是 `https://github.com/yangagile/pcache/tree/main`，当前这个仓库是在原始项目基础上补充了 Docker 部署相关内容，同时保留了原始项目结构和文档。

注意：

- `README.md`
- `README_CN.md`

这两份原始 README 主要用于介绍项目架构、能力和整体设计，不作为本仓库当前这套落地方案的唯一操作入口。

## 先按你的目标来选

### 1. 我想先了解项目是什么

先看项目总览和架构：

- 中文架构说明: `README_CN.md`
- English overview: `README.md`

## 2. 我想知道该走 Ubuntu 原生部署，还是 Docker 部署

先看这份选择说明：

- `docs-custom/README_choose_ubuntu_or_docker.md`

这份文档会告诉你：

- 什么情况下更适合 Ubuntu 原生部署
- 什么情况下更适合 Docker quickstart
- 两条路径分别该看哪些文档

## 3. 我想在 Windows 上直接用 Docker 跑起来

按下面顺序看：

1. `docs-custom/README_choose_ubuntu_or_docker.md`
2. `docs-custom/README_one_click_windows.md`
3. `docs-custom/README_auth_mode_windows.md`

补充问题排查：

- `docs-custom/README_troubleshooting_windows_quickstart.md`
- `docs-custom/README_issue_log_windows_auth.md`
- `docs-custom/README_multi_pms_native_and_docker.md`

## 4. 我想按项目原始方式在 Ubuntu / Linux 上部署

按下面顺序看：

1. `docs/cn/startup.md`
2. `docs/cn/minio_ops.md`
3. `docs/cn/meta.md`

如果你还要启用认证，再继续看：

4. `docs/cn/api_token.md`

如果你要看多节点相关说明，再继续看：

5. `docs/cn/multi-pms.md`
6. `docs-custom/README_multi_pms_native_and_docker.md`

## 5. 我想看 pcmd 的使用方式

直接看：

- `pcmd/README.md`

适合场景：

- 上传文件
- 下载文件
- 同步目录
- 验证 PBucket 访问链路

## 6. 我想看 SDK 的使用方式

Go SDK：

- `sdk/pc-sdk-go/README.md`

Java SDK：

- `sdk/pc-sdk-java/README.md`

## 7. 我想看这次仓库新增的落地补充文档

都在这里：

- `docs-custom/`

当前新增文档包括：

- `docs-custom/README_choose_ubuntu_or_docker.md`
- `docs-custom/README_one_click_windows.md`
- `docs-custom/README_auth_mode_windows.md`
- `docs-custom/README_multi_pms_native_and_docker.md`
- `docs-custom/README_troubleshooting_windows_quickstart.md`
- `docs-custom/README_issue_log_windows_auth.md`
- `docs-custom/README_submit_checklist.md`

## 8. 我只想最快把项目跑起来

建议直接走这条路径：

1. 看 `docs-custom/README_choose_ubuntu_or_docker.md`
2. 选择 Docker quickstart
3. 看 `docs-custom/README_one_click_windows.md`
4. 跑通后再看 `docs-custom/README_auth_mode_windows.md`

## 9. 我想做最终提交或发布前整理

看这里：

- `docs-custom/README_submit_checklist.md`

## 推荐阅读顺序

如果你是第一次接这个仓库，推荐这样看：

1. `README_START_HERE.md`
2. `docs-custom/README_choose_ubuntu_or_docker.md`
3. 根据你的环境选择 Docker 或 Ubuntu 路线
4. 跑通后再看认证模式、排障文档和提交清单

这样能把“架构说明”和“落地操作说明”分开，后续维护也会更清楚。
