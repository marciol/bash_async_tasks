#!/usr/bin/env bash

__dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source "${__dir}/core.sh"

regular_task() {
  echo "$@"
  sleep $(echo $RANDOM % 10 + 1 | bc)
  echo "This message is from ${0}"
}

task_with_errors() {
  echo "$@"
  sleep $(echo $RANDOM % 10 + 1 | bc)
  inexistent_command
  echo "This message is from ${0}"
}

task_that_exits_on_errors() {
  set -e #exit on first error
  echo "$@"
  sleep $(echo $RANDOM % 10 + 1 | bc)
  echo "This message is from ${0}"
  exit_now_on_inexistent_command
}

run_regular_task_once() {
  echo "${CYAN}* Run regular_task Once...${NORMAL}"

  task_start

  cmd=(regular_task "once" "from regular task")
  task_run cmd[@]

  task_wait
}

run_regular_task_multiple_times() {
  echo "${CYAN}* Run regular_task Multiple times...${NORMAL}"

  task_start

  for i in {0..10}; do
    cmd=(regular_task ${i} "from regular task")
    task_run cmd[@]
  done

  task_wait
}

run_task_with_errors_once() {
  echo "${CYAN}* Run task_with_errors Once...${NORMAL}"

  task_start

  cmd=(task_with_errors "once" "from task with errors")
  task_run cmd[@]

  task_wait
}

run_task_with_errors_multiple_times() {
  echo "${CYAN}* Run task_with_errors Multiple Times...${NORMAL}"

  task_start

  for i in {0..10}; do
    cmd=(task_with_errors ${i} "from task that EXITS ON errors")
    task_run cmd[@]
  done

  task_wait
}

run_task_that_exits_on_errors_once() {
  echo "${CYAN}* Run task_that_exits_on_errors Once...${NORMAL}"

  task_start
  echo "${_task_pid}"

  cmd=(task_that_exits_on_errors "once" "from task that EXITS ON errors")
  task_run cmd[@]

  task_wait
}

run_task_that_exits_on_errors_multiple_times() {
  echo "${CYAN}* Run task_that_exits_on_errors Multiple Times...${NORMAL}"

  task_start

  for i in {0..10}; do
    cmd=(task_that_exits_on_errors ${i} "from task that EXITS ON errors")
    task_run cmd[@]
  done

  task_wait
}

run_regular_task_once
run_regular_task_multiple_times
run_task_with_errors_once
run_task_with_errors_multiple_times
run_task_that_exits_on_errors_once
run_task_that_exits_on_errors_multiple_times

exit 0