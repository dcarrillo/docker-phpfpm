# minimal php-fpm docker image

php-fpm docker image with production parameters and opcache module enabled.

Opcache parameters:

```ini
zend_extension=opcache
opcache.enable=1
opcache.memory_consumption=128
opcache.interned_strings_buffer=8
opcache.max_accelerated_files=4000
opcache.huge_code_pages=1
opcache.validate_timestamps=0
# This implies reset OPcache manually via opcache_reset(), opcache_invalidate()
# or by restarting php-fpm for changes to the filesystem to take effect.
```

## Configuration

Edit [conf.env](conf.env)

```bash
PHP_VERSION=x.x.x-fpm-alpine  # Official PHP image version to build from
DOCKER_IMAGE=dcarrillo/php    # Docker image
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
