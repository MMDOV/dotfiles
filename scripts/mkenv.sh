#!/usr/bin/env bash

mkenv() {
    mkdir "$DIRNAME"
    cd "$DIRNAME"
    $1
    cd ".."
}

DIRNAME="$1"
if [ $# -ne 2 ]; then
    echo "Usage: $0 <Directory-name> <environment-type>"
fi

ENVTYPE="$2"

if [ "$ENVTYPE" == "venv" ]; then
    mkenv "python -m venv venv"
elif [ "$ENVTYPE" == "mamba" ]; then
    mkenv "mamba create -n "$DIRNAME""
elif [ "$ENVTYPE" == "conda" ]; then
    mkenv "conda create -n "$DIRNAME""
else
    echo "Environment type not supported. Make sure you use one of the supported names (venv, mamba, conda)"
    exit 1
fi
