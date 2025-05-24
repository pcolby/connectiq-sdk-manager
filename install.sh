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
message=$(jq --raw-output '.message//""' <<< "${releaseInfo}")
[[ -z "${message}" ]] || { echo "${message}"; exit 1; }
releaseName=$(jq --raw-output '.name' <<< "${releaseInfo}")
echo "Found details for release: ${releaseName}"

echo 'Checking for installed SDK versions'
installedSdkVersions='[]'
[[ ! -d "${CONNECT_IQ_DIR}/Sdks" ]] || installedSdkVersions=$(
  find "${CONNECT_IQ_DIR}/Sdks" -mindepth 1 -maxdepth 1 -type d -printf '%f\n' |
  sed -Ene 's|^connectiq-sdk-lin-(([0-9]+\.){2}[0-9]+)-.*$|"\1"|p' |
  jq --compact-output --slurp 'sort_by(split(".")[]|tonumber)'
)
echo "Found installed SDK versions: ${installedSdkVersions}"

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
done < <(jq --argjson 'installedSdkVersions' "${installedSdkVersions}" --compact-output "$(cat <<-'-'
	# Extend each  asset with broken down application name and version components.
	([.assets[]|.+{
	  "version": .name|capture("^(?<name>[^-]+)-(?<major>[0-9]+)\\.(?<minor>[0-9]+)\\.(?<patch>[0-9]+)")
	}]) as $assets|

	# Output the SDK Manager asset.
	($assets[]|select(.version.name == "Connect_IQ_SDK_Manager")),

	# Output the most-recent version for each application with major version matching an installed SDK version.
	([$installedSdkVersions[]|split(".")[0]]|unique[]) as $majorVersion|
	[$assets[]|select(.version.major == $majorVersion)]|
	group_by(.version|[.name,.major])[]|
	sort_by(.version|[.major,.minor,.patch][]|tonumber)|last
	-
)" <<< "${releaseInfo}" || :)
