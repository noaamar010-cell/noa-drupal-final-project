#!/usr/bin/env bash
set -Eeuo pipefail

NETWORK="noa-drupal-net"
CONTAINERS=(noa-drupal noa-postgres)
VOLUMES=(noa-postgres-data noa-drupal-sites)

printf 'Removing project containers...\n'
for container in "${CONTAINERS[@]}"; do
  docker container inspect "$container" >/dev/null 2>&1 && docker rm -f -v "$container" >/dev/null || true
done

printf 'Removing project volumes...\n'
for volume in "${VOLUMES[@]}"; do
  docker volume inspect "$volume" >/dev/null 2>&1 && docker volume rm "$volume" >/dev/null || true
done

printf 'Removing the project network...\n'
docker network inspect "$NETWORK" >/dev/null 2>&1 && docker network rm "$NETWORK" >/dev/null || true

printf 'Cleanup completed. Shared Docker images were kept for faster future setup.\n'
