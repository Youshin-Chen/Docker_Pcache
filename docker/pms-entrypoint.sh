#!/bin/sh
set -eu

PMS_META_DIR="${PMS_META_DIR:-/opt/pcache/meta/}"

if [ -n "${PMS_SEED_META_DIR:-}" ] && [ -d "${PMS_SEED_META_DIR}" ]; then
  mkdir -p "${PMS_META_DIR}"
  if [ -z "$(ls -A "${PMS_META_DIR}" 2>/dev/null)" ]; then
    cp -R "${PMS_SEED_META_DIR}/." "${PMS_META_DIR}"
  fi
fi

exec java ${PMS_JAVA_OPTS:--Xms128m -Xmx256m} \
  -Dserver.address=0.0.0.0 \
  -Dserver.port="${PMS_PORT:-8080}" \
  -Dpms.enable.token="${PMS_ENABLE_TOKEN:-false}" \
  -Dpms.enable.write="${PMS_ENABLE_WRITE:-false}" \
  -Dpms.ak="${PMS_AK:-pms-admin}" \
  -Dpms.sk="${PMS_SK:-QPAAmgJVWUTzrRC9lGDMRJo6mCd4XWK6+tolzsWmgO4=}" \
  -Dpms.meta.loader="${PMS_META_LOADER:-file-loader}" \
  -Dpms.data.loader.file.path="${PMS_META_DIR}" \
  -Dpms.log.dir="${PMS_LOG_DIR:-/opt/pcache/logs/}" \
  -Dpms.existing.url="${PMS_EXISTING_URL:-}" \
  -Dpms.public.url="${PMS_PUBLIC_URL:-}" \
  -Dpms.http.header="${PMS_HTTP_HEADER:-http://}" \
  -Dpms.network.interface.name="${PMS_NETWORK_INTERFACE_NAME:-}" \
  -jar /opt/pcache/pc-pms.jar
