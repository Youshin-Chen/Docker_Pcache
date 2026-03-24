# Windows 一键部署问题档案

本文档记录本次 `Windows + Docker Desktop + docker compose` 落地过程中遇到的实际问题，和项目原始文档区分开保存。

## 适用范围

- Windows 宿主机
- Docker Desktop
- 当前仓库的一键 quickstart 方案

## 一、原项目代码在本次场景下暴露的问题

### 1. `PCP` 启动时报 `no protocol: api/v1/pms/pcp/pulse`

现象：

- `pcache-pcp` 日志出现 `java.net.MalformedURLException: no protocol: api/v1/pms/pcp/pulse`

原因：

- 原始 `UrlProbe` 在拿不到可用 `PMS` 地址列表时，可能返回空值
- 后续再拼接 `/api/v1/pms/pcp/pulse`，就会形成无协议的坏 URL

处理：

- 在 `pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java` 增加 base URL 回退逻辑
- 增加 `pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java` 覆盖该场景

结果：

- `PCP` 在 `PMS` 列表暂时为空时，不会再拼出非法 URL

### 2. `pcmd` 在缺少 `ak/sk` 时直接 panic

现象：

- `pcmd put` 或 `pcmd get` 在配置缺失时出现空指针崩溃

原因：

- `NewPBucket` 返回错误后，原代码没有及时 `return`
- 后面继续对空对象调用方法，触发 panic

处理：

- 修复 `pcmd/put.go`
- 修复 `pcmd/get.go`

结果：

- 现在会直接返回错误，不再因为缺少凭证而崩溃

### 3. `pcmd sync` 下载权限参数错误

现象：

- 下载方向的 `sync` 权限字符串原本是一个错误的逗号拼接值

原因：

- 原代码把 `GetObject,ListObject` 放成了一个字符串

处理：

- 修复 `pcmd/sync.go`

结果：

- 下载方向的 `sync` 现在会正确申请 `GetObject` 和 `ListObject`

### 4. `pcmd put -h` 显示成 `get` 的帮助信息

现象：

- `pcmd put -h` 输出 `Usage of get`

原因：

- `pcmd/put.go` 里 `FlagSet` 被误写成了 `"get"`

处理：

- 修复 `pcmd/put.go`
- 同时修正 `skip-existing` 默认值等 CLI 细节

结果：

- `pcmd` 帮助信息和参数默认值恢复正常

## 二、Docker 一键部署场景下暴露的问题

### 5. `PCP` 重启后向 `localhost:8080` 发心跳，出现 `Connection refused`

现象：

- `pcache-pcp` 日志出现：
  - `report fail url http://localhost:8080/api/v1/pms/pcp/pulse`
  - `java.net.ConnectException: Connection refused`

原因：

- 为了方便宿主机访问，`PMS` 对外注册成了 `http://localhost:8080/`
- 这对浏览器和 `pcmd` 是正确的
- 但 `PCP` 容器内部拿到这个地址后，会把 `localhost` 当成自己，而不是 `pms` 容器

处理：

- 修复 `pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java`
- 当 `PCP` 发现 `PMS` 返回的是 loopback 地址时，自动回退到内部地址 `PCP_PMS_URL`

结果：

- `PCP` 可以继续对宿主机暴露 `localhost`
- 同时又能在容器内正确访问 `pms`

### 6. 整套服务重启时，`PCP` 可能先于 `PMS` 启动

现象：

- `docker compose restart` 后，`PCP` 有概率先发起探测
- 如果这时 `PMS` 端口还没起来，就会出现一次瞬时连接失败

原因：

- `depends_on` 只保证启动顺序，不保证应用层 readiness

处理：

- 修复 `docker/pcp-entrypoint.sh`
- 在真正启动 `PCP` 进程前，先等待 `PMS` 端口可连接

结果：

- 重启窗口期的瞬时报错显著减少
- `PCP` 启动稳定性更好

