#!/bin/bash

set -euo pipefail

cwd="${PWD}"

# Somehow emar will fail to find llvm-ar when using the /proc/self/cwd path. To
# prevent that, on linux, we find out the "real path" of the sandbox. We do not
# rely on realpath as it may not be installed on the machine. We could compile
# one ourselves, but it's not really nescessary.
if [[ "${OSTYPE}" == "linux-gnu" ]]; then
    cwd="$(readlink ${cwd})"
fi

export EMCC_TEMP_DIR="${cwd}/emtmp"
mkdir -p ${EMCC_TEMP_DIR}
trap "rm -rf ${EMCC_TEMP_DIR}" EXIT

EM_CONFIG="LLVM_ROOT='${cwd}/external/emscripten_clang';"
EM_CONFIG+="EMSCRIPTEN_NATIVE_OPTIMIZER='external/emscripten_clang/optimizer';"
EM_CONFIG+="BINARYEN_ROOT='external/emscripten_clang/binaryen';"
EM_CONFIG+="EMSCRIPTEN_ROOT='external/emscripten_toolchain';"
EM_CONFIG+="TEMP_DIR='${EMCC_TEMP_DIR}';"
EM_CONFIG+="SPIDERMONKEY_ENGINE='';"
EM_CONFIG+="V8_ENGINE='';"
EM_CONFIG+="NODE_JS='${cwd}/external/nodejs/bin/node';"
EM_CONFIG+="COMPILER_ENGINE=NODE_JS;"
EM_CONFIG+="JS_ENGINES=[NODE_JS];"
export EM_CONFIG

export EM_EXCLUSIVE_CACHE_ACCESS=1
export EMCC_SKIP_SANITY_CHECK=1
export EMCC_WASM_BACKEND=0
# Let Bazel paralellize
export EMCC_CORES=1
export EMMAKEN_NO_SDK=1
export EM_CACHE="$(dirname ${0})/emscripten_cache"
