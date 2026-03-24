# Windows 认证模式补充说明

本文档只描述当前仓库这套 `Windows + Docker Desktop + docker compose` quickstart 如何切换到完整认证模式。

- 原始项目文档保持不动
- 本文档只放在 `docs-custom/`
- 认证模式已经实际跑通，最终 `pcmd get` 返回结果为 `auth mode ok`

## 适用范围

- Windows
- Docker Desktop
- 当前仓库根目录的 `docker-compose.yml`
- 本地已经能编译 `pcmd.exe`

## 这套认证模式验证了什么

- `PMS_ENABLE_TOKEN=true` 后，PMS 接口开始要求 `X-AK` + `X-TOKEN`
- `PCP` 心跳在认证开启后仍然可以正常上报
- `demo-user` 只保留业务访问权限，不具备管理权限
- `pms-admin` 可以访问管理接口
- `pcmd` 在认证模式下仍可正常 `put/get`
- 最终验证文件内容为 `auth mode ok`

## 1. 切换到认证模式

如果你之前已经跑过无认证模式，建议直接做一次干净重建。原因很简单：

- `docker-data/quickstart/pms/meta` 会持久化
- `docker/quickstart/meta/secret` 里的新 seed 数据不会自动覆盖旧数据
- 认证模式依赖新增的 `ak-pcp-admin`

执行下面这组命令：

```powershell
Set-Location D:\pcache
$env:PMS_ENABLE_TOKEN = "true"

docker compose down --remove-orphans
docker rm -f pcache-minio pcache-pms pcache-pcp pcache-minio-init 2>$null
docker network rm pcache_default 2>$null
Remove-Item -Recurse -Force .\docker-data\quickstart -ErrorAction SilentlyContinue

docker compose up -d --build
docker compose ps
```

如果你想把认证模式固定下来，也可以在仓库根目录额外创建一个 `.env`，内容如下：

```text
PMS_ENABLE_TOKEN=true
```

## 2. 生成 `pms-admin` 管理 token

```powershell
$pmsToken = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/v1/secret/token" -ContentType "application/json" -Body (@{
  accessKey = "pms-admin"
  secretKey = "QPAAmgJVWUTzrRC9lGDMRJo6mCd4XWK6+tolzsWmgO4="
  expirationMs = 1800000
  claims = @{}
  description = "pms admin token"
} | ConvertTo-Json -Depth 5)

$pmsHeaders = @{
  "X-AK" = "pms-admin"
  "X-TOKEN" = $pmsToken
}
```

## 3. 先验证“未带 token 会被拒绝”

直接请求下面这个接口：

```powershell
Invoke-RestMethod "http://localhost:8080/api/v1/pms/list"
```

预期：

- 请求失败
- 常见报错为 `missing ak/token`

这一步的目的只是确认认证模式确实打开了。

## 4. 验证管理接口可用

带上 `pms-admin` 头之后，下面这些接口应该能正常返回：

```powershell
Invoke-RestMethod -Headers $pmsHeaders "http://localhost:8080/api/v1/pms/list" | ConvertTo-Json -Depth 5
Invoke-RestMethod -Headers $pmsHeaders "http://localhost:8080/api/v1/pcp/list" | ConvertTo-Json -Depth 5
Invoke-RestMethod -Headers $pmsHeaders "http://localhost:8080/api/v1/pms/meta"
```

如果这里能拿到结果，说明：

- `pms-admin` 凭证有效
- PMS 管理接口权限校验已经打通
- PCP 心跳也已经在认证模式下成功注册

## 5. 生成 `demo-user` 业务 token

```powershell
$demoToken = Invoke-RestMethod -Method Post -Uri "http://localhost:8080/api/v1/secret/token" -ContentType "application/json" -Body (@{
  accessKey = "demo-user"
  secretKey = "l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw="
  expirationMs = 1800000
  claims = @{}
  description = "demo user token"
} | ConvertTo-Json -Depth 5)

$demoHeaders = @{
  "X-AK" = "demo-user"
  "X-TOKEN" = $demoToken
}
```

## 6. 验证“业务权限可以，管理权限不行”

先验证业务接口：

```powershell
Invoke-RestMethod -Headers $demoHeaders "http://localhost:8080/api/v1/pb/demo-minio/info" | ConvertTo-Json -Depth 5
Invoke-RestMethod -Headers $demoHeaders "http://localhost:8080/api/v1/pb/demo-minio/sts?permissions=GetObject,ListObject" | ConvertTo-Json -Depth 5
```

然后验证管理接口应当被拒绝：

```powershell
try {
  Invoke-RestMethod -Headers $demoHeaders "http://localhost:8080/api/v1/pms/meta"
  throw "unexpected success"
} catch {
  $_.Exception.Message
}
```

预期：

- `demo-user` 能获取 bucket 信息和 STS
- `demo-user` 访问 `/api/v1/pms/meta` 会失败
- 常见报错包含 `IAM error`

## 7. 用 `pcmd` 验证认证模式

先写入客户端配置：

```powershell
@"
endpoint=http://localhost:8080
ak=demo-user
sk=l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw=
"@ | Set-Content -Path "$HOME\.pcmd.cfg" -Encoding ascii
```

然后执行上传、下载和结果检查：

```powershell
New-Item -ItemType Directory -Force .\verify-data | Out-Null
Set-Content -Path .\verify-data\auth-mode.txt -Value "auth mode ok" -Encoding ascii

& "D:\pcache\pcmd\pcmd.exe" put "D:\pcache\verify-data\auth-mode.txt" "s3://demo-minio/auth-mode/auth-mode.txt"
& "D:\pcache\pcmd\pcmd.exe" get "s3://demo-minio/auth-mode/auth-mode.txt" "D:\pcache\verify-data\auth-mode.out.txt"

Get-Content "D:\pcache\verify-data\auth-mode.out.txt"
```

预期最终输出：

```text
auth mode ok
```

## 8. 本次认证模式能跑通，依赖了哪些关键点

- `docker-compose.yml` 中的 `PMS_ENABLE_TOKEN` 已改为可通过环境变量切换
- `docker/quickstart/meta/secret` 已预置 `pms-admin`、`demo-user`、`ak-pcp-admin`
- `PMS` 内部调用已改为生成合法 token，而不是把原始 `SK` 直接当成 `X-TOKEN`
- `PCP` 心跳使用 `ak-pcp-admin`
- 管理接口权限已收紧为 `pms:admin` 或 `pcp:admin`

## 9. 推荐结论

如果你要把这套仓库交给别人直接拉起，建议保留两种模式：

- 默认 quickstart：`PMS_ENABLE_TOKEN=false`
- 完整认证模式：在文档里明确写出 `PMS_ENABLE_TOKEN=true` 和干净重建步骤

这样别人第一次可以先快速跑通，第二次再切到完整认证模式，不容易卡住。
