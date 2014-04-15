#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Võtab sisendist IMAP kasutajanimed, salasõnad ja serveri nime. Logib sisse ja tõmbab meilide nimekirja alla
#
# http://yuji.wordpress.com/2011/06/22/python-imaplib-imap-example-with-gmail/
# http://stackoverflow.com/questions/2983647/how-do-you-iterate-through-each-email-in-your-inbox-using-python
#
# Gert Vaikre A21
#

import imaplib
import email
import sys

if len(sys.argv) != 2:
    print "Argumentide arv on vale!"
    print "Kasuta programmi", sys.argv[0], "sisendfail"
    sys.exit(1)

failinimi=sys.argv[1]

try:
    sisend = open(failinimi, 'r')
except IOError:
    print "Sisendfaili", failinimi, "ei eksisteeri või pole õiguseid"
    sys.exit(2)

while True:
    rida = sisend.readline()
    if not rida:
        break
    andmed = rida.split(' ')
    try:
        user = andmed[0]
        psw =  andmed[1]
        server = andmed[2].strip()
    except IndexError:
        print "Viga faili", failinimi, "töötlemisel\n"
        print "Faili näide:"
        print "minukasutajanimi@meil.com minuparool imap.meil.com"
        print "minuteinekasutaja@teinemeil.com minuparool imap.teinemeil.com"
        sys.exit(3)
    try:
        mail = imaplib.IMAP4_SSL(server)
        mail.login(user, psw)
        mail.list()
        mail.select("inbox")
        #result, data = mail.search(None, "ALL")
        #võimalik, et (UNSEEN) on gmaili feature ainult?
        result, data = mail.search(None, "(UNSEEN)")
        meilideID = data[0] 
        print "Kasutaja", user, "@", server, "uute meilide nimekiri"
        print 20*"="
        for number in meilideID.split():
            result, data = mail.fetch(number, "(RFC822)")
            raw_email = data[0][1] 
            email_message = email.message_from_string(raw_email)
            print email_message['Subject']
        print 20*"="
    except Exception, e:
        print "Viga kasutaja", user, "meilide töötlemisel"
        print "Veateade:"
        print e 
        print 20*"="
sisend.close()
