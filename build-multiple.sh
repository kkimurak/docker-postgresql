#!/usr/bin/env bash

set -Ceu
IMAGE_NAME="kkimurak/sameersbn-postgresql"
BUILD_DATE=$(date +%Y%m%d)
for POSTGRES_MAJOR_VERSION in {13..17}
do
    git switch "${POSTGRES_MAJOR_VERSION}-build"
    IMAGE_TAG="${POSTGRES_MAJOR_VERSION}-${BUILD_DATE}"
    echo "${IMAGE_TAG}" | tee VERSION
    sed -i Dockerfile -e "s/PG_VERSION=.*/PG_VERSION=${POSTGRES_MAJOR_VERSION} \\\/g"
    { time make release 2>&1; } 2>&1 | tee "build_${IMAGE_TAG}T$(date +%H%M%S).log"
    PSQL_VERSION=$(docker run --rm "${IMAGE_NAME}:${IMAGE_TAG}" \
                        psql -h localhost --version | sed -e "s/.*Ubuntu //" -e "s/\.pgdg.*//"
                    )

    # e.g. :16.8-1
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:${PSQL_VERSION}"
    # e.g. 16.8
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:${PSQL_VERSION%-*}"
    # e.g. 16
    docker tag "${IMAGE_NAME}:${IMAGE_TAG}" "${IMAGE_NAME}:${POSTGRES_MAJOR_VERSION}"
    echo "==== build complete: ${POSTGRES_MAJOR_VERSION}"
    git add VERSION
    git commit -m "bump version to ${IMAGE_TAG}"
done
