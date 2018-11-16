#!/bin/bash
sed_i="sed -i"
if [[ "${OSTYPE}" == "darwin"* ]]; then
    sed_i+=" ''"
fi
${sed_i} "${@}"
