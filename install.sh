#!/usr/bin/env -S bash -r
# SPDX-FileCopyrightText: 2025 Paul Colby <git@colby.id.au>
# SPDX-License-Identifier: MIT
#
# Usage: curl -Ls https://raw.githubusercontent.com/pcolby/connectiq-sdk-manager/main/build-appimage.sh | bash -r
#

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

: "${CONNECT_IQ_DIR:=${HOME}/.Garmin/ConnectIQ}"
readonly outputDir="${CONNECT_IQ_DIR}/AppImages"

echo "Installing to: ${outputDir}"
mkdir -p "${outputDir}"

echo 'Fetching details for release: latest'
releaseInfo=$(curl --location --no-progress-meter 'https://api.github.com/repos/pcolby/connectiq-sdk-manager/releases/latest')
releaseName=$(jq --raw-output '.name' <<< "${releaseInfo}")
echo "Found details for release: ${releaseName}"

while IFS= read -r assetInfo; do
  IFS=$'\x1f' read -d '' -r assetName downloadUrl < \
    <(jq -r '[.name,.browser_download_url]|join("\u001F")+"\u0000"' <<< "${assetInfo}" || :)
  outputPath="${outputDir}/${assetName}"
  if [[ -s "${outputPath}" ]]; then
    echo "Skipping ${assetName} - already exists: ${outputPath}"
    continue
  fi
  printf 'Downloading %s\n  src: %s\n  dst: %s\n' "${assetName}" "${downloadUrl}"  "${outputPath}"
  curl --location --output "${outputPath}" --progress-bar "${downloadUrl}"
  chmod u+x "${outputPath}"
done < <(jq --compact-output '.assets[]|select(.name|test("\\.AppImage$"))' <<< "${releaseInfo}" || :)
