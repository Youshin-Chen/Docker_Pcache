#!/bin/sh
set -eu

wait_for_pms() {
  pms_url="${PCP_PMS_URL:-http://pms:8080/}"
  pms_target="${pms_url#*://}"
  pms_target="${pms_target%%/*}"
  pms_host="${pms_target%%:*}"
  pms_port="${pms_target##*:}"

  if [ "${pms_host}" = "${pms_target}" ]; then
    case "${pms_url}" in
      https://*)
        pms_port=443
        ;;
      *)
        pms_port=80
        ;;
    esac
  fi

  if command -v bash >/dev/null 2>&1; then
    echo "Waiting for PMS at ${pms_host}:${pms_port}..."
    until bash -lc "exec 3<>/dev/tcp/${pms_host}/${pms_port}" 2>/dev/null; do
      sleep 2
    done
  fi
}

wait_for_pms

exec java ${PCP_JAVA_OPTS:--Xms1g -Xmx4g} \
  -Dserver.address=0.0.0.0 \
  -Dserver.port="${PCP_PORT:-8091}" \
  -Dpcp.ak="${PCP_AK:-ak-pcp-admin}" \
  -Dpcp.sk="${PCP_SK:-yWlt32Rw6uImzTcAKJ5AZO5Bqw9rPS1YSZKZfgyv3ao=}" \
  -Dpcp.log.dir="${PCP_LOG_DIR:-/opt/pcache/logs/}" \
  -Dpcp.data.dir="${PCP_DATA_DIR:-/opt/pcache/data/}" \
  -Dpcp.pms.url="${PCP_PMS_URL:-http://pms:8080/}" \
  -Dpcp.public.url="${PCP_PUBLIC_URL:-}" \
  -Dpcp.network.interface.name="${PCP_NETWORK_INTERFACE_NAME:-}" \
  -Dpms.http.header="${PCP_HTTP_HEADER:-http://}" \
  -Dpcp.available.size="${PCP_AVAILABLE_SIZE:-10737418240}" \
  -Dpcp.block.cache.size="${PCP_BLOCK_CACHE_SIZE:-2147483648}" \
  -classpath /opt/pcache/pc-pcp.jar com.cloud.pc.PcpMain
