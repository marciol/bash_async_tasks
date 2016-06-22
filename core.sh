#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__dir}/colors.sh"

trap "kill 0" SIGINT SIGQUIT

__task_multiplex() {
  while IFS= read -r _line; do
    __task_cicle_trace "${_line}"
  done < "${_task_pid}"
}

__task_trace() {
  local _job_pid="$1"
  local _line="$2"
  echo "(pid: ${_job_pid}) ${_line}"
}

_task_cicle=0
__task_cicle_trace() {
  local _job_pid=$(echo $1 | sed 's/\((pid.*)\)\(.*\)/\1/')
  local _line=$(echo ${_line} | sed 's/\((pid.*)\)\(.*\)/\2/')
  if (( (${_task_cicle} % 2) == 1 )); then
    _tag="${CYAN}${_job_pid}${NORMAL}"
  else
    _tag="${MAGENTA}${_job_pid}${NORMAL}"
  fi
  echo "${_tag} ${_line}"
  ((++_task_cicle))
}

__task_job_run() {
  local _task=(${!1})
  local _job_id=$(sh -c 'echo $PPID')
  set -o pipefail

  { 
    "${_task[@]}" 2> >(
      while read _line; do 
        echo "${RED}* ${_line}${NORMAL}" >&2
      done
    ); 
  } 2>&1 | { 
    while read _line; do 
      __task_trace "${_job_id}" "${_line}"
    done 
  } > "${_task_pid}" 2>&1 
}

trap __task_finish EXIT
__task_finish() {
  if [[ -a ${_task_pid} ]]; then
    rm ${_task_pid}
  fi
  unset _task_list
  _task_pid=""
}

_task_pid=""
_task_list=()
task_start() {
  local _pid_id=$(base64 /dev/urandom | tr -d '/+' | head -c 32 | tr '[:upper:]' '[:lower:]')
  _task_pid="/var/tmp/${_pid_id}-$$.pid"
  mkfifo ${_task_pid}
}

task_run() {
  if [[ -z $1 ]]; then
    echo "Is mandatory to pass as argument the task to run!" >&2
    exit 1
  fi

  declare -a _task=(${!1})
  __task_job_run _task[@] &
  _task_list+=($!)
}

task_wait() {
  __task_multiplex &
  wait $!
  for _task in ${_task_list[@]}; do
    wait ${_task}
    if [ $? -ne 0 ]; then
      echo "${RED}* Error on pid: ${_task}${NORMAL}"
    fi
  done
  __task_finish
}