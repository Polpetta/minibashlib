#!/bin/bash

function check () {
    if [ "$1" -ne 0 ]
    then
        msg err "$2"
        exit 1
    fi
}

function set_dbg () {
    if [ "$1" = "true" ]
    then
        set -x
    else
        set +x
    fi
}

function exec_if_not_null () {
    [[ -z "$1" ]] && "$2" 
}

function exec_if_null () {
    [[ -z "$1" ]] || "$2"
}
