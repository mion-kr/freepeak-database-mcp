#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_PATH="${CONFIG_TEMPLATE_PATH:-/app/config.template.json}"
OUTPUT_PATH="${CONFIG_PATH:-/app/config.json}"

if [ ! -f "${TEMPLATE_PATH}" ]; then
  echo "[entrypoint-live] 템플릿 파일을 찾을 수 없습니다: ${TEMPLATE_PATH}" >&2
  exit 1
fi

required_vars=(
  LIVE_DB_HOST
  LIVE_DB_PORT
  LIVE_DB_USER
  LIVE_DB_PASSWORD
  LIVE_DB_CHARSET
  LIVE_DB_TIMEZONE
  LIVE_DB_NAME_PARTNERS
  LIVE_DB_NAME_BOOKING
  LIVE_DB_NAME_USIN
  LIVE_DB_NAME_SUBSCRIPTION
  LIVE_DB_NAME_MALL
)

missing=false
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[entrypoint-live] ${var} 환경변수가 설정되지 않았습니다." >&2
    missing=true
  fi
done

if [ "${missing}" = true ]; then
  exit 1
fi

envsubst < "${TEMPLATE_PATH}" > "${OUTPUT_PATH}"

echo "[entrypoint-live] ${OUTPUT_PATH} 파일 생성 완료."

exec "$@"
