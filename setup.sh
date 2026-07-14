#!/usr/bin/env bash
set -Eeuo pipefail

NETWORK="noa-drupal-net"
DB_CONTAINER="noa-postgres"
DRUPAL_CONTAINER="noa-drupal"
DB_VOLUME="noa-postgres-data"
SITES_VOLUME="noa-drupal-sites"
DB_NAME="drupal"
DB_USER="root"
DB_PASSWORD="my-secret-pw"

fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
exists() { docker container inspect "$1" >/dev/null 2>&1; }

command -v docker >/dev/null 2>&1 || fail "Docker is not installed."
docker info >/dev/null 2>&1 || fail "Docker is not running."

if exists "$DB_CONTAINER" || exists "$DRUPAL_CONTAINER"; then
  fail "Project containers already exist. Run ./cleanup.sh before a fresh setup."
fi

printf 'Creating the project network...\n'
docker network inspect "$NETWORK" >/dev/null 2>&1 || docker network create "$NETWORK" >/dev/null

printf 'Starting PostgreSQL...\n'
docker run --detach \
  --name "$DB_CONTAINER" \
  --network "$NETWORK" \
  --publish 5432:5432 \
  --env POSTGRES_DB="$DB_NAME" \
  --env POSTGRES_USER="$DB_USER" \
  --env POSTGRES_PASSWORD="$DB_PASSWORD" \
  --volume "$DB_VOLUME:/var/lib/postgresql" \
  postgres:latest >/dev/null

printf 'Waiting for PostgreSQL to accept connections...\n'
for attempt in {1..30}; do
  if docker exec "$DB_CONTAINER" pg_isready -U "$DB_USER" -d "$DB_NAME" >/dev/null 2>&1; then
    break
  fi
  (( attempt == 30 )) && fail "PostgreSQL did not become ready in time."
  sleep 2
done

printf 'Starting Drupal...\n'
docker run --detach \
  --name "$DRUPAL_CONTAINER" \
  --network "$NETWORK" \
  --publish 8080:80 \
  --volume "$SITES_VOLUME:/var/www/html/sites" \
  drupal:latest >/dev/null

cat <<INFO

Setup completed.
Open: http://localhost:8080

Drupal database settings:
  Database type: PostgreSQL
  Database name: $DB_NAME
  Username:      $DB_USER
  Password:      $DB_PASSWORD
  Host:          $DB_CONTAINER
  Port:          5432
INFO
