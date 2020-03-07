#!/usr/bin/env sh

set -e

# shellcheck disable=SC1090
. "$(dirname "$0")"/conf.env

while [ $# -gt 0 ]; do
    case $1 in
        --push)
            PUSH=true
            shift
            ;;
        --latest)
            LATEST=true
            shift
            ;;
        *)
            shift
            ;;
    esac
done

sed s/__PHP_VERSION__/"$PHP_VERSION"/g Dockerfile.template > Dockerfile
docker build -t "$DOCKER_IMAGE:$PHP_VERSION" .

if [ x$PUSH = "xtrue" ]; then
    docker push "$DOCKER_IMAGE":"$PHP_VERSION"
fi

if [ x$LATEST = "xtrue" ]; then
    docker tag "$DOCKER_IMAGE":"$PHP_VERSION" "$DOCKER_IMAGE":latest
    [ x$PUSH = "xtrue" ] && docker push "$DOCKER_IMAGE":latest
fi
