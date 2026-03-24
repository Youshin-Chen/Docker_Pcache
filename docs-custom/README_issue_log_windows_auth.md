# Windows 落地问题记录

本文档记录这次在 `Windows + Docker Desktop + docker compose` 落地当前项目时，真实遇到的问题、原因和处理方式。

- 原始项目文档不改
- 本文档只放在 `docs-custom/`
- 覆盖范围包括 quickstart、`pcmd`、以及完整认证模式

## 1. `CRLF` / `LF` 行尾隐患

### 现象

- Windows 下编辑脚本、`Dockerfile`、`yml` 后，容易混入 `CRLF`
- 这类文件进容器或 Ubuntu 后，可能出现隐藏问题

### 处理

- 新增 `.gitattributes`
- 把本次相关脚本、Docker 文件、配置文件统一为 `LF`

### 关于 Ubuntu

如果你是在 Ubuntu 上直接 `git clone`，Git 默认通常会保留 `LF`，风险比 Windows 小很多。

但这不代表绝对安全。只要仓库里已经被提交进去了 `CRLF` 内容，Ubuntu 机器拿到的也可能就是带问题的文本。所以：

- Ubuntu 侧风险更低
- 但仓库层面仍然应该用 `.gitattributes` 固化行尾策略

## 2. Docker 拉取基础镜像时出现 `EOF`

### 现象

- `docker compose up -d --build` 过程中拉镜像失败
- 常见报错为 `failed to copy`、`EOF`

### 原因

- 主要是镜像源或网络链路不稳定
- 不是项目代码逻辑问题

### 处理

- 继续使用仓库内这份 `docker-compose.yml`
- 重试构建
- 必要时调整 Docker Desktop 镜像源

## 3. `PCP` 启动时报 `no protocol: api/v1/pms/pcp/pulse`

### 现象

- `pcache-pcp` 日志出现 `java.net.MalformedURLException`
- 关键报错是 `no protocol: api/v1/pms/pcp/pulse`

### 原因

- `UrlProbe` 在特定场景下拿不到可用的 base URL
- 后续继续拼接相对路径，形成了坏掉的 URL

### 处理

- 修复 `UrlProbe` 的 base URL 回退逻辑
- 增加对应测试

## 4. `PCP` 心跳打到 `localhost:8080`，容器内出现 `Connection refused`

### 现象

- `PCP` 暴露给宿主机的地址是 `http://localhost:8091/`
- 但容器内部拿到 `http://localhost:8080/` 去访问 `PMS` 时失败

### 原因

- 对宿主机来说，`localhost:8080` 是正确的
- 但对 `PCP` 容器来说，`localhost` 指向它自己，不是 `pms` 容器

### 处理

- 保留对外可用的 `localhost`
- 在 `PCP` 内部回退到 `PCP_PMS_URL=http://pms:8080/`

## 5. `PCP` 可能先于 `PMS` 启动

### 现象

- `docker compose restart` 后，`PCP` 偶发先发起探测
- `PMS` 端口还没 ready 时会短暂报错

### 原因

- `depends_on` 只保证启动顺序，不保证应用 ready

### 处理

- 在 `docker/pcp-entrypoint.sh` 增加等待 `PMS` 端口可连通的逻辑

## 6. Swagger 页面“看起来没有返回”

### 现象

- 在 `swagger-ui` 里打开接口定义时，看起来没有数据

### 原因

- Swagger 默认只是展示接口定义
- 只有点击 `Execute` 才会真正发请求

### 结论

- 这不是后端故障
- 是 Swagger 的正常使用方式

## 7. PowerShell here-string 写法容易出错

### 现象

- 出现 `here-string 标题后面和行尾之前不允许包含任何字符`
- 或者出现 `意外的标记`

### 原因

- `@"` 必须单独占一行
- 结束符 `"@` 也必须单独占一行

### 正确写法

```powershell
@"
endpoint=http://localhost:8080
ak=demo-user
sk=l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw=
"@ | Set-Content -Path "$HOME\.pcmd.cfg" -Encoding ascii
```

## 8. `.\pcmd\pcmd.exe` 找不到

### 现象

- PowerShell 提示 `.\pcmd\pcmd.exe` 不是可执行命令

### 原因

