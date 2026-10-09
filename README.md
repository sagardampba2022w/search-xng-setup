# Local SearXNG

A small Docker Compose setup for running [SearXNG](https://searxng.github.io/searxng/) locally.

## Requirements

- Docker Desktop with Docker Compose

## Start

```bash
./setup.sh
```

Open [http://localhost:8080](http://localhost:8080) in a browser, or query the JSON endpoint:

```bash
curl 'http://localhost:8080/search?q=docker&format=json'
```

The service is bound to `127.0.0.1` by default and is not exposed to your network. To change the port or bind address, edit the generated `.env` file and restart:

```bash
docker compose up -d
```

## Common commands

```bash
# Follow SearXNG logs
docker compose logs -f core

# Stop containers but keep data
docker compose down

# Update images and restart
docker compose pull
docker compose up -d
```

SearXNG settings live in [`core-config/settings.yml`](core-config/settings.yml). The default configuration uses SearXNG's built-in broad set of search sources. The Valkey service is included for SearXNG features that need persistent state, such as rate limiting.

## Update the configuration

Edit [`core-config/settings.yml`](core-config/settings.yml), then restart the SearXNG container:

```bash
$EDITOR core-config/settings.yml
docker compose restart core
```

The current file starts with `use_default_settings: true`, so your file keeps SearXNG's built-in defaults. Add only the settings you want to override. For example:

```yaml
general:
  instance_name: "My Local Search"

server:
  image_proxy: true

engines:
  - name: "engine-name"
    disabled: false
```

To keep only a selected set of engines, replace `use_default_settings: true` with the documented `keep_only` configuration and list the engine names there. Engine-specific options, credentials, and supported values are documented by SearXNG. Never commit API keys or other secrets to this repository.

After changing configuration, check for startup errors with:

```bash
docker compose logs --tail=50 core
```

To update the container images themselves:

```bash
docker compose pull
docker compose up -d
```

## Security note

This setup is intended for local use. Do not change `SEARXNG_HOST` to `0.0.0.0` or place the instance on the public internet without adding authentication, HTTPS, and appropriate rate limiting.
