# 多 PMS 验证记录

本文档记录当前仓库对“多 PMS”能力做过的两轮验证：

- 原始项目原生双 PMS 验证
- Docker 双 PMS 收敛验证

原始项目地址是 `https://github.com/yangagile/pcache/tree/main`，当前仓库是在原始项目基础上补充了 Docker 部署相关内容，同时保留了原始项目结构和文档。

## 验证结论

这条验证线已经完整跑通：

- 原生双 PMS 加入成功
- 原生双 PMS meta 同步成功
- 原生 leader 切换成功
- Docker 双 PMS 收敛成功
- Docker 双 PMS meta 同步成功
- Docker 双 PMS leader 切换成功

## 相关原始文档

- `docs/cn/multi-pms.md`
- `pc-pms/run.sh`
- `pc-pms/src/main/java/com/cloud/pc/config/Envs.java`

## 一、原生双 PMS 验证

### 验证目标

- 第二个 PMS 可以通过 `pms.existing.url` 加入第一个 PMS
- 第二个 PMS 可以同步第一个 PMS 的 meta
- leader 可以手动切换
- 旧 leader 写失败，新 leader 写成功

### 启动方式

使用 Windows 本机直接起两个 PMS 进程，避免和 Docker 版 `8080` 端口冲突：

- `pms1`: `127.0.0.1:18080`
- `pms2`: `127.0.0.1:18081`

核心参数：

- `pms1`
  - `-Dpms.enable.write=true`
  - `-Dpms.public.url=http://127.0.0.1:18080/`
- `pms2`
  - `-Dpms.enable.write=false`
  - `-Dpms.existing.url=http://127.0.0.1:18080/`
  - `-Dpms.public.url=http://127.0.0.1:18081/`

### 关键观察

原生双 PMS 首次验证时出现了一个很关键的现象：

- `pms2` 已经加入了心跳链路
- 但 `pms2` 的 `meta` 目录一开始仍然是空的
- 直接查询 `http://127.0.0.1:18081/api/v1/pb/demo-minio/info` 会报：
  - `Cannot invoke "java.util.Map.get(Object)" because "this.keyMap" is null`

从代码行为看，这说明：

- `pms2` 已启动成功
- 但第一次 meta 同步尚未触发

### 为什么第一次同步没有立刻发生

从 `PmsService.receivePulse(...)` 的实现看，只有收到的 `metaVersion` 更大时，从节点才会调用 `syncMetaFrom(...)`。

而这次验证使用的是 seed meta：

- 初始 `lastUpdateTime` 很多为 `0`
- 因此一开始 `metaVersion` 可能没有明显变化
- 双 PMS 会互相看到，但不会自动触发第一次拉取

### 如何触发第一次同步

在 `pms1` 上做一次真实 meta 写入，例如新增一条 secret，`metaVersion` 就会变化。

这之后 `pms2` 日志出现了：

```text
load meta down from http://127.0.0.1:18080/api/v1/pms/meta!
```

随后 `pms2` 的 `meta` 目录生成了：

- `pbucket`
- `secret`
- `vendor`
- `vendorbucket`

这说明原始项目的多 PMS 同步机制本身是成立的，只是“纯 seed meta + 初始 version 不变化”时不会自动触发首轮同步。

### leader 切换验证结果

原生版已经验证通过：

- `pms1` 降为 follower
- `pms2` 升为 leader
- `pms1` 写入失败
- `pms2` 写入成功
- `pms1` 停掉后，`pms2` 仍能继续提供查询服务

验证通过的关键现象：

- `http://127.0.0.1:18081/api/v1/pms/list` 中 `pms2` 为 `leader: true`
- 旧 leader 写入返回 `500`
- 新 leader 写入成功返回新增 secret
- `http://127.0.0.1:18081/api/v1/pb/demo-minio/info` 返回正常

## 二、Docker 双 PMS 收敛

### 目标

在已经确认原始项目多 PMS 逻辑成立后，再把它收敛到 Docker 部署里，验证容器环境下同样能成立。

### 新增文件

为了不影响原有单 PMS quickstart，这次 Docker 双 PMS 使用单独的覆盖文件：

- `docker-compose.multi-pms.yml`

它的作用是：

- 复用原有 `docker-compose.yml`
- 新增 `pms2`
- 给 `pms2` 单独分配卷目录
- 让 `pms2` 通过 `PMS_EXISTING_URL=http://pms:8080/` 加入集群

### Docker 双 PMS 核心配置

- `pms`
  - `PMS_PUBLIC_URL=http://pms:8080/`
- `pms2`
  - `ports: 8081:8080`
  - `PMS_EXISTING_URL=http://pms:8080/`
  - `PMS_PUBLIC_URL=http://pms2:8080/`
  - 独立 meta/log 卷

这样做的原因很明确：

- 多个 PMS 在容器内部必须用容器网络地址互通
- 不能继续用 `localhost` 作为容器之间的互访地址

### Docker 双 PMS 验证结果

Docker 环境下已经验证通过：

- `pms`
- `pms2`
- `pcp`
- `minio`

都能正常启动。

并且 `pms2` 日志中已经出现：

```text
load meta down from http://pms:8080/api/v1/pms/meta!
```

同时：

```text
http://localhost:8081/api/v1/pb/demo-minio/info
```

已经能返回 `demo-minio` 的 bucket 信息。

这说明：

- Docker 双 PMS 加入成功
- Docker 双 PMS meta 同步成功

### Docker leader 切换验证结果

Docker 版也已经验证通过：

- `pms` 降为 follower
- `pms2` 升为 leader
- 旧 leader 写失败
- 新 leader 写成功
- 新 leader 继续提供查询服务

验证通过的关键现象：

- `http://localhost:8081/api/v1/pms/list` 中 `http://pms2:8080/` 为 `leader: true`
- `http://localhost:8080/api/v1/secret/add` 返回 `500`
- `http://localhost:8081/api/v1/secret/add` 成功返回新增 secret
- `http://localhost:8081/api/v1/pb/demo-minio/info` 返回正常

## 三、这条验证线最终说明了什么

到这里可以比较稳地给出结论：

- 原始项目的多 PMS 机制不是纸面设计，实际可运行
- 当前仓库补充的 Docker 部署并没有破坏多 PMS 能力
- 单 PMS、认证模式、多 PMS、Docker 收敛这几条主线现在都已经跑通

## 四、一个值得记录的实现边界

这次验证里最值得单独记录的点是：

- 首轮 meta 同步依赖 `metaVersion` 变化
- 因此“纯 seed meta + 初始 version 不变化”的场景下，第二个 PMS 可能先加入成功，但不会自动拉 meta

这不影响多 PMS 最终成立，但会影响第一次验证时的直观体验。

如果后续要继续优化这条链路，比较自然的方向是：

- 在从节点首次加入时主动触发一次 meta 拉取
- 或者在 leader 上对 seed meta 初始化阶段写入明确的更新时间

## 五、推荐阅读顺序

如果后来的人要复现这条验证线，建议按这个顺序：

1. `docs/cn/multi-pms.md`
2. 本文档
3. 先跑原生双 PMS
4. 再跑 Docker 双 PMS

这样最容易把“项目能力问题”和“部署层问题”拆开看清楚。
