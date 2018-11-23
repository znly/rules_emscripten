#!/bin/bash

set -euo pipefail

# --- begin runfiles.bash initialization ---
if [[ ! -d "${RUNFILES_DIR:-/dev/null}" && ! -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
    if [[ -f "$0.runfiles_manifest" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles_manifest"
    elif [[ -f "$0.runfiles/MANIFEST" ]]; then
      export RUNFILES_MANIFEST_FILE="$0.runfiles/MANIFEST"
    elif [[ -f "$0.runfiles/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
      export RUNFILES_DIR="$0.runfiles"
    fi
fi
if [[ -f "${RUNFILES_DIR:-/dev/null}/bazel_tools/tools/bash/runfiles/runfiles.bash" ]]; then
  source "${RUNFILES_DIR}/bazel_tools/tools/bash/runfiles/runfiles.bash"
elif [[ -f "${RUNFILES_MANIFEST_FILE:-/dev/null}" ]]; then
  source "$(grep -m1 "^bazel_tools/tools/bash/runfiles/runfiles.bash " \
            "$RUNFILES_MANIFEST_FILE" | cut -d ' ' -f 2-)"
else
  echo >&2 "ERROR: cannot find @bazel_tools//tools/bash/runfiles:runfiles.bash"
  exit 1
fi
# --- end runfiles.bash initialization ---

source "$(rlocation rules_emscripten/toolchain/emenv.sh)"

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

# Start by removing the cache, before rebuilding
rm -rf "${EM_CACHE}/asmjs"
python external/emscripten_toolchain/embuilder.py "$@"
rm -rf "${EM_CACHE}/asmjs/ports-builds"

# Remove the first line of .d file (emscripten resisted all my attempts to make
# it realize it's just the absolute location of the source)
sed_i="$(rlocation rules_emscripten/toolchain/sed_i.sh)"
find . -name '*.d' -exec "${sed_i}" '2d' {} \;
