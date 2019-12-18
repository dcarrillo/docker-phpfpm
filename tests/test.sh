#!/usr/bin/env bash

set -e

if [ x"$DEBUG" = xtrue ]; then
    set -x
fi

trap _catch_err ERR
trap _cleanup EXIT

LOCAL_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
. "$LOCAL_DIR"/../conf.env

_catch_err()
{
    echo "Test FAILED"
}

_cleanup()
{
    echo "Cleaning up..."
    docker rm -f "${PHP_VERSION}-test" > /dev/null 2>&1
}

_build_test_image()
{
    echo "Building ${DOCKER_IMAGE}-fcgi image"
    docker build -t "${DOCKER_IMAGE}-fcgi" - > /dev/null <<'EOF'
    FROM debian:buster-slim
    RUN apt update && apt -y install libfcgi0ldbl && rm -rf /var/lib/apt/lists/*
    ENTRYPOINT ["cgi-fcgi"]
EOF
}

_check_response()
{
    if echo "$1" | grep -q "$2"; then
        echo "Test succeeded"
    else
        printf "Test FAILED, response:\n%s\n" "$1"
        exit 1
    fi
}

_build_test_image

docker run --name "${PHP_VERSION}-test" --rm \
           -v "$LOCAL_DIR"/www.conf:/usr/local/etc/php-fpm.d/www.conf:ro \
           -d "${DOCKER_IMAGE}":"${PHP_VERSION}" > /dev/null

echo "Requesting /phpfpm_status"
RESPONSE=$(docker run --name fcgi-tester --link "${PHP_VERSION}-test" --rm -i \
           -e REQUEST_METHOD=GET \
           -e SCRIPT_NAME=/phpfpm_status \
           -e SCRIPT_FILENAME=/phpfpm_status \
           "${DOCKER_IMAGE}-fcgi" \
           -bind -connect "${PHP_VERSION}-test":9000)

_check_response "$RESPONSE" "process manager:      dynamic"

echo "Testing opcache is enabled"
RESPONSE=$(docker exec -i "${PHP_VERSION}-test" php -i | grep opcache.enable)

_check_response "$RESPONSE" "opcache.enable => On => On"

echo "All tests succeeded !"
