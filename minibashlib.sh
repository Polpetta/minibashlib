#!/bin/bash

readonly MB_RELEASE_REPO_URL=https://github.com/Polpetta/minibashlib
readonly MB_RAW_REPO_URL=https://raw.githubusercontent.com/Polpetta/minibashlib

# args:
# - $1: module name - if blank all modules are fetched
# - $2: module version - if blank modules are downloaded from master, otherwise
#       a corrispective tag is downloaded, if possible
function mb_load () {

    local version=""
    local module_name=$1
    local module_version=$2

    if [ -z "$module_name" ]
    then
        local mb_modules=()
        mb_modules+=("logging")
        mb_modules+=("assertions")
        mb_modules+=("systemop")
        # load all the modules
        local mb_modules_size=$((${#mb_modules[@]} - 1))
        for i in $(seq 0 $mb_modules_size)
        do
            module_name=${mb_modules[$i]}
            mb_load "$module_name" "$2"
        done
    else
        local file_to_load=""
        if [ -z "$2" ]
        then
            version="master"
            file_to_load=$(_mb_download_module "$MB_RAW_REPO_URL/$version/modules/$1.sh")
        else
            version="$2"
            file_to_load=$(_mb_download_module "$MB_BASE_REPO_URL/releases/$2/$1.sh")
        fi

        . $file_to_load

    fi

}

function _mb_download_module () {
    local module_path=$(mktemp)
    curl -s "$1" > $module_path

    echo "$module_path"
}
