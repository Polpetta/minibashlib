#!/bin/bash

readonly MB_BASE_REPO_URL=https://github.com/Polpetta/minibashlib

function load () {

    # TODO: to download scripts directly from master
    # use raw.githubusercontent.com
    
    local version=""
    
    if [ -z "$1" ]
    then
        mb_modules=()
        mb_modules+="logging"
        mb_modules+="assertions"
        # load all the modules
        for i in "${mb_modules[@]}"
        do
            echo "calling again myself: 1: $1, 2: $2, i: $i"
            sleep 10
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

}
