#!/usr/bin/env bash

set -e

if [ x"$DEBUG" = xtrue ]; then
    set -x
fi

# shellcheck disable=SC2039
trap _catch_err ERR
trap _cleanup EXIT

LOCAL_DIR="$(cd "$(dirname "$0")" ; pwd -P)"
# shellcheck disable=SC1090
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
    if echo "$1" | grep -Eq "$2"; then
        if [ x"$3" = xis_false ]; then
            printf "Test FAILED, pattern %s is in response\n" "$2"
            exit 1
        else
            echo "Test succeeded"
        fi
    else
        if [ x"$3" = xis_false ]; then
            echo "Test succeeded"
        else
            printf "Test FAILED, pattern %s is not in response\n" "$2"
            exit 1
        fi
    fi
}

echo "Preparing ${DOCKER_IMAGE}:${PHP_VERSION} to be tested"
_build_test_image
docker run --name "${PHP_VERSION}-test" --rm \
           -e FPM_PM=ondemand \
           -e FPM_PM_MAX_CHILDREN=15 \
           -e FPM_PM_MAX_REQUESTS=50 \
           -e FPM_PM_PROCESS_IDLE_TIMEOUT=5s \
           -e FPM_PM_STATUS_PATH=/phpfpm_test_status \
           -d "${DOCKER_IMAGE}:${PHP_VERSION}" > /dev/null
docker exec "${PHP_VERSION}-test" sh -c 'echo "<?php phpinfo(); ?>" > /tmp/info.php'

## Test 1 php-fpm is up and running
echo "+++ Requesting /phpfpm_test_status"
RESPONSE=$(docker run --name fcgi-tester --link "${PHP_VERSION}-test" --rm -i \
           -e REQUEST_METHOD=GET \
           -e SCRIPT_NAME=/phpfpm_test_status \
           -e SCRIPT_FILENAME=/phpfpm_test_status \
           "${DOCKER_IMAGE}-fcgi" \
           -bind -connect "${PHP_VERSION}-test":9000)
_check_response "$RESPONSE" "process manager:      ondemand"

## Test 2 opcache is enabled
RESPONSE=$(docker run --name fcgi-tester --link "${PHP_VERSION}-test" --rm -i \
           -e REQUEST_METHOD=GET \
           -e SCRIPT_NAME=/tmp/info.php \
           -e SCRIPT_FILENAME=/tmp/info.php \
           "${DOCKER_IMAGE}-fcgi" \
           -bind -connect "${PHP_VERSION}-test":9000)
echo "+++ Checking opcache is enabled"
_check_response "$RESPONSE" "opcache.enable</td>.+>On<.+"

## Test 3 validate_timestamps is disabled
echo "+++ Checking validate_timestamps is disabled"
_check_response "$RESPONSE" "opcache.validate_timestamps</td>.+>Off<.+"

## Test 4 X-Powered-By header is hidden
echo "+++ Checking X-Powered-By header is hidden"
_check_response "$RESPONSE" "X-Powered-By" is_false

echo "All tests succeeded !"
