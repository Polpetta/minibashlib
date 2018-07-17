#!/bin/bash

readonly MB_BASE_REPO_URL=https://github.com/Polpetta/minibashlib

function load () {
    set -e
    
    local version=""
    
    if [ -z "$1" ]
    then
        modules=()
        modules+="logging"
        modules+="assertions"
        # load all the modules
        for i in "${arr[@]}"
        do
            load "$i" "$2"
        done
    fi

    local final_repo_url=""
    if [ -z "$2" ]
    then
        version="latest"
        final_repo_url="blob/master/modules"
    else
        version="$2"
    fi

    local module_path=$(mktemp)
    curl -s "$MB_BASE_REPO_URL/$final_repo_url/$2" > $module_path

    set +e
}
