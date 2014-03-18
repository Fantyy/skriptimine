#!/usr/bin/env python
# -*- coding: utf-8 -*-

import sys
from __future__import print

print("Argumentide arv on:", len(sys.argv))

for arg in sys.argv:
    print("Argument:", arg)

print("programm lõpetas töö")
