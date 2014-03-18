#!/usr/bin/env python
# -*- coding: utf-8 -*-
#
# Leiab sisendfailist pikima rea.
# Gert Vaikre A21
#
from __future__ import print_function
import sys

if len(sys.argv) != 2:
    print("Argumentide arv on vale!")
    print("Kasuta programmi", sys.argv[0], "sisendfail")
    sys.exit(1)

try:
    ifh = open(sys.argv[1], 'r')
except IOError:
    print("Sisendfaili", sys.argv[1], "ei eksisteeri või pole õiguseid")
    sys.exit(2)

massiiv = []

#for line in ifh.readlines():
#    massiiv.append(line)

while True:
    line = ifh.readline()
    if not line:
        break
    massiiv.append(line)
ifh.close()

print(max(massiiv, key=len))