- 当前目录不在仓库根目录
- 不是 `pcmd.exe` 本身有问题

### 处理

- 先 `Set-Location D:\pcache`
- 或者直接使用绝对路径执行

## 9. `Invoke-RestMethod` 读取数组时取错结构

### 现象

- 出现 `无法对 Null 数组进行索引`

### 原因

- `/api/v1/pcp/list` 返回的是数组
- 不能直接假设一定有 `.value[0]`

### 处理

```powershell
$list = @(Invoke-RestMethod "http://localhost:8080/api/v1/pcp/list")
$first = $list[0]
```

## 10. `pcmd` 缺少 `ak/sk` 时直接 panic

### 现象

- `pcmd put/get` 在缺配置时出现空指针崩溃

### 原因

- 构造 bucket 失败后，原逻辑没有及时返回
- 后续继续对空对象调用方法

### 处理

- 修复 `pcmd/get.go`
- 修复 `pcmd/put.go`

## 11. 认证模式下，PMS 内部调用原来把原始 `SK` 当作 `X-TOKEN`

### 现象

- 开启 `PMS_ENABLE_TOKEN=true` 后，内部调用会失败

### 原因

- 以前的内部调用把 `Envs.sk` 直接塞进 `X-TOKEN`
- 这在完整认证模式下不是合法 token

### 处理

- 改为使用 `SecretUtils.generateToken(...)` 动态生成 token

## 12. 认证模式下，`PCP` 心跳还需要单独的管理身份

### 现象

- `PCP` 向 `PMS` 上报心跳时会被鉴权拦截

### 原因

- 认证开启后，`/api/v1/pms/pcp/pulse` 不能再匿名访问
- `PCP` 需要一组具备 `pcp:admin` 的固定凭证

### 处理

- 在 `docker/quickstart/meta/secret` 里新增 `ak-pcp-admin`
- `docker-compose.yml` 里为 `PCP` 注入 `PCP_AK` / `PCP_SK`

## 13. 管理接口原本没有完全按 `pms:admin` / `pcp:admin` 收紧

### 现象

- 认证开启后，业务账号和管理账号的边界不够清晰

### 处理

- `secret/add`、`secret/iam/bucket` 改为要求 `pms:admin`
- `vendor/add`、`vendor/bucket/add`、`vendor/bucket/list` 改为要求 `pms:admin`
- `pb/add` 改为要求 `pms:admin`
- `pcp/add`、`pcp/remove` 改为要求 `pcp:admin` 或 `pms:admin`
- `pms/pcp/pulse` 改为要求 `pcp:admin` 或 `pms:admin`
- `pms/pms/pulse`、`pms/meta`、`pms/leader/enable` 改为要求 `pms:admin`

## 14. 鉴权错误信息原来不够直接

### 现象

- 出错时不容易立刻判断是 `AK` 缺失、token 缺失还是 `AK` 不存在

### 处理

- 补充更明确的错误信息：
  - `missing ak/token`
  - `invalid ak`
  - `missing iam policy`
  - `IAM error: the AK does not have the required permissions`

## 15. 本次最终验证结果

下面这些都已经实际验证通过：

- 无认证 quickstart 启动
- 干净重建
- `PMS` / `PCP` 注册
- `pcmd put/get/sync`
- STS 下发
- MinIO 后端落对象
- PCP 缓存增长
- `PCP` 单独重启
- 整套服务重启
- 完整认证模式
- 认证模式下 `pcmd get` 最终输出 `auth mode ok`

## 16. 本文档对应的核心文件

- `docker-compose.yml`
- `docker/pms-entrypoint.sh`
- `docker/pcp-entrypoint.sh`
- `.gitattributes`
- `pc-common/src/main/java/com/cloud/pc/utils/ServiceUrlUtils.java`
- `pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java`
- `pc-common/src/test/java/com/cloud/pc/utils/ServiceUrlUtilsTest.java`
- `pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java`
- `pc-pcp/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java`
- `pc-pms/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pms/src/main/java/com/cloud/pc/service/PmsService.java`
- `pc-pms/src/main/java/com/cloud/pc/service/SecretService.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PBucketController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PcpController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PmsController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/SecretController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/VendorController.java`
- `pcmd/get.go`
- `pcmd/put.go`
- `pcmd/sync.go`
