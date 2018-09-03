#script d'origine: https://raspberry-pi.developpez.com/cours-tutoriels/projets-rpi-zero/traceur-gps/
import datetime
import time
import serial
import os
import sys
import psycopg2
import psycopg2.extras
import subprocess

from datetime import datetime

firstFixFlag = False # this will go true after the first GPS fix.
firstFixDate = ""
DEBUG = True
SLEEP = 10
# trouver chemin vers usb gps
def get_var(varname): 
    CMD = 'echo $(source /usr/src/app/usb.sh; echo $%s)' % varname
    p = subprocess.Popen(CMD, stdout=subprocess.PIPE, shell=True, executable='/bin/bash')
    return p.stdout.readlines()[0].strip()

# Try to connect
try:
    conn=psycopg2.connect("host='172.24.1.1' port='5432' dbname='geopoppy' user='docker' password='docker'")
    print get_var('USB') #get ttyUSB
    print "Connection DB OK"
    subprocess.call(['stty', '-F',get_var('USB'), '4800']) #do /dev/ttyUSB* on 4800
except:
    print "I am unable to connect to the database."


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

# Main program loop:
print "Start : %s" % time.ctime()
while True:
    
    line = ser.readline()
    if "$GPRMC" in line: # This will exclude other NMEA sentences the GPS unit provides.
        if DEBUG is True: 
            print "GPRMC entering..." + line
        
        try:    
            gpsData = parse_GPRMC(line) # Turn a GPRMC sentence into a Python dictionary called gpsData
        
        except parseerror as error:
            print "!!! Error catched... stopping program "
            print "!!! -------------------------------- !!!! "
            print "!!! Parsing GPRMC error : " + error
            print "Ending at : %s" % time.ctime()
            sys.exit(0)
            

        if gpsData['validity'] == "A": # If the sentence shows that there's a fix, then we can log the line
            if DEBUG is True: 
                print "Writing into database..." 
            
            #cus_date = datetime.strptime(gpsData['fix_date'], "%d%m%Y").date()                
            
            # Data to insert 
            cur = conn.cursor()
            sql = "INSERT INTO trame (dt, latitude, longitude, geom) VALUES ( %s, %s, %s, st_setsrid(st_makepoint(%s,%s), 4326) );"
            cur.execute(sql, (datetime.strptime(' '.join(gpsData['fix_date'],gpsData['fix_time']),'%d%m%y %H%M%S.%f'),str(gpsData['decimal_latitude']),str(gpsData['decimal_longitude']), str(gpsData['decimal_longitude']), str(gpsData['decimal_latitude']) ))
            conn.commit()
            time.sleep( SLEEP )
