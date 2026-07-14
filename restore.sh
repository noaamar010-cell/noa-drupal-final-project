#!/usr/bin/env bash
set -Eeuo pipefail

DB_CONTAINER="noa-postgres"
DRUPAL_CONTAINER="noa-drupal"
DB_NAME="drupal"
DB_USER="root"
DB_BACKUP="backups/drupal.sql"
SITES_BACKUP="backups/sites.tar.gz"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
running() { [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null || true)" = "true" ]; }

test -s "$DB_BACKUP" || fail "Missing $DB_BACKUP. Run ./backup.sh first."
test -s "$SITES_BACKUP" || fail "Missing $SITES_BACKUP. Run ./backup.sh first."
running "$DB_CONTAINER" || fail "$DB_CONTAINER is not running. Run ./setup.sh first."
running "$DRUPAL_CONTAINER" || fail "$DRUPAL_CONTAINER is not running. Run ./setup.sh first."

printf 'Recreating the Drupal database...\n'
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d postgres \
  -c "DROP DATABASE IF EXISTS $DB_NAME WITH (FORCE);" >/dev/null
docker exec "$DB_CONTAINER" psql -U "$DB_USER" -d postgres \
  -c "CREATE DATABASE $DB_NAME;" >/dev/null
docker exec -i "$DB_CONTAINER" psql -v ON_ERROR_STOP=1 -U "$DB_USER" -d "$DB_NAME" \
  <"$DB_BACKUP" >/dev/null

printf 'Restoring Drupal site files...\n'
docker exec "$DRUPAL_CONTAINER" rm -rf /var/www/html/sites
docker exec -i "$DRUPAL_CONTAINER" tar -xzf - -C /var/www/html <"$SITES_BACKUP"
docker restart "$DRUPAL_CONTAINER" >/dev/null

printf 'Restore completed. Open http://localhost:8080\n'
