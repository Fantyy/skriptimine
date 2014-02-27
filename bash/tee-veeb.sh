#!/bin/bash
#
# Gert Vaikre A21
# Võtab argumendina veebiserveri aadressi ning seadistab
# veebiserveri koos nimelahendusega.
#

export LC_ALL=C

SAIT=$1

if [ $# -ne 1 ]; then
    echo "kasutamine: $0 veebisaidi-nimi"
    echo "näide: $0 www.minuveebisait.ee"
    exit 1
fi

if [ $UID -ne 0 ]; then
    echo "käivita root kasutajana"
    exit 2
fi

if [ $(apt-cache policy apache2 | grep "(none)" | wc -l) -eq 1 ]; then
    echo "apache2 ei ole paigaldatud"
    echo "uuendan repod"
    apt-get update > /dev/null
    echo "paigaldan apache2"
    apt-get install -y apache2 > /dev/null
else
    echo "apache2 on paigaldatud"
fi

if [ $(grep "127.0.0.1 $SAIT" /etc/hosts >/dev/null; echo $?) -eq 0 ]; then
    echo "nimelahendus on juba olemas"
else
    echo "loon nimelahenduse /etc/hosts failis"
    echo "127.0.0.1 $SAIT" >> /etc/hosts
fi

if [ -d "/var/www/$SAIT" ]; then
    echo "kaust /var/www/$SAIT on juba olemas"
    echo "ilmselt on sait juba konfitud, exit"
    exit 3 
else
    echo "teen kausta /var/www/$SAIT"
    mkdir -p "/var/www/$SAIT"
fi

echo "kopin template'i kausta"
sed "s/It works!/$SAIT/" /var/www/index.html > "/var/www/$SAIT/index.html"

echo "tekitan confi faili /etc/apache2/sites-available/$SAIT ja seadistan selle"
sed "s/ServerAdmin webmaster@localhost/ServerAdmin webmaster@$SAIT\n\tServerName $SAIT/" /etc/apache2/sites-available/default > "/etc/apache2/sites-available/$SAIT"

sed -i "s@/var/www@/var/www/$SAIT@" "/etc/apache2/sites-available/$SAIT"

echo "enablen saidi $SAIT"
a2ensite $SAIT

echo "teen sambale reloadi"
service apache2 reload

echo "valmis"
