#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_PATH="${CONFIG_TEMPLATE_PATH:-/app/config.template.json}"
OUTPUT_PATH="${CONFIG_PATH:-/app/config.json}"

if [ ! -f "${TEMPLATE_PATH}" ]; then
  echo "[entrypoint] 템플릿 파일을 찾을 수 없습니다: ${TEMPLATE_PATH}" >&2
  exit 1
fi

required_vars=(
  DEV_DB_HOST
  DEV_DB_PORT
  DEV_DB_USER
  DEV_DB_PASSWORD
  DEV_DB_CHARSET
  DEV_DB_TIMEZONE
  DEV_DB_NAME_PARTNERS
  DEV_DB_NAME_BOOKING
  DEV_DB_NAME_USIN
  DEV_DB_NAME_SUBSCRIPTION
  DEV_DB_NAME_MALL
)

missing=false
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[entrypoint] ${var} 환경변수가 설정되지 않았습니다." >&2
    missing=true
  fi
done

if [ "${missing}" = true ]; then
  exit 1
fi

envsubst < "${TEMPLATE_PATH}" > "${OUTPUT_PATH}"

echo "[entrypoint] ${OUTPUT_PATH} 파일 생성 완료."

exec "$@"
