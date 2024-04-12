#!/usr/bin/env bash
#  Copyright (c) 2024 Greg Rynkowski. All rights reserved.
#  License: MIT License

# Path Initialization
if [ -n "${SHELL_GR_DIR:-}" ]; then
  _SHELL_GR_DIR="${SHELL_GR_DIR}"
elif [ -z "${_SHELL_GR_DIR:-}" ]; then
  _SCRIPT_PATH_1="${BASH_SOURCE[0]:-$0}"
  _SCRIPT_PATH="$([[ ! "${_SCRIPT_PATH_1}" =~ /bash$ ]] && readlink -f "${_SCRIPT_PATH_1}" || exit 1)"
  _SCRIPT_DIR="$(cd "$(dirname "${_SCRIPT_PATH}")" && pwd -P || exit 1)"
  _ROOT_DIR="$(cd "${_SCRIPT_DIR}/../.." && pwd -P || exit 1)"
  _SHELL_GR_DIR="${_ROOT_DIR}"
fi
# Library Sourcing
source "${_SHELL_GR_DIR}/lib/checksum.bash"              # verify_with_checksum_string_in_file
source "${_SHELL_GR_DIR}/lib/error.bash"                 # assert_not_empty, fail
source "${_SHELL_GR_DIR}/lib/install/common/github.bash" # GRIC_GH_latest_stable, GRIC_GH_list_all_versions
source "${_SHELL_GR_DIR}/lib/log.bash"                   # log_debug, log_info
source "${_SHELL_GR_DIR}/lib/os.bash"                    # linux_id
source "${_SHELL_GR_DIR}/lib/temp.bash"                  # temp_dir
source "${_SHELL_GR_DIR}/lib/trap.bash"                  # add_on_exit

# shellcheck disable=SC2034
GH_REPO="https://github.com/clj-kondo/clj-kondo"
TOOL_NAME="clj-kondo"
TOOL_TEST="clj-kondo --help"

compose_download_url() {
  local version="$1"
  local platform_uname platform
  platform_uname="$(uname -s)"
  case "${platform_uname}" in
    Linux*)
      if [ "$(linux_id)" == "alpine" ]; then
        platform="linux-static"
      else
        platform="linux"
      fi
      ;;
    Darwin*) platform="macos" ;;
    *) fail "Platform \"${platform_uname}\" is not yet supported." ;;
  esac

  local uname_arch arch
  uname_arch="$(uname -m)"
  case "${uname_arch}" in
    x86_64) arch="amd64" ;;
    *) fail "Architecture \"${uname_arch}\" is not yet supported." ;;
  esac
  # possible values:
  # https://stackoverflow.com/questions/45125516/possible-values-for-uname-m

  # releases: https://github.com/clj-kondo/clj-kondo/releases
  # sample URL: https://github.com/clj-kondo/clj-kondo/releases/download/v2023.12.15/clj-kondo-2023.12.15-linux-amd64.zip
  local download_url="${GH_REPO}/releases/download/v${version}/${TOOL_NAME}-${version}-${platform}-${arch}.zip"
  printf "%s" "${download_url}"
}

GRI_CLJ_KONDO__download() {
  # inputs
  local -r type="${GRI_CLJ_KONDO__INSTALL_TYPE:-}"
  local -r version="${GRI_CLJ_KONDO__INSTALL_VERSION:-}"
  local -r dest="${GRI_CLJ_KONDO__DOWNLOAD_PATH:-}"
  local -r github_api_token="${GITHUB_API_TOKEN:-}" # optional

  # inputs validation
  [ "${type}" != "version" ] && fail "asdf-${TOOL_NAME} supports release installs only"
  [ -z "${version}" ] && fail "version can't be empty"
  [ -z "${dest}" ] && fail "destination can't be empty"

  # prepare temp directory
  local temp_dir
  temp_dir=$(mktemp -d -t "asdf-${TOOL_NAME}.XXXX")
  add_on_exit rm -rf "${temp_dir}"
  log_debug "Temporary directory created at ${temp_dir}"
  log_debug

  # prepare curl opts
  local curl_opts=(-fsSL)
  if [ -n "${github_api_token:-}" ]; then
    curl_opts=("${curl_opts[@]}" "-H" "Authorization: token ${github_api_token}")
  fi

  # download zip & sha
  log_info "Downloading ${TOOL_NAME} release ${version}..."
  local zip_url sha_url
  zip_url="$(compose_download_url "${version}")"
  sha_url="${zip_url}.sha256"
  log_info " - ${zip_url}"
  log_info " - ${sha_url}"
  local temp_zip_path="${temp_dir}/${TOOL_NAME}.zip"
  local temp_sha_path="${temp_dir}/${TOOL_NAME}.zip.sha256"
  curl "${curl_opts[@]}" -o "${temp_zip_path}" -C - "${zip_url}" || fail "Could not download ${zip_url}"
  curl "${curl_opts[@]}" -o "${temp_sha_path}" -C - "${sha_url}" || fail "Could not download ${sha_url}"
  log_info

  # verify checksum
  GR_CHECKSUM__ALGO="sha256" \
    GR_CHECKSUM__FILE_PATH="${temp_zip_path}" \
    GR_CHECKSUM__CHECKSUM_PATH="${temp_sha_path}" \
    verify_with_checksum_string_in_file
  log_info

  # move the downloaded file to final destination
  mkdir -p "${dest}"
  local unzip_opts=(-o "${temp_zip_path}" -d "${dest}")
  ! is_debug && unzip_opts=(-q "${unzip_opts[@]}")
  unzip "${unzip_opts[@]}" || fail "Could not extract ${temp_zip_path}"

  log_info "Downloading ${TOOL_NAME} release ${version}... DONE"
  log_info
}

