#!/bin/bash
#
# Gert Vaikre A21
# Otsib kõik failid (v.a. kodukaustast), mis kuuluvad
# argumendina etteantud kasutajale.
#

NIMI=$1
KODU=$(getent passwd $1 | cut -d":" -f6)

if [ $# -ne 1 ]; then
    echo "kasutamine: $0 kasutaja-nimi"
    echo "näide: $0 student"
    exit 1
fi

find / -user $NIMI -not -path "$KODU/*"