### 7. Docker 拉取基础镜像时出现 `EOF` 或镜像源失败

现象：

- 构建阶段出现 `failed to copy`、`EOF`、镜像源拉取失败

原因：

- 国内镜像源不稳定
- 不是项目代码问题

处理：

- 优先使用当前仓库的 `docker-compose.yml`
- 必要时重试构建
- 必要时调整 Docker Desktop 镜像源

结果：

- 问题属于环境网络层，不属于项目功能缺陷

## 三、Windows / PowerShell 使用过程中的问题

### 8. PowerShell here-string 写法导致配置命令报错

现象：

- 出现 `here-string 标题后面和行尾之前不允许包含任何字符`
- 或 `表达式或语句中包含意外的标记`

原因：

- PowerShell 的 here-string 必须单独占行
- 不能把 `@"` 和正文内容写到同一行

正确写法：

```powershell
@"
endpoint=http://localhost:8080
ak=demo-user
sk=l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw=
"@ | Set-Content -Path "$HOME\.pcmd.cfg" -Encoding ascii
```

### 9. `.\pcmd\pcmd.exe` 无法识别

现象：

- PowerShell 提示找不到 `.\pcmd\pcmd.exe`

原因：

- 当前目录不在仓库根目录
- 不是 `pcmd.exe` 本身不存在

处理：

- 先执行 `Set-Location D:\pcache`
- 或直接使用绝对路径：

```powershell
& "D:\pcache\pcmd\pcmd.exe" put "D:\pcache\demo-data\a.txt" "s3://demo-minio/test/a.txt"
```

### 10. `Invoke-RestMethod` 读取 `/api/v1/pcp/list` 时按错结构

现象：

- PowerShell 报 `无法对 Null 数组进行索引`

原因：

- `/api/v1/pcp/list` 返回的是数组
- 不能按 `.value[0]` 方式读取

正确写法：

```powershell
$list = @(Invoke-RestMethod "http://localhost:8080/api/v1/pcp/list")
$first = $list[0]
```

### 11. Swagger 页面里“看起来没有返回”

现象：

- 在 Swagger 页面里打开接口定义时，看起来没有数据

原因：

- Swagger 只是展示接口定义
- 只有点击 `Execute` 后才会实际发请求

结论：

- 这不是后端故障

## 四、跨平台行尾问题

### 12. Windows 提交后可能把脚本变成 `CRLF`

现象：

- Shell 脚本、Dockerfile、YAML 在 Ubuntu 或容器内可能出现隐患

原因：

- Windows 默认容易产生 `CRLF`

处理：

- 新增 `.gitattributes`
- 对本次相关脚本、Docker 文件、文档、Java、Go 文本统一为 `LF`

结果：

- 这套 quickstart 在 Windows 开发、Linux 容器运行的场景下更稳定

## 五、验证结论

本次问题处理后，已经实际验证通过：

- 一键 `docker compose up -d --build`
- 干净重建
- `PMS` / `PCP` 注册
- `pcmd put/get/sync`
- `STS` 下发
- `MinIO` 后端落对象
- `PCP` 缓存增长
- `PCP` 单独重启
- 整套服务重启
- `PCP` 对 `PMS` 心跳恢复正常

## 六、与本次问题直接相关的文件

- `docker-compose.yml`
- `docker/pms-entrypoint.sh`
- `docker/pcp-entrypoint.sh`
- `.gitattributes`
- `pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java`
- `pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java`
- `pc-common/src/main/java/com/cloud/pc/utils/ServiceUrlUtils.java`
- `pc-common/src/test/java/com/cloud/pc/utils/ServiceUrlUtilsTest.java`
- `pc-pms/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pms/src/main/java/com/cloud/pc/service/PmsService.java`
- `pc-pcp/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java`
- `pcmd/get.go`
- `pcmd/put.go`
- `pcmd/sync.go`
