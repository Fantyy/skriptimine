#!/bin/bash

if [ $UID -ne 0 ]; then
    echo "käivita root kasutajana"
    exit 2
fi

case "$1" in
'md5')
    HASH=1
;;
'blowfish')
    HASH=2
;; 
'sha256')
    HASH=5 
;;
'sha512')
    HASH=6
;;
*)
    echo "kasutamine: $0 [sha512/sha256/blowfish/md5]"
    echo "näide: $0 sha512"
    exit 1
;;
esac

KASUTAJAD=$(getent shadow | grep ":\$$HASH" | cut -d":" -f1)
echo "kasutajad, kelle parooliräsi on $1'ga räsitud:"

if [[ -z $KASUTAJAD ]]; then
    echo "mitte ühtegi : ("
    exit 3
else
    echo $KASUTAJAD
fi
