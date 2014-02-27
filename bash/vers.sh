#!/bin/bash
#
# Gert Vaikre A21
# Ütleb argumendina etteantud paketi versiooninumbri.
#

export LC_ALL=C

PAKETT=$1
VERSIOON=$(apt-cache policy $PAKETT | grep "Installed:" | cut -d":" -f2)
echo $VERSIOON
