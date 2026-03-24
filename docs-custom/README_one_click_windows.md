# Windows 一键部署补充说明

本文档是当前仓库新增的补充文档，用来和项目原始文档区分。

- 原始文档目录仍然是 `docs/`
- 本文档只描述当前仓库这套本地一键部署方案
- 目标是让任何人在 Windows 上 `git clone` 后，用 Docker Desktop 直接拉起一个可验证的本地演示环境

## 这套环境会启动什么

根目录的 `docker-compose.yml` 会启动 4 个服务：

- `minio`
- `minio-init`
- `pms`
- `pcp`

默认端口：

- `8080`: PMS
- `8091`: PCP
- `9000`: MinIO API
- `9001`: MinIO Console

## 前置条件

- Windows
- Docker Desktop
- Docker Desktop 已切到 Linux containers

## 启动命令

在仓库根目录执行：

```powershell
docker compose up -d --build
```

## 干净重建

如果你想回到这套 quickstart 的初始状态，执行：

```powershell
docker compose down --remove-orphans
docker rm -f pcache-minio pcache-pms pcache-pcp pcache-minio-init 2>$null
docker network rm pcache_default 2>$null
Remove-Item -Recurse -Force .\docker-data\quickstart -ErrorAction SilentlyContinue
docker compose up -d --build
```

这会清掉本地 quickstart 数据，并让 PMS 重新导入仓库里的 seed meta。

## 启动后默认可用内容

默认会预置以下资源：

- 演示桶：`demo-minio`
- 演示访问账号：`demo-user`
- 演示密钥：`l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw=`
- MinIO Bucket：`minio-test`

PMS 默认地址：

```text
http://localhost:8080
```

Swagger：

```text
http://localhost:8080/swagger-ui/index.html
```

MinIO Console：

```text
http://localhost:9001
```

MinIO root 账号默认值来自 `docker/quickstart.env.example`：

```text
MINIO_ROOT_USER=minioadmin
MINIO_ROOT_PASSWORD=minioadmin123
```

## 快速自检

启动后建议先检查：

```powershell
docker compose ps
docker compose logs --tail=100 pms
docker compose logs --tail=100 pcp
```

然后访问 Swagger 并验证这些接口：

- `/api/v1/pms/list`
- `/api/v1/pcp/list`
- `/api/v1/pb/demo-minio/info`

## pcmd 最小验证

如果你已经编译好了 `pcmd.exe`，可以直接做一次上传下载验证。

先写入 `~/.pcmd.cfg`：

```powershell
@"
endpoint=http://localhost:8080
ak=demo-user
sk=l2VInj4kTB9Um9d7WEiJxNx2AUkXiyxCF3/e4n/JgPw=
"@ | Set-Content -Path "$HOME\.pcmd.cfg" -Encoding ascii
```

准备测试文件并上传：

```powershell
Set-Content -Path .\pcmd\hello.txt -Value "hello pcache" -Encoding ascii
.\pcmd\pcmd.exe put .\pcmd\hello.txt s3://demo-minio/hello.txt
```

下载回本地并检查：

```powershell
.\pcmd\pcmd.exe get s3://demo-minio/hello.txt .\pcmd\hello.out.txt
Get-Content .\pcmd\hello.out.txt
```

## 这份补充文档对应的实现

当前这套 quickstart 依赖以下文件：

- `docker-compose.yml`
- `Dockerfile.pms`
- `Dockerfile.pcp`
- `docker/pms-entrypoint.sh`
- `docker/quickstart/meta/*`
- `docker/quickstart.env.example`

如果你修改了 seed meta 或默认账号，最稳妥的方式就是执行一次“干净重建”。
