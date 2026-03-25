# 仓库提交清单

本文档用于整理这套 Windows 一键部署和认证模式补充改动，在最终统一提交前做一次对照。

## 建议纳入最终提交的文件

### 根目录与 Docker 相关

- `.dockerignore`
- `.gitattributes`
- `.gitignore`
- `docker-compose.yml`
- `docker-compose.multi-pms.yml`
- `Dockerfile.pms`
- `Dockerfile.pcp`

### Docker 启动与 quickstart seed

- `docker/pms-entrypoint.sh`
- `docker/pcp-entrypoint.sh`
- `docker/start-windows.ps1`
- `docker/quickstart.env.example`
- `docker/quickstart/meta/pbucket`
- `docker/quickstart/meta/secret`
- `docker/quickstart/meta/vendor`
- `docker/quickstart/meta/vendorbucket`

### Java 公共能力与 URL/心跳修复

- `pc-common/src/main/java/com/cloud/pc/utils/ServiceUrlUtils.java`
- `pc-common/src/main/java/com/cloud/pc/utils/UrlProbe.java`
- `pc-common/src/test/java/com/cloud/pc/utils/ServiceUrlUtilsTest.java`
- `pc-common/src/test/java/com/cloud/pc/utils/UrlProbeTest.java`
- `pc-common/src/test/java/com/cloud/pc/utils/FileUtilsTest.java`
- `pc-common/src/test/java/com/cloud/pc/utils/SecretUtilsTest.java`
- `pc-pcp/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java`
- `pc-pms/src/main/java/com/cloud/pc/config/Envs.java`
- `pc-pms/src/main/java/com/cloud/pc/service/PmsService.java`

### Java 认证模式与权限收紧

- `pc-pms/src/main/java/com/cloud/pc/service/SecretService.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PBucketController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PcpController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/PmsController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/SecretController.java`
- `pc-pms/src/main/java/com/cloud/pc/controller/VendorController.java`

### Go CLI 修复

- `pcmd/get.go`
- `pcmd/put.go`
- `pcmd/sync.go`

### 补充文档

- `README_START_HERE.md`
- `docs-custom/README_one_click_windows.md`
- `docs-custom/README_troubleshooting_windows_quickstart.md`
- `docs-custom/README_auth_mode_windows.md`
- `docs-custom/README_multi_pms_native_and_docker.md`
- `docs-custom/README_issue_log_windows_auth.md`
- `docs-custom/README_choose_ubuntu_or_docker.md`
- `docs-custom/README_submit_checklist.md`

## 不应提交的本地产物

这些目录或文件只属于本地构建、运行和验证，不建议入库：

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
- `pcmd/auth-mode.txt`
- `pcmd/auth-mode.out.txt`

## 统一加入版本控制时的参考命令

```powershell
git add `
  .dockerignore `
  .gitattributes `
  .gitignore `
  docker-compose.yml `
  docker-compose.multi-pms.yml `
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
  pc-common/src/test/java/com/cloud/pc/utils/FileUtilsTest.java `
  pc-common/src/test/java/com/cloud/pc/utils/SecretUtilsTest.java `
  pc-pcp/src/main/java/com/cloud/pc/config/Envs.java `
  pc-pcp/src/main/java/com/cloud/pc/pulse/PulseTask.java `
  pc-pms/src/main/java/com/cloud/pc/config/Envs.java `
  pc-pms/src/main/java/com/cloud/pc/service/PmsService.java `
  pc-pms/src/main/java/com/cloud/pc/service/SecretService.java `
  pc-pms/src/main/java/com/cloud/pc/controller/PBucketController.java `
  pc-pms/src/main/java/com/cloud/pc/controller/PcpController.java `
  pc-pms/src/main/java/com/cloud/pc/controller/PmsController.java `
  pc-pms/src/main/java/com/cloud/pc/controller/SecretController.java `
  pc-pms/src/main/java/com/cloud/pc/controller/VendorController.java `
  pcmd/get.go `
  pcmd/put.go `
  pcmd/sync.go `
  README_START_HERE.md `
  docs-custom/README_one_click_windows.md `
  docs-custom/README_troubleshooting_windows_quickstart.md `
  docs-custom/README_auth_mode_windows.md `
  docs-custom/README_multi_pms_native_and_docker.md `
  docs-custom/README_issue_log_windows_auth.md `
  docs-custom/README_choose_ubuntu_or_docker.md `
  docs-custom/README_submit_checklist.md
```

## 当前建议的发布说明

这次最终发布，建议明确分成两条主线：

- Windows 一键 quickstart
- Windows 完整认证模式

前者解决“别人拉仓库后先跑起来”，后者解决“认证边界和权限模型已经能落地验证”。
