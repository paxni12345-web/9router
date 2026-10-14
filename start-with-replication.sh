#!/bin/sh
# Starts 9router. If LITESTREAM_* is configured, restores the SQLite DB from S3 first and keeps replicating it.
DB="${DATA_DIR:-/app/data}/db/data.sqlite"
if [ -n "$LITESTREAM_BUCKET" ] && [ -n "$LITESTREAM_ENDPOINT" ]; then
  export LITESTREAM_DB_PATH="$DB"
  export LITESTREAM_PATH="${LITESTREAM_PATH:-9router/data.sqlite}"
  export LITESTREAM_REGION="${LITESTREAM_REGION:-us-east-1}"
  mkdir -p "$(dirname "$DB")"
  litestream restore -config /etc/litestream.yml -if-db-not-exists -if-replica-exists "$DB" \
    || echo "[litestream] restore failed, starting with an empty database"
  exec litestream replicate -config /etc/litestream.yml -exec "node custom-server.js"
fi
echo "[litestream] not configured, data is NOT persisted"
exec node custom-server.js
