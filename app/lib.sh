#!/bin/sh
# vim: ft=sh ts=4 sw=4 sts=4 noet
set -euf

export COLOR_NC='\e[0m'
export COLOR_WHITE='\e[1;37m'
export COLOR_BLACK='\e[0;30m'
export COLOR_BLUE='\e[0;34m'
export COLOR_LIGHT_BLUE='\e[1;34m'
export COLOR_GREEN='\e[0;32m'
export COLOR_LIGHT_GREEN='\e[1;32m'
export COLOR_CYAN='\e[0;36m'
export COLOR_LIGHT_CYAN='\e[1;36m'
export COLOR_RED='\e[0;31m'
export COLOR_LIGHT_RED='\e[1;31m'
export COLOR_PURPLE='\e[0;35m'
export COLOR_LIGHT_PURPLE='\e[1;35m'
export COLOR_BROWN='\e[0;33m'
export COLOR_YELLOW='\e[1;33m'
export COLOR_GRAY='\e[0;30m'
export COLOR_LIGHT_GRAY='\e[0;37m'

# Command wrappers to handle output or errors in specific ways.
silently() {
	"$@" >/dev/null 2>&1
}

quietly() {
	"$@" >/dev/null
}

carelessly() {
	"$@" 2>/dev/null || true
}

# Logging functions.
fatality() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_RED}$*${COLOR_NC}" 1>&2
	exit 1
}

inform() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_CYAN}$*${COLOR_NC}"
}

whisper() {
	# shellcheck disable=SC2039
	echo -e "${COLOR_GRAY}$*${COLOR_NC}"
}

# allow scripts to use dab without spawning another container by skipping main
# and executing subcommands directly. For consistency main uses this as well.
dab() {
	sub="subcommands/$1.sh"
	[ -f "$sub" ] || fatality "$1 is not a valid subcommand!"
	shift
	"$sub" "$@"
}

# config helpers
config_get() {
	path="/etc/dab/$1"
	[ ! -r "$path" ] || cat "$path"
}

config_set() {
	whisper "setting config key $1 to $2"
	path="/etc/dab/$1"
	mkdir -p "$(dirname "$path")"
	if [ -n "$2" ]; then
		echo "$2" >"$path"
	else
		rm -f "$path"
	fi
}

config_add() {
	path="/etc/dab/$1"
	mkdir -p "$(dirname "$path")"
	echo "$2" >>"$path"
	whisper "added $2 to config key $1 which now contains $(wc -l <"$path") values"
}

# Auto update functionality
day_in_seconds=86400
should_selfupdate() {
	[ "${DAB_AUTOUPDATE:-yes}" = 'yes' ] || return 1

	last_updated="$(config_get "${1:-/}updates/last")"
	[ -n "$last_updated" ] || return 0

	now="$(date +%s)"
	seconds_since_last_update="$((now - last_updated))"
	[ "$seconds_since_last_update" -gt "$day_in_seconds" ]
}

maybe_selfupdate_repo() {
	if should_selfupdate "repo.$1"; then
		inform "checking $1 repo for updates"
		(
			cd "$DAB_REPO_PATH/$1"
			out="$(git fetch)"
			if echo "$out" | silently grep origin/master; then
				inform "$1 repo has updates on origin/master!"
			fi
		)
	fi
}
maybe_selfupdate_dab() {
	if should_selfupdate; then
		inform "self updating dab!"
		config_set updates/last "$(date +%s)"
		./subcommands/update.sh
	fi
}

# Subcommand table display
alias draw_subcommand_table="sort -s -k 1,1 | column -s':' -o' | ' -t -N SUBCOMMAND,ALIASES,DESCRIPTION -R SUBCOMMAND"
subcmd_row() {
	cmd="$1"
	aliases=""
	desc="$2"
	if [ "$#" -eq 3 ]; then
		aliases="$2"
		desc="$3"
	fi
	echo "$cmd:$aliases:$desc"
}