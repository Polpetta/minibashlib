#!/bin/bash

MB_DISTRO=""
CMD=""

function _die () {
    echo "$1"
    exit 1
}

function _check_if_sudo_needed () {
    if [ "$EUID" -ne 0 ]
    then
        # I need to place sudo in front of the administrative commands
        [[ -f $(which sudo) ]] ||
        _die "You're not root and you don't have sudo installed: I won't be \
able to run admin commands"
        CMD=$(which sudo)
    fi
}

function detect_distro () {
    if [ -f /etc/os-release ]
    then
        local res="$(cat /etc/os-release | grep ID= | cut -d'=' -f2 | head -n1)"
        # It removes extra double quotes
        echo $(echo $res | sed "s/^\(\"\)\(.*\)\1\$/\2/g")
    fi
}

function set_distro () {
    MB_DISTRO="$1"
}

function get_distro () {
    echo $MB_DISTRO
}

function install_centos () {
    $CMD yum install -y $@
}

function install_ubuntu () {
    $CMD apt-get install -y $@
}

function update_ubuntu () {
    $CMD apt-get update
    $CMD apt-get upgrade -y
    $CMD apt-get autoclean
    $CMD apt-get autoremove -y
}

function update_centos () {
    $CMD yum upgrade -y
}

function update () {
    if [ -z "$MB_DISTRO" ]
    then
        set_distro "$(detect_distro)"
    fi

    case "$MB_DISTRO" in
        "ubuntu")
            update_ubuntu
            ;;
        "centos")
            update_centos
            ;;
        *)
            _die "Package installation on this distro is not supported yet"
    esac
}

function install () {
    local package_list=( "$@" )
    
    if [ -z "$MB_DISTRO" ]
    then
        set_distro "$(detect_distro)"
    fi

    case "$MB_DISTRO" in
        "ubuntu")
            install_ubuntu "${package_list[@]}"
            ;;
        "centos")
            install_centos "${package_list[@]}"
            ;;
        *)
            _die "Package installation on this distro is not supported yet"
    esac
}

function exec_root_func ()
{
    # I use underscores to remember it's been passed
    local _funcname_="$1"

    local params=( "$@" )             ## array containing all params passed here
    local tmpfile="/dev/shm/$RANDOM"  ## temporary file
    local content                     ## content of the temporary file
    local regex                       ## regular expression
    local func                        ## function source

    # Shift the first param (which is the name of the function)
    unset params[0]              ## remove first element
    # params=( "${params[@]}" )  ## repack array

    content="#!/bin/bash\n\n"

    # Write the params array
    content="${content}params=(\n"

    regex="\s+"
    for param in "${params[@]}"
    do
        if [[ "$param" =~ $regex ]]
        then
            content="${content}\t\"${param}\"\n"
        else
            content="${content}\t${param}\n"
        fi
    done

    content="$content)\n"
    echo -e "$content" > "$tmpfile"

    # Append the function source
    echo "#$( type "$_funcname_" )" >> "$tmpfile"

    # Append the call to the function
    echo -e "\n$_funcname_ \"\${params[@]}\"\n" >> "$tmpfile"

    sudo bash "$tmpfile"
    local sudo_exit_code=$?
    rm "$tmpfile"

    echo $sudo_exit_code
}

_check_if_sudo_needed
