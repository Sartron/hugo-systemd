#!/bin/bash

# Script authored by Angel N. <angel@ludi.sh> under the MIT License.

declare -r __SYSTEMD_UNIT_DIR="${HOME}/.config/systemd/user" \
  __SYSTEMD_UNIT_NAME='hugo.service'
declare __HUGO_BINARY=''

function preflight_checks()
{
  # $1 passed to script must be a valid file.
  if [ ! -f "${1}" ]
  then
    echo "'${1}' is not a valid file, aborting!" >&2
    return 1
  fi

  # Try to find hugo binary from PATH.
  __HUGO_BINARY="$(command -v hugo)"
  if [ -z "${__HUGO_BINARY}" ]
  then
    echo 'Unable to find hugo binary under PATH variable, aborting!' >&2
    return 2
  fi

  if [ ! -f "${__SYSTEMD_UNIT_NAME}" ]
  then
    echo "'${__SYSTEMD_UNIT_NAME}'" >&2
    return 3
  fi

  # Create user-level systemd config directory.
  [ -d "${HOME}/.config/systemd/user" ] || mkdir -pv "${HOME}/.config/systemd/user"
}

function install_service()
{
  local name_hugo="$(basename "${1}")"
  local path_systemd_unit="${__SYSTEMD_UNIT_DIR}/${name_hugo}@${__SYSTEMD_UNIT_NAME}" \
    path_source="$(dirname "$(dirname /home/ludi/ludi.sh/ludi-site_dev/systemd/development)")" \
    path_env="$(readlink -f "${1}")"

  # Install and configure systemd unit.
  cp -fv "${__SYSTEMD_UNIT_NAME}" "${path_systemd_unit}"
  sed -ri '/^EnvironmentFile=/s/=/='"${path_env////\\/}"'/' "${path_systemd_unit}" # Service/EnvironmentFile
  sed -ri '/^ExecStart=/s/ExecStart=hugo/ExecStart='"${__HUGO_BINARY////\\/}"'/' "${path_systemd_unit}"  # Service/ExecStart/hugo
  sed -ri '/^ExecStart=/s/--source=/--source='"${path_source////\\/}"'/' "${path_systemd_unit}"  # Service/ExecStart/source

  # Reload systemd and restart the service if it is running.
  systemctl --user daemon-reload
  if systemctl --user is-active "${name_hugo}@${__SYSTEMD_UNIT_NAME}"
  then
    echo "Restarting unit '${name_hugo}@${__SYSTEMD_UNIT_NAME}'."
    systemctl --user restart "${name_hugo}@${__SYSTEMD_UNIT_NAME}"
  fi
}

function main()
{
  preflight_checks "${1}" || return ${?}
  install_service "${1}" || return ${?}
}

main "${@}"
