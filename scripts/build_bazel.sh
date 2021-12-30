#!/bin/bash
# Script to build Bazel on Raspbian Buster

# Use the latest supported version if no argument has been specified
if [ -z "$1" ]; then
    VERSION=$(cat BAZEL_VERSION)
    echo "No version specified, using ${VERSION}"
else
    VERSION=$1
fi

BAZEL_DIR=bazel
DIST_FILE=bazel-${VERSION}-dist.zip
DOWNLOAD_URL=https://github.com/bazelbuild/bazel/releases/download
DIST_URL="${DOWNLOAD_URL}"/"${VERSION}"/"${DIST_FILE}"
PATCH=patches/bazel-"${VERSION}"-arm.patch

# Download and unpack Bazel distribution file
if [ ! -f "${DIST_FILE}" ]; then
    curl --retry 3 -sLo "${DIST_FILE}" "${DIST_URL}"
fi
if [ -d "${BAZEL_DIR}" ]; then
    rm -rf "${BAZEL_DIR}"
fi
unzip -qqd "${BAZEL_DIR}" "${DIST_FILE}"

# Patch Bazel distribution if there's a patch for this version
# if [ -f "${PATCH}" ]; then
#     # Patch created with (for example):
#     # $ diff -ruN bazel bazel-2 > patches/bazel-3.3.1-arm.patch
#     patch -s -p0 < "${PATCH}"
# fi

# Build Bazel
cd "${BAZEL_DIR}" || exit

patch -s -p1 < ../patches/blaze_util_linux.patch

env EXTRA_BAZEL_ARGS="--host_javabase=@local_jdk//:jdk" bash ./compile.sh
