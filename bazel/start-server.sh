#!/usr/bin/env bash

set -e

config_dir=$(dirname $(realpath $0))

pushd /mnt/data/others/bazel-buildfarm/

bazel run //src/main/java/build/buildfarm:buildfarm-server $config_dir/server-config

popd
