#!/bin/bash

MB_DISTRO=""
CMD=""

function _die () {
    echo $1
    exit 1
}

function _check_if_sudo_needed () {
    if [ "$EUID" -ne 0 ]
    then
        # need to place sudo in front of the administrative commands
        [[ -f $(which sudo) ]] ||
        _die "You're not root and you don't have sudo installed: I won't be \
able to run admin commands"
        CMD=$(which sudo)
    fi
}

function detect_distro () {
    if [ -f /etc/os-release ]
    then
        echo "$(cat /etc/os-release | grep ID= | cut -d'=' -f2 | head -n1)"
    fi
}

function set_distro () {
    MB_DISTRO="$1"
}

function install_centos () {
    $CMD yum install -y "$1"
}

function install_ubuntu () {
    $CMD apt-get install -y "$1"
}

function install () {
    local package_list="$1"
    
    if [ -z "$MB_DISTRO" ]
    then
        set_distro "$(detect_distro)"
    fi

    case "$MB_DISTRO" in
        "ubuntu")
            install_ubuntu "$package_list"
            ;;
        "centos")
            install_centos "$package_list"
            ;;
        *)
            _die "Package installation on this distro is not supported yet"
    esac
}

_check_if_sudo_needed
