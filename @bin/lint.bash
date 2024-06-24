#!/usr/bin/env bash
#  Copyright (c) 2024 Greg Rynkowski. All rights reserved.
#  License: MIT License

# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -
#
# Lint bash source files
#
# Example:
#
#     @bin/lint.bash
#
# - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - -

# Bash Strict Mode Settings
set -euo pipefail
# Path Initialization
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd -P || exit 1)"
ROOT_DIR="$(cd "${SCRIPT_DIR}/.." && pwd -P || exit 1)"
export SHELL_GR_DIR="${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@e5a1b73" # needed for shell-gr to resolve paths
# Library Sourcing
source "${ROOT_DIR}/.github_deps/rynkowsg/shell-gr@e5a1b73/lib/tool/lint.bash" # lint

main() {
  local error=0
  lint bash \
    < <(
      find "${ROOT_DIR}" \( -type f \( -name '*.bash' -o -name '*.sh' \) -o -path '*/bin/*' \) \
        | grep -v -E '(.github_deps|/gen/)' \
        | sort
    ) \
    || ((error += $?))
  lint bats < <(find "${ROOT_DIR}" -type f -name '*.bats' | sort) || ((error += $?))
  if ((error > 0)); then
    exit "$error"
  fi
}

main
