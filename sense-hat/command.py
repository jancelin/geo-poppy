from sense_hat import SenseHat, ACTION_PRESSED, ACTION_HELD, ACTION_RELEASED
from signal import pause
#from time import sleep
import time
import os
import socket
import urllib

sense = SenseHat()

r = [255, 0, 0] # R pour Red (rouge)
o = [255, 127, 0] # O pour Orange (orange)
y = [255, 255, 0] # Y pour Yellow (jaune)
g = [0, 255, 0]   # G pour Green  (vert)
b = [0, 0, 255]   # B pour Blue   (bleu)
i = [255, 255, 255]  # I pour ???
v = [159, 0, 255] # V pour Violet (violet)
e = [0, 0, 0]     # E pour Empty  (donc eteind... noir)

question_mark = [
e, b, i, b, b, b, b, e,
e, e, b, b, b, b, e, e,
y, y, e, b, b, e, g, g,
y, e, y, e, e, g, e, g,
y, y, y, e, e, g, e, g,
y, e, e, e, e, e, g, g,
y, e, r, e, e, r, e, e,
e, e, e, r, r, e, e, e
]

shutdown = [
e, e, e, e, e, e, e, e,
e, r, e, e, e, r, e, e,
e, e, r, e, r, e, e, e,
e, e, e, r, e, e, e, e,
e, e, r, e, r, e, e, e,
e, r, e, e, e, r, e, e,
e, e, e, e, e, e, e, e,
e, e, e, y, e, o, e, r,
]

reboot = [
e, e, g, g, g, g, e, e,
e, g, e, e, e, e, g, e,
g, e, e, g, g, e, e, g,
g, e, g, e, e, g, e, g,
g, e, g, e, g, e, e, g,
g, e, e, g, g, g, g, e,
e, g, e, e, e, e, e, e,
e, e, g, e, y, e, o, e,
]

docker = [
e, e, e, e, e, e, e, e,
e, e, e, v, e, e, e, e,
e, v, v, v, e, b, b, b,
v, v, v, v, v, e, b, e,
b, b, b, b, b, b, b, e,
b, b, i, b, b, b, b, e,
e, b, b, b, b, b, e, e,
e, e, b, b, b, e, e, e,
]

geopoppy = [
e, e, e, e, e, e, e, e,
e, r, r, r, r, r, e, e,
e, r, r, r, r, r, e, e,
e, e, r, r, r, e, e, e,
e, e, e, g, e, e, e, e,
e, e, e, g, e, e, e, e,
e, e, e, e, g, e, e, e,
e, e, e, e, e, g, e, e,
]

#docker-compose up -d
def pushed_up(event):
    if event.action != ACTION_RELEASED:
        sense.set_pixels(docker)
        os.system("docker-compose -f /home/pirate/docker-compose.yml  up -d")
        time.sleep(8)
        sense.clear()

# Shutdown
def pushed_down(event):
    if event.action != ACTION_RELEASED:
        sense.set_pixels(shutdown)
        os.system("sudo shutdown -h now")
        sense.clear()
        
# Reboot
def pushed_right(event):
    if event.action != ACTION_RELEASED:
		sense.set_pixels(reboot)
		os.system("sudo reboot")

#Get ip
def getNetworkIp():
    s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
    s.setsockopt(socket.SOL_SOCKET, socket.SO_BROADCAST, 1)
    s.connect(('<broadcast>', 0))
    return s.getsockname()[0]

#Show ip
def pushed_left(event):
    if event.action != ACTION_HELD:
        sense.show_message("wifi: black-pearl.local or IP: ")
        sense.show_message(getNetworkIp())
#Memo
def pushed_push(event):
    if event.action != ACTION_PRESSED:
		sense.set_pixels(question_mark)
		time.sleep(2)
		sense.clear()

def refresh():
    sense.clear()
		
sense.set_pixels(geopoppy)
time.sleep(5)
sense.clear()
sense.stick.direction_up = pushed_up
sense.stick.direction_down = pushed_down
sense.stick.direction_left = pushed_left
sense.stick.direction_right = pushed_right
sense.stick.direction_middle = pushed_push
#sense.stick.direction_any = refresh
#refresh()
pause()
