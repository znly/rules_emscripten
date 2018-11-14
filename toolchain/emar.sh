#!/bin/bash

set -euo pipefail

source $(dirname $0)/emenv.sh

argv=("${@}")
outfile=${argv[1]}
outarchive=

if [[ ${outfile} == *.lo ]]; then
    outarchive=${outfile%.*}.a
    argv[1]=${outarchive}
fi

python external/emscripten_toolchain/emar.py "${argv[@]}"

if [[ ! -z "${outarchive}" ]]; then
    mv "${outarchive}" "${outfile}"
fi
