# minimal php-fpm docker image

![build](https://github.com/dcarrillo/docker-phpfpm/workflows/CI/badge.svg)

- [minimal php-fpm docker image](#minimal-php-fpm-docker-image)
  - [Image configuration](#image-configuration)
  - [Build](#build)
  - [Testing](#testing)
  - [Run](#run)
  - [Opcache environment variable names](#opcache-environment-variable-names)
  - [FPM environment variable names](#fpm-environment-variable-names)
  - [rash](#rash)

php-fpm docker image with templatized production parameters and opcache module enabled.

Opcache parameterized parameters:

```ini
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.huge_code_pages=1
opcache.validate_timestamps=0
```

FPM parameterized parameters

```ini
[www]

listen = 127.0.0.1:9000
listen.backlog = 8196

pm = dynamic
pm.max_children = 50
pm.start_servers = 5
pm.min_spare_servers = 5
pm.max_spare_servers = 10
pm.max_requests = 500
pm.status_path = /phpfpm_status

rlimit_files = 2048
```

## Image configuration

Edit [conf.env](conf.env)

```bash
PHP_VERSION=x.x.x-fpm-alpine  # Official PHP image version to build from
DOCKER_IMAGE=image_namespace/php    # Docker image
```

## Build

Build locally:

```bash
./build.sh
```

Build locally and upload to a registry (you must be logged in to the registry)

```bash
./build.sh --push
```

Build locally, tag image as latest and upload to a registry (you must be logged in to the registry)

```bash
./build.sh --push --latest
```

## Testing

```bash
# build local image
./build.sh

# run tests
./tests/test.sh
```

## Run

Default parameters:

```bash
docker run -ti -d dcarrillo/php_rash:x.x.x-fpm-alpine
```

Change FPM process manager to ondemand and disable opcache:

```bash
docker run -ti \
           -e FPM_PM=ondemand \
           -e FPM_PM_MAX_CHILDREN=15 \
           -e FPM_PM_MAX_REQUESTS=50 \
           -e FPM_PM_PROCESS_IDLE_TIMEOUT=5s \
           -e OPCACHE_ENABLED=0 \
           -d dcarrillo/php_rash:x.x.x-fpm-alpine
```

## Opcache environment variable names

- OPCACHE_ENABLED
- OPCACHE_MEMORY_CONSUMPTION
- OPCACHE_INTERNED_STRINGS_BUFFER
- OPCACHE_MAX_ACCELERATED_FILES
- OPCACHE_HUGE_CODE_PAGES
- OPCACHE_VALIDATE_TIMESTAMPS

## FPM environment variable names

- FPM_LISTEN
- FPM_LISTEN_BACKLOG
- FPM_PM
- FPM_PM_MAX_CHILDREN
- FPM_PM_START_SERVERS
- FPM_PM_MIN_SPARE_SERVERS
- FPM_PM_MAX_SPARE_SERVERS
- FPM_PM_MAX_REQUESTS
- FPM_PM_STATUS_PATH
- FPM_PM_PROCESS_IDLE_TIMEOUT
- FPM_RLIMIT_FILES

## rash

This image uses [rash](https://github.com/rash-sh/rash) to render configuration files
from a declarative entrypoint
