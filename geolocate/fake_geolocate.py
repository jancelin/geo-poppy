#!/usr/bin/env python2
# -*- coding: utf-8 -*-
# Source https://github.com/tobe/python-utils/blob/master/geolocation.py

import SocketServer # We need this in order to emulate a server
import json # This is used to parse JSON

class MyTCPHandler(SocketServer.BaseRequestHandler):

    latitude    = '51.271904' # latitude
    longtitude  = '30.226622' # longtitude
    accuracy    = '19.50' # accuracy, in meters.

    def handle(self):
        # Get the JSON data...return the ESSIDS (their respective MAC addresses and the signal strength)
        # self.data = json.loads(self.request.recv(1024).strip())
        self.data = self.request.recv(1024).strip()
        print '=== Got something from ' + self.client_address[0] + ' ==='
        print self.data # Print it out I guess...just to note it's been received
        print '\n\n\n=== SENDING SPOOFED DATA TO ALL CLIENTS ===\n'

        self.request.sendall(json.dumps({'location': {'lat': self.latitude, 'lng': self.longtitude}, 'accuracy': self.accuracy}))
        print json.dumps({'location': {'lat': self.latitude, 'lng': self.longtitude}, 'accuracy': self.accuracy})

        print '\n=== DID IT WORK? ;-) ==='

if __name__ == '__main__':
    # Just bind it.
    server = SocketServer.TCPServer(("", 1950), MyTCPHandler) # 1950 TORCIDA HAJDUK

    print '=== WE ARE LIVE ==='

    # Forever yours, of course until you bash ^C
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        exit('^C received, exiting...')
