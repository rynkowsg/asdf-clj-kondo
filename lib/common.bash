#!/usr/bin/env bash

# shellcheck disable=SC2034
GH_REPO="https://github.com/clj-kondo/clj-kondo"
TOOL_NAME="clj-kondo"
TOOL_TEST="clj-kondo --help"

CURL_OPTS=(-fsSL)
if [ -n "${GITHUB_API_TOKEN:-}" ]; then
  CURL_OPTS=("${CURL_OPTS[@]}" -H "Authorization: token ${GITHUB_API_TOKEN}")
fi

fail() {
  echo -e "asdf-${TOOL_NAME}: $*"
  exit 1
}
