#!/usr/bin/env bash
set -euo pipefail

TEMPLATE_PATH="${CONFIG_TEMPLATE_PATH:-/app/config.template.json}"
OUTPUT_PATH="${CONFIG_PATH:-/app/config.json}"

if [ ! -f "${TEMPLATE_PATH}" ]; then
  echo "[entrypoint-office] 템플릿 파일을 찾을 수 없습니다: ${TEMPLATE_PATH}" >&2
  exit 1
fi

required_vars=(
  OFFICE_DB_HOST
  OFFICE_DB_PORT
  OFFICE_DB_USER
  OFFICE_DB_PASSWORD
  OFFICE_DB_CHARSET
  OFFICE_DB_TIMEZONE
  OFFICE_DB_NAME_PARTNERS
  OFFICE_DB_NAME_BOOKING
  OFFICE_DB_NAME_USIN
  OFFICE_DB_NAME_SUBSCRIPTION
  OFFICE_DB_NAME_MALL
)

missing=false
for var in "${required_vars[@]}"; do
  if [ -z "${!var:-}" ]; then
    echo "[entrypoint-office] ${var} 환경변수가 설정되지 않았습니다." >&2
    missing=true
  fi
done

if [ "${missing}" = true ]; then
  exit 1
fi

envsubst < "${TEMPLATE_PATH}" > "${OUTPUT_PATH}"

echo "[entrypoint-office] ${OUTPUT_PATH} 파일 생성 완료."

exec "$@"
