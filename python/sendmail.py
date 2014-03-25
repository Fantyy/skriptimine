#!/usr/bin/env python
# -*- coding: utf-8 -*-
# Gert Vaikre A21

from __future__ import print_function
import smtplib

s = smtplib.SMTP('172.16.0.160',25)
s.sendmail('gert.vaikre@itcollege.ee', 'margus.ernits@itcollege.ee', open('asdasd.py', 'r').read())
s.quit()
