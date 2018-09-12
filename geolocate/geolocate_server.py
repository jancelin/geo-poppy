#script d'origine: https://raspberry-pi.developpez.com/cours-tutoriels/projets-rpi-zero/traceur-gps/
import datetime
import time
import serial
import os
import sys
import subprocess
import SocketServer # We need this in order to emulate a server
import json # This is used to parse JSON

from datetime import datetime

class MyTCPHandler(SocketServer.BaseRequestHandler):

    firstFixFlag = False # this will go true after the first GPS fix.
    firstFixDate = ""
    DEBUG = True
    SLEEP = 1
    # trouver chemin vers usb gps
    def get_var(varname): 
        CMD = 'echo $(source /usr/src/app/usb.sh; echo $%s)' % varname
        p = subprocess.Popen(CMD, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
        return p.stdout.readlines()[0].strip()

    # Try to connect
    try:
        print get_var('USB') #get ttyUSB
        subprocess.call(['stty', '-F',get_var('USB'), '4800']) #do /dev/ttyUSB* on 4800
    except:
        print "I am unable to connect to GNNS recever."


    # Set up serial:
    ser = serial.Serial(
        port=get_var('USB'),\
        baudrate=4800,\
        parity=serial.PARITY_NONE,\
        stopbits=serial.STOPBITS_ONE,\
        bytesize=serial.EIGHTBITS,\
        timeout=1)

    # Helper function to take HHMM.SS, Hemisphere and make it decimal:
    def degrees_to_decimal(data, hemisphere):
        try:
            decimalPointPosition = data.index('.')
            degrees = float(data[:decimalPointPosition-2])
            minutes = float(data[decimalPointPosition-2:])/60
            output = degrees + minutes
            if hemisphere is 'N' or hemisphere is 'E':
                return output
            if hemisphere is 'S' or hemisphere is 'W':
                return -output
        except:
            return ""

    # Helper function to take a $GPRMC sentence, and turn it into a Python dictionary.
    # This also calls degrees_to_decimal and stores the decimal values as well.
    def parse_GPRMC(data):
        data = data.split(',')
        dict = {
                # $GPRMC,161854.000,
                'fix_time': data[1],
                'validity': data[2],
                'latitude': data[3],
                'latitude_hemisphere' : data[4],
                'longitude' : data[5],
                'longitude_hemisphere' : data[6],
                'speed': data[7],
                'true_course': data[8],
                'fix_date': data[9],
                'variation': data[10],
                'variation_e_w' : data[11],
                'checksum' : data[12]
        }
        dict['decimal_latitude'] = degrees_to_decimal(dict['latitude'], dict['latitude_hemisphere'])
        dict['decimal_longitude'] = degrees_to_decimal(dict['longitude'], dict['longitude_hemisphere'])
        return dict
        
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

if __name__ == '__main__':
    # Just bind it.
    server = SocketServer.TCPServer(("", 1950), MyTCPHandler) # 1950 TORCIDA HAJDUK

    print '=== WE ARE LIVE ==='

    # Forever yours, of course until you bash ^C
    try:
        server.serve_forever()
    except KeyboardInterrupt:
        exit('^C received, exiting...')
   
            

