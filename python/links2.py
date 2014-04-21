#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Võtab sisendist URLi ja leiab sealt lehelt kõik lingid ning prindib need
# välja.
#
# Väljundi faili saamiseks võib kasutada suunamist.
#
# Gert Vaikre A21
#
# http://www.pythonforbeginners.com/code/regular-expression-re-findall
#

import sys
import re
import urllib2

if len(sys.argv) != 2:                                                          
    print "Argumentide arv on vale!"                                            
    print "Kasuta programmi", sys.argv[0], "URL"                         
    sys.exit(1)

aadress = sys.argv[1]

try:    
    veebileht = urllib2.urlopen(aadress)
except ValueError:
    print "URL ei ole õigel kujul."
    print "Kasutamise näide:"
    print sys.argv[0], "http://www.itcollege.ee"
    sys.exit(2)

html = veebileht.read()
lingid = re.findall('<a href=(.*?)[ >]', html)

for link in lingid:
    print link.replace('"', '')
