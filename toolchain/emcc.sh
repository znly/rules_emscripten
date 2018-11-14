#!/bin/bash

set -euo pipefail

source $(dirname $0)/emenv.sh

argv=("$@")
outbase=
zipfile=

# Find the -o option, and strip the .zip from it.
for (( i=0; i<$#; i++ )); do
    if [[ "x${argv[i]}" == x-o ]]; then
        arg=${argv[$((i+1))]}
        if [[ "x$arg" == x*.zip ]]; then
            zipfile=${arg}
            outbase=${zipfile%.*}
            argv[$((i+1))]=${outbase}.js
        fi
        break
    fi
done

python external/emscripten_toolchain/emcc "${argv[@]}"

# Remove the first line of .d file (emscripten resisted all my attempts to make
# it realize it's just the absolute location of the source)
find . -name '*.d' -exec sed -i '' "/  \//d" {} \;

if [ "x$zipfile" != x ]; then
    outputs=()
    for ext in html js wasm mem data worker.js; do
        f=${outbase}.${ext}
        if [ -f "${f}" ]; then
            outputs+=("${f}")
        fi
    done
    external/bazel_tools/tools/zip/zipper/zipper cf ${zipfile} "${outputs[@]}"
fi
