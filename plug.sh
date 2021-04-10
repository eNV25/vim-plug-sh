#!/usr/bin/env bash

# SPDX-License-Identifier: 0BSD

return 0 2>/dev/null || true

VIM_PLUG_DIR="$(realpath "$(dirname "$0")")/testdir"
VIM_PLUG_LIST_FILE="$VIM_PLUG_DIR/plug.list"

_VIM_PLUG_PROGNAME_="$(basename "$0")"

function vim_plug_help {
    echo
    echo "usage:"
    echo "    $_VIM_PLUG_PROGNAME_"
    echo "    $_VIM_PLUG_PROGNAME_ run"
    echo "    $_VIM_PLUG_PROGNAME_ --help|-h"
    echo
} >&2

function vim_plug_test_file {
    local file="$1"
    if ! [[ -r "$file" ]]; then
        if ! [[ -s "$file" ]]; then
            if ! [[ -f "$VIM_PLUG_LIST_FILE" ]]; then
                echo "$_VIM_PLUG_PROGNAME_: $file: no such file" >&2
                exit 1
            fi
            echo "$_VIM_PLUG_PROGNAME_: $file: file is empty" >&2
            exit 1
        fi
        echo "$_VIM_PLUG_PROGNAME_: $file: file not readable" >&2
        exit 1
    fi
}

function vim_plug_run {
    local name repo
    vim_plug_test_file "$VIM_PLUG_LIST_FILE"
    while IFS=$'\n' read -r line; do
        IFS=$' \t' read -r name repo <<< "$line"
        if
            cd "$VIM_PLUG_DIR/$name" 2>/dev/null \
            && [[ "$(git remote -v 2>/dev/null | awk '/fetch/{print $2}')" == "$repo" ]]
        then
            echo ":: Updating $name ($repo)"
            git pull
        else
            echo ":: Installing $name ($repo)"
            git clone "$repo" "${VIM_PLUG_DIR##"$PWD/"}/$name"
        fi
    done < "$VIM_PLUG_LIST_FILE"
}

declare -A cmdispatch=(
    ['run']='vim_plug_run'
    ['help']='vim_plug_help'
)

_VIM_PLUG_ARGS_="$(getopt --shell bash -o 'h' -l 'help' -- "$@")" || {
    "${cmdispatch['help']}" 
    exit 1
}

eval set -- "$_VIM_PLUG_ARGS_"

# arguments
while true; do
    case "$1" in
    -h|--help)
        cmd='help'
        shift ;;
    --)
        shift
        break ;;
    esac
done

# positional arguments
if [[ "$1" ]]; then
    cmd="$1"
    shift
    if ! [[ "${cmdispatch["$cmd"]}" ]]; then
        if ! [[ "$*" ]]; then
            echo "$_VIM_PLUG_PROGNAME_: unrecognized command:" "$cmd" >&2
            "${cmdispatch['help']}"
            exit 1
        fi
    fi
fi

if [[ "$*" ]]; then
    echo "$_VIM_PLUG_PROGNAME_: unrecognized arguments:" "$cmd" "$@" >&2
    "${cmdispatch['help']}"
    exit 1
fi

if [[ "$cmd" ]]; then
    "${cmdispatch["$cmd"]}"
else
    "${cmdispatch['run']}"  # default
fi
