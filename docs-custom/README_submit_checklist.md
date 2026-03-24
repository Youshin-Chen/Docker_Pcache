# 仓库提交清单

本文档也是当前仓库新增的补充文档，只用于整理这套 Windows 一键部署改动的提交范围。

## 应提交的文件

基础交付文件：

- `.dockerignore`
- `.gitattributes`
- `.gitignore`
- `docker-compose.yml`
- `Dockerfile.pms`
- `Dockerfile.pcp`

Docker 启动与初始化文件：

- `docker/pms-entrypoint.sh`
- `docker/pcp-entrypoint.sh`
- `docker/start-windows.ps1`
- `docker/quickstart.env.example`
- `docker/quickstart/meta/pbucket`
- `docker/quickstart/meta/secret`
- `docker/quickstart/meta/vendor`
- `docker/quickstart/meta/vendorbucket`

Java 侧改动：

- `pc-common/src/main/java/com/cloud/pc/utils/ServiceUrlUtils.java`
- `pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java`
- `pc-common/src/test/java/com/cloud/pc/utils/ServiceUrlUtilsTest.java`
- `pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java`
- `pc-pms/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pms/src/main/java/com/cloud/pc/service/PmsService.java`
- `pc-pcp/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java`

Go CLI 改动：

- `pcmd/get.go`
- `pcmd/put.go`
- `pcmd/sync.go`

补充文档：

- `docs-custom/README_one_click_windows.md`
- `docs-custom/README_submit_checklist.md`
- `docs-custom/README_troubleshooting_windows_quickstart.md`

## 不应提交的本地产物

这些文件或目录只用于本地运行和测试，不应入库：

- `docker-data/`
- `demo-data/`
- `demo-download/`
- `verify-data/`
- `pc-common/target/`
- `pc-pcp/target/`
- `pc-pms/target/`
- `pcmd/pcmd.exe`
- `pcmd/hello.txt`
- `pcmd/hello.out.txt`

## 推荐加入版本控制的命令

```powershell
git add `
  .dockerignore `
  .gitattributes `
  .gitignore `
  docker-compose.yml `
  Dockerfile.pms `
  Dockerfile.pcp `
  docker/pms-entrypoint.sh `
  docker/pcp-entrypoint.sh `
  docker/start-windows.ps1 `
  docker/quickstart.env.example `
  docker/quickstart/meta/pbucket `
  docker/quickstart/meta/secret `
  docker/quickstart/meta/vendor `
  docker/quickstart/meta/vendorbucket `
  pc-common/src/main/java/com/cloud/pc/utils/ServiceUrlUtils.java `
  pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java `
  pc-common/src/test/java/com/cloud/pc/utils/ServiceUrlUtilsTest.java `
  pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java `
  pc-pms/src/main/java/com/cloud/pc/config/Envs.java `
  pc-pms/src/main/java/com/cloud/pc/service/PmsService.java `
  pc-pcp/src/main/java/com/cloud/pc/config/Envs.java `
  pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java `
  pcmd/get.go `
  pcmd/put.go `
  pcmd/sync.go `
  docs-custom/README_one_click_windows.md `
  docs-custom/README_submit_checklist.md `
  docs-custom/README_troubleshooting_windows_quickstart.md
```

## 启动方式

这套环境的主入口还是仓库根目录：

```powershell
docker compose up -d --build
```

如果你想给别人一个更直接的 Windows 启动方式，也可以用：

```powershell
powershell -ExecutionPolicy Bypass -File .\docker\start-windows.ps1
```
