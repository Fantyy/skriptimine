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

type smbd &>/dev/null ||
  { echo "uuendan repod/paigaldan samba"
  apt-get update >/dev/null && apt-get install -y samba >/dev/null; }

getent group $GRUPP &>/dev/null ||
  { echo "teen grupi $GRUPP"
  groupadd $GRUPP; }

[ -d $KAUST ] ||
  { echo "teen kausta $KAUST"
  mkdir $KAUST; }

echo "määran kaustale õigused"
chgrp $GRUPP $KAUST
chmod g+w $KAUST

if [ $(grep -E "^\[$SHARE\]$" /etc/samba/smb.conf &>/dev/null; echo $?) -eq 0 ]; then
  echo "smb.confis on $SHARE juba olemas, exit"
  exit 3
fi

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
if [ $(testparm -s &>/dev/null; echo $?) -eq 1 ]; then
    echo "esines viga, taastan smb.confi backupist"
    rm /etc/samba/smb.conf
    mv /etc/samba/smb.conf-backup /etc/samba/smb.conf
    exit 4
fi

echo "kõik korras, teen smbd service'le restardi"
service smbd restart

echo "valmis. kui miskit ei sobi, siis backup asub failis /etc/samba/smb.conf-backup"
