#!/usr/bin/env bash

# -----------------------------------------------------------------------------
# Copyright 2019 Dave Jarvis
#
#   Permission is hereby granted, free of charge, to any person obtaining a
#   copy of this software and associated documentation files (the
#   "Software"), to deal in the Software without restriction, including
#   without limitation the rights to use, copy, modify, merge, publish,
#   distribute, sublicense, and/or sell copies of the Software, and to
#   permit persons to whom the Software is furnished to do so, subject to
#   the following conditions:
#
#   The above copyright notice and this permission notice shall be included
#   in all copies or substantial portions of the Software.
#
#   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS
#   OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
#   MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
#   IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
#   CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
#   TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
#   SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
# -----------------------------------------------------------------------------
# 
# ping2.sh
# rummage around in a kickstarter and ding if it passes a value
#
# lame - requires a hard code to the wav file
#
readonly SCRIPT_SRC="$(dirname "${BASH_SOURCE[0]}")"
readonly SCRIPT_DIR="$(cd "${SCRIPT_SRC}" >/dev/null 2>&1 && pwd)"
readonly SCRIPT_NAME=$(basename "$0")

# -----------------------------------------------------------------------------
# Entry point.
# -----------------------------------------------------------------------------
main() {
  parse_commandline "$@"

  if [ -n "${ARG_HELP}" ]; then
    show_usage
    exit 3
  fi

  log "Check for missing software requirements"
  validate_requirements

  if [ "${REQUIRED_MISSING}" -gt "0" ]; then
    exit 4
  fi
 
  cd "${SCRIPT_DIR}" && execute_tasks
}

# -----------------------------------------------------------------------------
# Perform tasks to execute.
# -----------------------------------------------------------------------------
execute_tasks() {

if [ -n "${ARG_MONEY}" ]; then

    noise=/home/bdunbar/script/tjic/service-bell_daniel_simion.wav

    var=`curl https://www.kickstarter.com/projects/tjic/escape-the-city-a-how-to-homesteading-guide/stats.json`

    cut=`echo $var | cut -d'"' -f16`

    cut2=`echo $cut | rev | cut -c3- | rev`

    if [ $cut2 -gt $ARG_VALUE ]
    then
	    aplay $noise	
    fi
fi
}

# -----------------------------------------------------------------------------
# Check for required commands.
# -----------------------------------------------------------------------------
validate_requirements() {
  required aplay "install aplay"
}

# -----------------------------------------------------------------------------
# Check for a required command.
#
# $1 - Command to execute.
# $2 - Where to find the command's source code or binaries.
# -----------------------------------------------------------------------------
required() {
  local missing=0

  if ! command -v "$1" > /dev/null 2>&1; then
    warning "Missing requirement: install $1 ($2)"
    missing=1
  fi

  REQUIRED_MISSING=$(( REQUIRED_MISSING + missing ))
}

# -----------------------------------------------------------------------------
# Write coloured text to standard output.
#
# $1 - The text to write
# $2 - The colour to write in
# -----------------------------------------------------------------------------
coloured_text() {
  printf "%b%s%b\n" "$2" "$1" "${COLOUR_OFF}"
}

# -----------------------------------------------------------------------------
# Write a warning message to standard output.
#
# $1 - The text to write
# -----------------------------------------------------------------------------
warning() {
  coloured_text "$1" "${COLOUR_WARNING}"
}

# -----------------------------------------------------------------------------
# Write an error message to standard output.
#
# $1 - The text to write
# -----------------------------------------------------------------------------
error() {
  coloured_text "$1" "${COLOUR_ERROR}"
}

# -----------------------------------------------------------------------------
# Write a timestamp and message to standard output.
#
# $1 - The text to write
# -----------------------------------------------------------------------------
log() {
  if [ -n "${ARG_DEBUG}" ]; then
    printf "[%s] " "$(date +%H:%I:%S.%4N)"
    coloured_text "$1" "${COLOUR_LOGGING}"
  fi
}

# -----------------------------------------------------------------------------
# Set global argument values.
# -----------------------------------------------------------------------------
parse_commandline() {
  while [ "$#" -gt "0" ]; do
    local consume=1

    case "$1" in
      -d|--debug)
        ARG_DEBUG="true"
      ;;
      -h|-\?|--help)
        ARG_HELP="true"
      ;;
      -m|-\?|--money)
        ARG_MONEY="true"
        ARG_VALUE="$2"
      ;;
      *)
        # Skip argument
      ;;
    esac

    shift ${consume}
  done

}

# -----------------------------------------------------------------------------
# Show acceptable command-line arguments.
# -----------------------------------------------------------------------------
show_usage() {
  printf "Usage: %s [OPTION...]\n" "${SCRIPT_NAME}" >&2
  printf "  -m, --money\t\tDollar value to check at KS\n" >&2
  printf "  -d, --debug\t\tLog messages while processing\n" >&2
  printf "  -h, --help\t\tShow this help message then exit\n" >&2
  printf "  check on the kickstarter" >&2
}

# ANSI colour escape sequences
readonly COLOUR_BLUE='\033[1;34m'
readonly COLOUR_PINK='\033[1;35m'
readonly COLOUR_DKGRAY='\033[30m'
readonly COLOUR_DKRED='\033[31m'
readonly COLOUR_YELLOW='\033[1;33m'
readonly COLOUR_OFF='\033[0m'

# Colour definitions used by script
readonly COLOUR_LOGGING=${COLOUR_BLUE}
readonly COLOUR_WARNING=${COLOUR_YELLOW}
readonly COLOUR_ERROR=${COLOUR_DKRED}

# Ensure pre-existing values do not affect the script
unset ARG_HELP
unset ARG_DEBUG
unset REQUIRED_MISSING
unset ARG_CONNECT
unset ARG_DISCONNECT

# -----------------------------------------------------------------------------
# Run the script, passing in all command-line arguments.
# -----------------------------------------------------------------------------
main "$@"
