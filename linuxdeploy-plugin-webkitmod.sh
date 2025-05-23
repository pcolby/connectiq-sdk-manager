#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2025 Paul Colby <git@colby.id.au>
# SPDX-License-Identifier: MIT
#
# A custom linuxdeploy plugin to modify the `libwebkit2gtk-4.0.so.37` libarary to point to
# `/usr/lib/x86_64-linux-gnu/webkit2gtk-4.1` instead of `/usr/lib/x86_64-linux-gnu/webkit2gtk-4.0`.
#
# See `README.md` and https://github.com/linuxdeploy/linuxdeploy/wiki/Plugin-system for more information.

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

readonly FILE_TO_PATCH='usr/lib/libwebkit2gtk-4.0.so.37'

unset appDir
while [[ "$#" -gt 0 ]]; do
  case "$1" in
    --appdir)             appDir="${2:?--appdir requires an argument}"; shift;;
    --plugin-api-version) echo 0; exit;;
    --plugin-patterns)    printf '-//- plugin patterns -//-\n%s\n' "${FILE_TO_PATCH}";;
    --plugin-type)        echo 'input'; shift;;
    *)                    echo "Invalid option: ${1}"; exit 1;;
  esac
  shift
done

echo "Patching: ${appDir:?Missing required option: --appdir}/${FILE_TO_PATCH}"
sed "-Ei${LINUXDEPLOY_WEBKITMOD_VERBOSE:+.bak}" -e 's|(/usr/lib/x86_64-linux-gnu/webkit2gtk-4\.)0|\11|g' "${appDir}/${FILE_TO_PATCH}"
[[ ! -v LINUXDEPLOY_WEBKITMOD_VERBOSE ]] || {
  diff -u <(hexdump -C "${appDir}/${FILE_TO_PATCH}.bak" || :) <(hexdump -C "${appDir}/${FILE_TO_PATCH}" || :) && [[ "$?" -eq 1 ]]
}
