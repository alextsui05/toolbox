#!/bin/bash
function script_dir
{
    echo "$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
}

function debug
{
    if $VERBOSE; then
        echo "$*"
    fi
}

function redirect
{
    local OUT=$1
    shift
    if $DRY_RUN; then
        echo "$*" \> ${OUT}
    else
        run "$@" > ${OUT}
    fi
}

function run
{
    if $DRY_RUN; then
        echo "$*"
    else
        debug "$*"
        eval "$@"
    fi
}

function usage
{
    echo "Usage: $(basename $0) [-hnv] arg1 arg2"
}

VERBOSE=false
DRY_RUN=false
while getopts ":nhv" opt; do
    case "${opt}" in
    h)
        usage
        exit 0
        ;;

    n)
        DRY_RUN=true
        ;;

    v)
        VERBOSE=true
        ;;

    \?)
        echo "Unrecognized option -${OPTARG}"
        usage
        exit 1
        ;;

    :)
        echo "Option -${OPTARG} requires an argument."
        usage
        exit 1
        ;;
    esac
done
shift $((OPTIND-1))

if [[ $# < 2 ]]; then
    usage
    exit 1
fi

ARG1=$1
ARG2=$2
