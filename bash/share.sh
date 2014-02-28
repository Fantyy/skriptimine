#!/bin/bash
#
# Gert Vaikre A21
# Võtab argumentidena kaustanime, grupinime [võimalik ka sheeri nimi
# täpsustada; kui seda ei anta, kasutatakse kaustanime], vajadusel
# paigaldab samba/loob grupi/teeb kausta ning kirjutab smb.confi
# sheeri kohta vajalikud andmed.
#

export LC_ALL=C

KAUST=$1
GRUPP=$2

if [ $# -eq 3 ]; then
    SHARE=$3
elif [ $# -eq 2 ]; then
    SHARE=$(basename $KAUST)
else
    echo "kasutamine: $0 kaust grupp [jagatud-kaust]"
    exit 1
fi

if [ $UID -ne 0 ]; then
    echo "käivita root kasutajana"
    exit 2
fi

{ type smbd &>/dev/null && echo 'samba on paigaldatud'; } ||
  { echo "uuendan repod/paigaldan samba"
  apt-get update >/dev/null && apt-get install -y samba >/dev/null; }

if [ $(getent group $GRUPP &>/dev/null; echo $?) -eq 0 ]; then
    echo "grupp on olemas"
else
    echo "grupp ei ole olemas"
    echo "teen grupi"
    groupadd $GRUPP
fi


if [ -d $KAUST ]; then
    echo "kaust on olemas"
else
    echo "kaust ei ole olemas"
    echo "teen kausta"
    mkdir $KAUST 
    #if [ $(echo $?) -ne 0 ]; then
    #    echo "kausta tegemisel tekkis viga"
    #    exit 3
    #fi
    echo "määran kaustale õigused"
    chgrp $GRUPP $KAUST
    chmod g+w $KAUST
fi

if [ $(grep -E "^\[$SHARE\]$" /etc/samba/smb.conf &>/dev/null; echo $?) -eq 0 ]; then
    echo "sheer on juba olemas, exit"
    exit 3 
else
    echo "sheer ei ole olemas"
fi

#backup igaks juhuks
echo "teen smb.conf backupi /etc/samba/smb.conf-backup"
cp /etc/samba/smb.conf /etc/samba/smb.conf-backup

echo "kirjutan sheeri smb.confi"
cat >> /etc/samba/smb.conf << LOPP

[$SHARE]
read only = no
path = $KAUST
valid users = @$GRUPP
force group = $GRUPP
create mask = 770
directory mask = 770
LOPP

echo "kontrollin smb.conf'i testparmiga"
if [ $(testparm; echo $?) -eq 1 ]; then
    echo "esines viga, taastan smb.confi backupist"
    rm /etc/samba/smb.conf
    mv /etc/samba/smb.conf-backup /etc/samba/smb.conf
    exit 4
fi

echo "kõik korras, teen smbd service'le restardi"
service smbd restart

echo "valmis. kui miskit ei sobi, siis backup asub failis /etc/samba/smb.conf-backup"
