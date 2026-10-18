#!/usr/bin/env bash
# Run DB migrations for services that need it
set -euo pipefail

echo "[migrate] Running Chatwoot DB setup..."
docker compose exec chatwoot bundle exec rails db:chatwoot_prepare

echo ""
echo "[migrate] Done. All other services (Documenso, Metabase, n8n) auto-migrate on startup."
