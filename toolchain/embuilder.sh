#!/bin/bash

set -euo pipefail

source $(dirname $0)/emenv.sh

python external/emscripten_toolchain/embuilder.py "$@"

# Remove the first line of .d file (emscripten resisted all my attempts to make
# it realize it's just the absolute location of the source)
find . -name '*.d' -exec sed -i '' '2d' {} \;
