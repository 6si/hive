#!/bin/bash

__hive_git_branch() {
    command -v git >/dev/null 2>&1 || return
    git rev-parse --is-inside-work-tree >/dev/null 2>&1 || return
    git branch --show-current 2>/dev/null
}

__hive_prompt_git() {
    local b
    b="$(__hive_git_branch)"
    if [ -n "$b" ]; then
        printf '(%s)' "$b"
    fi
}

if [ -n "$DEVPOD_WORKSPACE_ID" ]; then
    export PS1="\[\e[32m\]\u@\h\[\e[33m\]($DEVPOD_WORKSPACE_ID)\[\e[34m\]:\w \[\e[33m\]$(__hive_prompt_git)\[\e[0m\]\n\$ "
else
    export PS1="\[\e[32m\]\u@\h:\[\e[34m\]\w \[\e[33m\]$(__hive_prompt_git)\[\e[0m\]\n\$ "
fi
