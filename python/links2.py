#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Gert Vaikre A21
#
# http://www.pythonforbeginners.com/code/regular-expression-re-findall
#
from __future__ import print_function
import sys

import re
import urllib2
    
website = urllib2.urlopen(sys.argv[1])

html = website.read()
    
links = re.findall('<a href=(.*?)[ >]', html)
file=open('lingid.txt', 'w')

for link in links:
    file.write(link)
    file.write("\n")
