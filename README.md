# minimal php-fpm docker image

php-fpm docker image with production parameters and opcache module enabled.

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
