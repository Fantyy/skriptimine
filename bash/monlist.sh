#!/bin/bash
#
# Gert Vaikre A21
# Kontrollib, kas ntp server lubab kasutada käsku monlist.
# Et ntpdc -c monlisti järgi väga kaua ootama ei peaks (kontroll toimib
# alles pärast ntpdc lõpetamist) kasutatakse timeout funktsiooni, mis
# tapab protsessi etteantud aja möödudes.
#
 
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
    COM=$1
    TARGET=$(echo $COM | cut -d" " -f1)

    $COM &
    sleep $TIME
    if [ $(ps -ef | grep $TARGET | grep -v grep >/dev/null; echo $?) -eq 0 ]; then
        killall $TARGET 
    fi
}

echo "oota natuke... (timeout $TIME)"
if [ $(timeout "ntpdc -c monlist $IP" 2>/dev/null | grep "remote" >/dev/null ; echo $?) -eq 0 ]; then
    echo "ntp server $IP lubab kasutada käsku monlist"
    exit 0
else
    echo "ntp server $IP ei luba kasutada käsku monlist"
    exit 2
fi
