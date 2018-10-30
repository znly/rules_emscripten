#!/bin/bash

set -euo pipefail

source $(dirname $0)/emenv.sh

argv=("$@")
outdir=
outbase=
tarfile=

# Find the -o option, and strip the .tar from it.
for (( i=0; i<$#; i++ )); do
    if [[ "x${argv[i]}" == x-o ]]; then
        arg=${argv[$((i+1))]}
        if [[ "x$arg" == x*.tar ]]; then
            tarfile=${arg}
            outdir="$(dirname ${tarfile})"
            outbase=$(basename ${tarfile/.tar/})
            argv[$((i+1))]=${tarfile/.tar/.js}
        fi
        break
    fi
done

python external/emscripten_toolchain/emcc "${argv[@]}"

# Remove the first line of .d file (emscripten resisted all my attempts to make
# it realize it's just the absolute location of the source)
find . -name '*.d' -exec sed -i '' "/  \//d" {} \;

if [ "x$tarfile" != x ]; then
    outputs=()
    for ext in html js wasm mem data worker.js; do
        f=${outbase}.${ext}
        if [ -f "${outdir}/${f}" ]; then
            outputs+=("${f}")
        fi
    done
    tar cf ${tarfile} -C ${outdir} "${outputs[@]}"
fi
