# 文件清单

本文档用于整理这套 Windows 一键部署和认证模式补充改动。

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
- `docs-custom/README_checklist.md`
