#!/usr/bin/env bash
set -Eeuo pipefail

DB_CONTAINER="noa-postgres"
DRUPAL_CONTAINER="noa-drupal"
DB_NAME="drupal"
DB_USER="root"
BACKUP_DIR="backups"
DB_BACKUP="$BACKUP_DIR/drupal.sql"
SITES_BACKUP="$BACKUP_DIR/sites.tar.gz"

running() { [ "$(docker inspect -f '{{.State.Running}}' "$1" 2>/dev/null || true)" = "true" ]; }
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }

running "$DB_CONTAINER" || fail "$DB_CONTAINER is not running."
running "$DRUPAL_CONTAINER" || fail "$DRUPAL_CONTAINER is not running."
mkdir -p "$BACKUP_DIR"

printf 'Saving the PostgreSQL database...\n'
docker exec "$DB_CONTAINER" pg_dump --clean --if-exists -U "$DB_USER" "$DB_NAME" >"$DB_BACKUP"

printf 'Saving Drupal site files...\n'
docker exec "$DRUPAL_CONTAINER" tar -czf - -C /var/www/html sites >"$SITES_BACKUP"

test -s "$DB_BACKUP" || fail "The database backup is empty."
test -s "$SITES_BACKUP" || fail "The sites backup is empty."

printf 'Backup completed:\n'
ls -lh "$DB_BACKUP" "$SITES_BACKUP"
