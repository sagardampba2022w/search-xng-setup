#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")"

if ! command -v docker >/dev/null 2>&1; then
  echo "Docker is required. Install Docker Desktop, then run this script again." >&2
  exit 1
fi

if ! docker compose version >/dev/null 2>&1; then
  echo "Docker Compose is required. Update Docker Desktop, then run this script again." >&2
  exit 1
fi

if ! docker info >/dev/null 2>&1; then
  echo "The Docker daemon is not running. Start Docker Desktop, then run this script again." >&2
  exit 1
fi

if [ ! -f .env ]; then
  cp .env.example .env

  if command -v openssl >/dev/null 2>&1; then
    secret="$(openssl rand -hex 32)"
  elif command -v python3 >/dev/null 2>&1; then
    secret="$(python3 -c 'import secrets; print(secrets.token_hex(32))')"
  else
    echo "Could not generate a secret. Install openssl or Python 3, then try again." >&2
    rm -f .env
    exit 1
  fi

  sed -i.bak "s/^SEARXNG_SECRET=.*/SEARXNG_SECRET=${secret}/" .env
  rm -f .env.bak
  echo "Created .env with a generated secret."
fi

echo "Starting SearXNG..."
docker compose up -d

echo
echo "SearXNG is available at http://localhost:${SEARXNG_PORT:-8080}"
echo "Try: curl 'http://localhost:${SEARXNG_PORT:-8080}/search?q=docker&format=json'"
