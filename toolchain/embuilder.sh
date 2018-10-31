#!/bin/bash

set -euo pipefail

source toolchain/emenv.sh

cflags=(
    "-isystem"
    "external/emscripten_toolchain/system/include/libcxx"
    "-isystem"
    "external/emscripten_toolchain/system/lib/libcxxabi/include"
    "-isystem"
    "external/emscripten_toolchain/system/include/compat"
    "-isystem"
    "external/emscripten_toolchain/system/include"
    "-isystem"
    "external/emscripten_toolchain/system/include/SSE"
    "-isystem"
    "external/emscripten_toolchain/system/include/libc"
    "-isystem"
    "external/emscripten_toolchain/system/lib/libc/musl/arch/emscripten"
    "-isystem"
    "external/emscripten_toolchain/system/local/include"
)

export EM_CACHE="${BUILD_WORKSPACE_DIRECTORY}/toolchain/emscripten_cache"
export EMCC_CFLAGS="${cflags[@]}"
python external/emscripten_toolchain/embuilder.py "$@"

# # Remove the first line of .d file (emscripten resisted all my attempts to make
# # it realize it's just the absolute location of the source)
find . -name '*.d' -exec sed -i '' '2d' {} \;
