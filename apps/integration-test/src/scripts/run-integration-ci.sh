#!/usr/bin/env bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../../../.." && pwd)"

PORT=3001
BACKEND_PID=""

function stop_services() {
  echo "🔴 - Stopping backend..."
  if [[ -n "$BACKEND_PID" ]]; then
    kill "$BACKEND_PID" 2>/dev/null || true
    wait "$BACKEND_PID" 2>/dev/null || true
  fi

  echo "🔴 - Taking down auxiliary services..."
  docker compose -f "$PROJECT_ROOT/docker/compose-files/docker-compose-integration-test.yml" down || true
}

trap stop_services EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

export DATABASE_URL="postgresql://postgres:password@localhost:5432/postgres"

echo "Starting auxilary services"
docker compose -f "$PROJECT_ROOT/docker/compose-files/docker-compose-integration-test.yml" up -d --wait

echo '🟡 - Waiting for database to be ready...'
"$PROJECT_ROOT/apps/integration-test/src/scripts/wait-for-it.sh" localhost:5432 --strict -- echo "database has started"

echo "Applying migration"
cd "$PROJECT_ROOT/packages/database"
pnpm exec prisma migrate deploy --schema "$PROJECT_ROOT/packages/database/prisma/schema.prisma"

echo "Generate Client"
pnpm exec prisma generate --schema "$PROJECT_ROOT/packages/database/prisma/schema.prisma"

echo '🟡 - Starting backend server...'
(
  cd "$PROJECT_ROOT/apps/backend"
  PORT=$PORT exec pnpm run dev:ci
) &
BACKEND_PID=$!

echo "backend pid $BACKEND_PID"

echo '🟡 - Waiting for backend to be ready...'
"$PROJECT_ROOT/apps/integration-test/src/scripts/wait-for-it.sh" localhost:3001 --strict -- echo "backend has started"

echo "Run integration test"
cd "$PROJECT_ROOT/apps/integration-test"
pnpm exec vitest --run
