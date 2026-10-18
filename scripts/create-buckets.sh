#!/usr/bin/env bash
# Creates required MinIO buckets after first startup
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
source "$ROOT/.env"

MINIO_URL="http://localhost:9000"

echo "[buckets] Waiting for MinIO..."
until curl -sf "$MINIO_URL/minio/health/live" > /dev/null; do
  sleep 2
done

# Install mc (MinIO client) if not present
if ! command -v mc &>/dev/null; then
  echo "[buckets] Installing MinIO client (mc)..."
  curl -sf https://dl.min.io/client/mc/release/darwin-amd64/mc -o /tmp/mc
  chmod +x /tmp/mc
  MC=/tmp/mc
else
  MC=mc
fi

echo "[buckets] Configuring alias..."
$MC alias set local "$MINIO_URL" "$MINIO_ROOT_USER" "$MINIO_ROOT_PASSWORD" --api S3v4

echo "[buckets] Creating buckets..."
for bucket in chatwoot documenso plane; do
  $MC mb --ignore-existing "local/$bucket"
  echo "  created: $bucket"
done

echo "[buckets] Done."
