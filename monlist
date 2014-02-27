#!/bin/bash
# Gert Vaikre A21
# Kontrollib, kas ntp server lubab kasutada käsku monlist.
# Et ntpdc -c monlisti järgi väga kaua ootama ei peaks (kontroll toimib alles pärast programmi lõpetamist)
# kasutatakse timeout funktsiooni, mis tapab protsessi etteantud aja möödudes.
# Iseenesest saaks selle skriptiga kogu neti läbi skännida (pannes timeout üpris väikseks),
# kui see kõik loopi panna ja argumentideks IP'de vahemik.
 
export LC_ALL=C
 
IP=$1
TIME=5
 
if [ $# -eq 2 ]; then
    TIME=$2
elif [ $# -eq 0 ]; then
    echo "kasutamine: $0 ip [timeout]"
    echo "default timeout 5s"
    exit 1
fi
 
function timeout {
    PROGRAMM=$(echo $1 | cut -d" " -f1)
    $1 &
    sleep $2
    if [ $(ps -ef | grep $PROGRAMM | grep -v grep >/dev/null; echo $?) -eq 0 ]; then
        killall $PROGRAMM 
    fi
}
 
if [ $(timeout "ntpdc -c monlist $IP" "$TIME" 2>/dev/null | grep remote >/dev/null ; echo $?) -eq 0 ]; then
    echo "ntp server $1 lubab kasutada käsku monlist"
else
    echo "ntp server $1 ei luba kasutada käsku monlist"
fi
