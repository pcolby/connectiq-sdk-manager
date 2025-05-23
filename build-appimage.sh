#!/usr/bin/env bash
# SPDX-FileCopyrightText: 2025 Paul Colby <git@colby.id.au>
# SPDX-License-Identifier: MIT

set -o errexit -o noclobber -o nounset -o pipefail
shopt -s inherit_errexit

scriptPath=$(realpath -e "${BASH_SOURCE[0]}")
scriptDir=$(dirname "${scriptPath}")
readonly scriptPath scriptDir

: "${BASE_URL:=https://developer.garmin.com/downloads/connect-iq}"
: "${BUILD_DIR:=${PWD}/build}"
: "${LINUXDEPLOY:=linuxdeploy-x86_64.AppImage}"
: "${OUTPUT_DIR:=${PWD}}"
readonly BASE_URL BUILD_DIR LINUXDEPLOY OUTPUT_DIR

[[ "$#" -gt 0 ]] || {
  echo "Usage: ${BASH_SOURCE[0]} [--force] <all|manager|version>..." >&2
  exit 1
}

mkdir -p "${BUILD_DIR}" "${OUTPUT_DIR}"

echo 'Fetching available SDKs list...' >&2
sdksList=$(curl --silent "${BASE_URL}/sdks/sdks.json")
readonly sdksList

function buildAll {
  echo 'Building AppImages for SDK manager, and all available SDK versions...' >&2
  buildManager
  while IFS= read -d '' -r version; do
    buildSdk "${version}"
  done < <(jq --raw-output0 '.[].version' <<< "${sdksList}" || :)
}

function buildManager {
  [[ "${1-}" == 'iconOnly' ]] || echo 'Build AppImage for SDK manager...' >&2
  local mgrInfo mgrFileName mgrVersion
  mgrInfo=$(curl --silent "${BASE_URL}/sdk-manager/sdk-manager.json")
  IFS=$'\x1f' read -r -d '' mgrVersion mgrFileName < \
    <(jq -r '[.version,.linux]|join("\u001F")+"\u0000"' <<< "${mgrInfo}" || :)
  local -r mgrDirName="${mgrFileName%.zip}-${mgrVersion}"
  local -r appName='Connect IQ SDK Manager'
  local -r appVersion="${mgrVersion// /-}${BUILD_ID:++${BUILD_ID}}"
  local -r binName='sdkmanager'
  local -r appImagePathName="${OUTPUT_DIR}/${appName// /_}-${appVersion}-x86_64.AppImage"
  if [[ -e "${appImagePathName}" && -n "${force}" && "${1-}" != 'iconOnly' ]]; then
    echo "  - skipping existing AppImage: ${appImagePathName}" >&2
    return
  fi

  # Download the SDK manager
  [[ -s "${BUILD_DIR}/${mgrFileName}" && -n "${force}" ]] || {
    echo "  - fetching: ${mgrFileName}" >&2
    curl --create-dirs --fail --location --output-dir "${BUILD_DIR}" --progress-bar --remote-name \
      "${BASE_URL}/sdk-manager/${mgrFileName}"
  }

  # Extract the SDK manager.
  [[ -s "${BUILD_DIR}/${mgrDirName}" && -n "${force}" ]] || {
    echo "  - extracting to: ${BUILD_DIR}/${mgrDirName}" >&2
    unzip ${force:+-o} -q "${BUILD_DIR}/${mgrFileName}" -d "${BUILD_DIR}/${mgrDirName}"
  }

  # Extract and convert the Conect IQ icon.
  [[ -s "${BUILD_DIR}/connectiq-icon.png" && -n "${force}" ]] || {
    echo "  - extracting icon to: ${BUILD_DIR}/connectiq-icon.png" >&2
    convert "${BUILD_DIR}/${mgrDirName}/share/sdkmanager/connectiq-icon.png" -gravity Center -crop '192x192+0+0' \
      "${BUILD_DIR}/connectiq-icon.png"
  }
  if [[ "${1-}" == 'iconOnly' ]]; then return; fi

  # Build the AppDir
  local -r appDirPath="${BUILD_DIR}/${mgrDirName}-${binName}"
  echo "  - constructing AppDir: ${appDirPath}" >&2
  mkdir -p "${appDirPath}/usr/"{bin,share}
  cp --archive "${BUILD_DIR}/${mgrDirName}/bin/${binName}" "${appDirPath}/usr/bin"
  cp --archive "${BUILD_DIR}/${mgrDirName}/share/${binName}" "${appDirPath}/usr/share/AppRun"

  echo "  - generating desktop file: ${appDirPath}.desktop" >&2
  # See https://specifications.freedesktop.org/desktop-entry-spec/latest/recognized-keys.html
  AppDirName="${appName}" \
  AppDirIcon='connectiq-icon' \
  AppDirExec="${binName}" \
  envsubst < "${scriptDir}/desktop.in" >| "${appDirPath}.desktop"

  # Build the AppImage
  echo "  - building AppImage: ${appImagePathName}" >&2
  LINUXDEPLOY_OUTPUT_VERSION="${appVersion}" \
  "${LINUXDEPLOY}" --appdir "${appDirPath}" --desktop-file "${appDirPath}.desktop" \
    --executable "${appDirPath}/usr/bin/${binName}" --icon-file "${BUILD_DIR}/connectiq-icon.png" --plugin gtk \
    --plugin webkitmod --output appimage
}

