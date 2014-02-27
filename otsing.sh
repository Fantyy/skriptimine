#!/bin/bash

NIMI=$1

if [ $# -ne 1 ]; then
    echo "kasutamine: $0 kasutaja-nimi"
    echo "näide: $0 student"
    exit 1
fi

find / -user $NIMI -not -path "/home/$NIMI/*"

