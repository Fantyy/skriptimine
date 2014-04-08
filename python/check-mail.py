#!/usr/bin/env python
# -*- coding: utf-8 -*-

# Võtab sisendist IMAP kasutajanimed, salasõnad ja serveri nime. Logib sisse ja kontrollib kas on uut posti (tõmbab meilide nimekirja alla)
#
# http://yuji.wordpress.com/2011/06/22/python-imaplib-imap-example-with-gmail/
# http://stackoverflow.com/questions/2983647/how-do-you-iterate-through-each-email-in-your-inbox-using-python
# http://stackoverflow.com/questions/13210737/get-only-new-emails-imaplib-and-python
#
# pooleli

import imaplib
import email

sisend = open('post.txt', 'r')

while True:
    rida = sisend.readline()
    if not rida:
        break
    andmed = rida.split(' ')
    user = andmed[0]
    psw =  andmed[1]
    server = andmed[2].strip()
    mail = imaplib.IMAP4_SSL(server)
    mail.login(user, psw)
    mail.list()
    mail.select("inbox")
    result, data = mail.search(None, "ALL")
    meilideID = data[0] 

    for number in meilideID.split():
        result, data = mail.fetch(number, "(RFC822)")
        raw_email = data[0][1] 
        email_message = email.message_from_string(raw_email)
        result, data = mail.store(number,'-FLAGS','\\Seen')
        if ret == 'OK':
            print email_message['Subject']
sisend.close()