GRI_CLJ_KONDO__install_downloaded() {
  # inputs
  local -r type="${GRI_CLJ_KONDO__INSTALL_TYPE:-}"
  local -r version="${GRI_CLJ_KONDO__INSTALL_VERSION:-}"
  local -r download_path="${GRI_CLJ_KONDO__DOWNLOAD_PATH:-}"
  local -r install_path="${GRI_CLJ_KONDO__INSTALL_PATH:-}"

  # inputs validation
  [ "${type}" != "version" ] && fail "asdf-${TOOL_NAME} supports release installs only"
  [ -z "${version}" ] && fail "version can't be empty"
  [ -z "${download_path}" ] && fail "download path can't be empty"
  [ -z "${install_path}" ] && fail "install path can't be empty"

  (
    mkdir -p "${install_path}"
    cp -r "${download_path}"/* "${install_path}"

    # test the command is installed
    local tool_cmd
    tool_cmd="$(echo "${TOOL_TEST}" | cut -d' ' -f1)" # actually take only the first param
    test -x "${install_path}/${tool_cmd}" || fail "Expected ${install_path}/${tool_cmd} to be executable."

    log_info "${TOOL_NAME} ${version} installation was successful!"
  ) || (
    rm -rf "${install_path}"
    fail "An error occurred while installing ${TOOL_NAME} ${version}."
  )
}

# Installs clj-kondo using the specified version.
# Basically it runs under the hood two functions:
# - GRI_CLJ_KONDO__download &
# - GRI_CLJ_KONDO__install_downloaded
GRI_CLJ_KONDO__install() {
  # inputs
  local -r type="${GRI_CLJ_KONDO__INSTALL_TYPE:-}"
  local -r version="${GRI_CLJ_KONDO__INSTALL_VERSION:-}"
  local -r install_path="${GRI_CLJ_KONDO__INSTALL_PATH:-}"
  local -r github_api_token="${GITHUB_API_TOKEN:-}" # optional

  # inputs validation
  [ "${type}" != "version" ] && fail "asdf-${TOOL_NAME} supports release installs only"
  [ -z "${version}" ] && fail "version can't be empty"
  [ -z "${install_path}" ] && fail "install path can't be empty"

  local download_path
  download_path="$(temp_dir "asdf-clj-kondo-download")"
  add_on_exit rm -rf "${download_path}"

  GRI_CLJ_KONDO__INSTALL_TYPE="${type}" \
    GRI_CLJ_KONDO__INSTALL_VERSION="${version}" \
    GRI_CLJ_KONDO__DOWNLOAD_PATH="${download_path}" \
    GITHUB_API_TOKEN="${github_api_token}" \
    GRI_CLJ_KONDO__download

  GRI_CLJ_KONDO__INSTALL_TYPE="${type}" \
    GRI_CLJ_KONDO__INSTALL_VERSION="${version}" \
    GRI_CLJ_KONDO__INSTALL_PATH="${install_path}" \
    GRI_CLJ_KONDO__DOWNLOAD_PATH="${download_path}" \
    GRI_CLJ_KONDO__install_downloaded
}

GRI_CLJ_KONDO__latest_stable() {
  # inputs
  local -r gh_repo="${GH_REPO}"
  local -r github_api_token="${GITHUB_API_TOKEN:-}" # optional
  # body
  GITHUB_API_TOKEN="${github_api_token}" \
    GRIC_GH_latest_stable "${gh_repo}"
}

GRI_CLJ_KONDO__list_all_versions() {
  # inputs
  local -r gh_repo="${GH_REPO}"
  # body
  GRIC_GH_list_all_versions "${gh_repo}"
}
