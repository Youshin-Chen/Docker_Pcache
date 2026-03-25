# 部署方式选择说明

本文档用于帮助后来接手这个仓库的人快速判断：应该走 `Ubuntu 原生部署`，还是走当前仓库补充的 `Docker quickstart`。

原始项目地址是 `https://github.com/yangagile/pcache/tree/main`，当前这个仓库是在原始项目基础上补充了 Docker 部署相关内容，同时保留了原始项目结构和文档。

- 原始项目文档保持不动
- 本文档只作为入口导航和选择建议
- 如果只是想先把项目跑起来，优先看这份

## 先说结论

如果你的目标是“尽快在本机把项目拉起来并验证服务”，优先选择 Docker。

如果你的目标是“更贴近项目原始运行方式、在 Linux 环境里做开发/调试/扩展”，优先选择 Ubuntu 原生部署。

## 两种方式分别适合什么场景

| 场景 | 更推荐的方式 | 原因 |
| --- | --- | --- |
| Windows 机器，本地快速演示 | Docker | 当前仓库已经补齐一键启动和 seed 数据 |
| 新同学第一次接手项目 | Docker | 依赖更少，路径更短，能先验证整体链路 |
| 想快速验证 PMS / PCP / MinIO / `pcmd` | Docker | `docker compose up -d --build` 就能起完整演示环境 |
| Ubuntu / Linux 服务器开发 | Ubuntu 原生 | 更贴近项目原始文档和原始运行方式 |
| 想研究原始 `run.sh`、原始模块启动逻辑 | Ubuntu 原生 | 能直接按仓库原设计运行各模块 |
| 想做更细粒度的环境定制 | Ubuntu 原生 | 更容易按你的实际对象存储、meta、节点结构调整 |
| 想给别人一个最短路径的落地方案 | Docker | 仓库已经补了单机 quickstart 文档 |

## 选择 Docker 的时候

### 适合你如果

- 你在 Windows 上工作
- 你想先把服务跑通
- 你希望别人 `git clone` 之后尽量少配环境
- 你需要一个可重复的本地演示环境

### 你会得到什么

- `minio`
- `minio-init`
- `pms`
- `pcp`

默认端口：

- `8080`: PMS
- `8091`: PCP
- `9000`: MinIO API
- `9001`: MinIO Console

### 入口文档

- Windows 一键 quickstart: `docs-custom/README_one_click_windows.md`
- Windows 认证模式: `docs-custom/README_auth_mode_windows.md`
- 多 PMS 验证记录: `docs-custom/README_multi_pms_native_and_docker.md`
- Windows 问题排查: `docs-custom/README_troubleshooting_windows_quickstart.md`
- 本次问题汇总: `docs-custom/README_issue_log_windows_auth.md`

### 最短启动命令

```powershell
docker compose up -d --build
```

### Docker 方案的特点

- 上手最快
- 适合本地验证和演示
- 当前仓库已经补齐 seed meta 和默认账号
- 对 Windows 用户最友好

### Docker 方案的边界

- 这套 quickstart 主要面向单机本地验证
- 它的目标是“方便跑通”，不是替代所有原始部署方式
- 如果你要深度研究模块启动参数、服务拆分、多节点结构，还是建议回到 Ubuntu 原生方式

## 选择 Ubuntu 原生部署的时候

### 适合你如果

- 你本身就在 Ubuntu / Linux 上开发
- 你想按项目原始设计方式启动 PMS、PCP、`pcmd`
- 你要做更接近生产环境的调试
- 你想理解原始 meta 初始化、run 脚本和服务关系

### 入口文档

原始中文文档入口：

- 启动说明: `docs/cn/startup.md`
- Token 认证: `docs/cn/api_token.md`
- Meta 说明: `docs/cn/meta.md`
- MinIO 操作: `docs/cn/minio_ops.md`
- 多 PMS 说明: `docs/cn/multi-pms.md`
- 多 PMS 实际验证记录: `docs-custom/README_multi_pms_native_and_docker.md`

### Ubuntu 原生部署的大致路径

1. 准备运行环境
2. 编译整个仓库
3. 准备对象存储
4. 初始化 meta
5. 启动 PMS
6. 启动 PCP
7. 配置 `pcmd` 或 SDK 验证

### 从原始文档提炼出来的最小理解

- 需要准备 Maven、Java、Go
- 需要你自己准备对象存储侧 AK/SK 和 bucket
- 需要初始化 meta 数据
- PMS 和 PCP 按原始 `run.sh` 启动
- 如果要启用认证，继续看 `docs/cn/api_token.md`

### Ubuntu 方案的特点

- 更贴近原始项目结构
- 更适合深度调试和定制
- 更方便延展到多节点或更复杂环境

### Ubuntu 方案的边界

- 手工步骤更多
- 首次接手更容易卡在环境、对象存储、meta 初始化上
- 对新同学不如 Docker quickstart 友好

## 推荐选择策略

如果你是第一次接这个仓库，建议按下面顺序走：

1. 先用 Docker quickstart 跑通完整链路
2. 再切到认证模式验证权限边界
3. 最后如果你需要深入开发或贴近 Linux 环境，再按原始文档走 Ubuntu 原生部署

这样做的好处是：

- 先确认“项目本身能跑”
- 再确认“认证模式能跑”
- 最后再处理原生部署里那些更细的环境问题

## 你可以直接这样判断

如果你符合下面任一条件，优先 Docker：

- 你在 Windows
- 你要演示给别人看
- 你想一小时内把项目跑通
- 你不想先手工配太多对象存储和 meta

如果你符合下面任一条件，优先 Ubuntu：

- 你本来就在 Ubuntu 开发
- 你要深改服务启动方式
- 你要严格按原始项目路径来
- 你要研究多节点、原始脚本、原始模块边界

## 最终建议

对这个仓库来说，两条路径不是互斥的，而是分层使用：

- Docker quickstart 负责“快速跑通”
- Ubuntu 原生部署负责“贴近原始项目和深度开发”

后来的人最稳的做法，不是二选一到底，而是先 Docker，后 Ubuntu。