function buildSdk {
  local -r sdkVersion="$1"
  local app sdkTitle sdkFileName
  echo "Building AppImage for SDK version: ${sdkVersion}" >&2
  sdkInfo=$(jq --arg version "${sdkVersion}" '.[]|select(.version == $version)' <<< "${sdksList}")
  [[ -n "${sdkInfo}" ]] || {
    echo "Failed to find details for SDK version: ${sdkVersion}" >&2
    exit 2
  }
  IFS=$'\x1f' read -r -d '' sdkTitle sdkFileName < \
    <(jq -r '[.title,.linux]|join("\u001F")+"\u0000"' <<< "${sdkInfo}" || :)
  local -r sdkDirName="${sdkFileName%.zip}"
  local -r sdkVersionName="${sdkTitle#Connect IQ }"
  local -r appVersion="${sdkVersionName// /-}${BUILD_ID:++${BUILD_ID}}"

  [[ -s "${BUILD_DIR}/connectiq-icon.png" && -n "${force}" ]] || {
    echo '  - fetching SDK manager for Connect IQ icon' >&2
    buildManager iconOnly
  }

  for app in 'Monkey Motion' 'Simulator'; do
    local appName="Connect IQ/Connect IQ ${app}"
    local binName="${app// /}"; binName="${binName,,}"
    local appImagePathName="${OUTPUT_DIR}/${appName// /_}-${appVersion}-x86_64.AppImage"
    if [[ -e "${appImagePathName}" && -n "${force}" ]]; then
      echo "  - skipping existing AppImage: ${appImagePathName}" >&2
      continue
    fi

    # Download the SDK (note, the 'Simulator' check is to prevent 'forcing' the download twice).
    [[ ( -s "${BUILD_DIR}/${sdkFileName}" && -n "${force}" ) || "${app}" == 'Simulator' ]] || {
      echo "  - fetching: ${sdkFileName}" >&2
      curl --create-dirs --fail --location --output-dir "${BUILD_DIR}" --progress-bar --remote-name \
        "${BASE_URL}/sdks/${sdkFileName}"
    }

    # Extract the SDK.
    [[ ( -s "${BUILD_DIR}/${sdkDirName}" && -n "${force}" ) || "${app}" == 'Simulator' ]] || {
      echo "  - extracting to: ${BUILD_DIR}/${sdkDirName}" >&2
      unzip ${force:+-o} -q "${BUILD_DIR}/${sdkFileName}" -d "${BUILD_DIR}/${sdkDirName}"
    }

    # Build the AppDir
    local appDirPath="${BUILD_DIR}/${sdkDirName}-${binName}"
    echo "  - constructing AppDir: ${appDirPath}" >&2
    mkdir -p "${appDirPath}/usr/"{bin,share}
    cp --archive "${BUILD_DIR}/${sdkDirName}/bin/${binName}" "${appDirPath}/usr/bin"
    [[ "${sdkVersion%%.*}" -lt 5 ]] || # version.txt added in SDK v5.
    cp --archive "${BUILD_DIR}/${sdkDirName}/bin/version.txt" "${appDirPath}/usr/bin"
    cp --archive "${BUILD_DIR}/${sdkDirName}/share/${binName}" "${appDirPath}/usr/share/AppRun"

    echo "  - generating desktop file: ${appDirPath}.desktop" >&2
    # See https://specifications.freedesktop.org/desktop-entry-spec/latest/recognized-keys.html
    AppDirName="Connect IQ ${app}" \
    AppDirIcon='connectiq-icon' \
    AppDirExec="${binName}" \
    envsubst < "${scriptDir}/desktop.in" >| "${appDirPath}.desktop"

    # Build the AppImage
    echo "  - building AppImage: ${appImagePathName}" >&2
    LINUXDEPLOY_OUTPUT_VERSION="${appVersion}" \
    "${LINUXDEPLOY}" --appdir "${appDirPath}" --desktop-file "${appDirPath}.desktop" \
      --executable "${appDirPath}/usr/bin/${binName}" --icon-file "${BUILD_DIR}/connectiq-icon.png" --plugin gtk \
      --plugin webkitmod --output appimage
  done
}

if [[ "${1:-}" == '--force' ]]; then force=yes; shift; else force=; fi

while [[ $# -gt 0 ]]; do
  case "$1" in
    'all')     buildAll;;
    'manager') buildManager;;
    *)         buildSdk "$1";;
  esac
  shift
done
