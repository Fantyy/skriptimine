#!/bin/bash
#
# Gert Vaikre A21
# Loeb logi failist välja unikaalsed IP-d ja üritab need
# kõik ka ära lahendada.
#


AADRESSID=$(grep NEVE robot.itcollege.ee-access.log | cut -d" " -f1 | sort -u)

for i in $AADRESSID; do
    host $i
done

