#!/usr/bin/env bash

# SPDX-License-Identifier: 0BSD

return 0 2>/dev/null || true

VIM_PLUG_DIR="$(realpath --no-symlinks "$(dirname "$0")")/testdir"
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

function vim_plug_msg {
    echo ":: $*"
} >&2

function vim_plug_error {
    echo "$_VIM_PLUG_PROGNAME_: $*"
} >&2

function vim_plug_test_file {
    local file="$1"
    if ! [[ -r "$file" ]]; then
        if ! [[ -s "$file" ]]; then
            if ! [[ -f "$VIM_PLUG_LIST_FILE" ]]; then
                vim_plug_error "$file: no such file"
                exit 1
            fi
            vim_plug_error "$file: file is empty"
            exit 1
        fi
        vim_plug_error "$file: file not readable"
        exit 1
    fi
}

function vim_plug_run {
    local name repo
    vim_plug_test_file "$VIM_PLUG_LIST_FILE"
    while IFS=$'\n' read -r line; do
        IFS=$' \t' read -r name repo <<< "$line"
        if
            cd "$VIM_PLUG_DIR/$name" 2>/dev/null                                         \
            && [[ "$(git remote -v 2>/dev/null | awk '/fetch/{print $2}')" == "$repo" ]]
        then
            vim_plug_msg "Updating $name ($repo)"
            git pull
        else
            [[ "$VIM_PLUG_DIR/$name" == "$PWD" ]]        \
            && : remove pre-existing directory/git-repo  \
            && cd "$VIM_PLUG_DIR"                        \
            && rm -rf "${VIM_PLUG_DIR:?}/$name"
            vim_plug_msg "Installing $name ($repo)"
            git clone "$repo" "${VIM_PLUG_DIR##"$PWD/"}/$name"
        fi
        cd "$VIM_PLUG_DIR" || return 0
    done < "$VIM_PLUG_LIST_FILE"
}

declare -A cmdispatch=(
    ['run']='vim_plug_run'
    ['help']='vim_plug_help'
)

_VIM_PLUG_ARGS_="$(getopt --shell bash -o 'h' -l 'help' -- "$@")" || {
    vim_plug_help
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
    if [[ -z "$cmd" ]]; then
        cmd="$1"
        shift
    fi
    # if $cmd is invalid
    if [[ -z "${cmdispatch["$cmd"]}" ]]; then
        # if there are $* continue to next test
        if [[ -z "$*" ]]; then
            vim_plug_error "unrecognized command:" "$cmd"
            vim_plug_help
            exit 1
        fi
    fi
fi

# if there are $*
if [[ "$*" ]]; then
    vim_plug_error "unrecognized arguments:" "$cmd" "$@"
    vim_plug_help
    exit 1
fi

if [[ "$cmd" ]]; then
    "${cmdispatch["$cmd"]}"
else
    "${cmdispatch['run']}"  # default
fi
