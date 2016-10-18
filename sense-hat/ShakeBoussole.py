from sense_hat import SenseHat
import time
import sys

sense = SenseHat()

led_loop = [4, 5, 6, 7, 15, 23, 31, 39, 47, 55, 63, 62, 61, 60, 59, 58, 57, 56, 48, 40, 32, 24, 16, 8, 0, 1, 2, 3]

sense = SenseHat()
sense.set_rotation(0)
sense.clear()

prev_x = 0
prev_y = 0

led_degree_ratio = len(led_loop) / 360.0

while True:
    x, y, z = sense.get_accelerometer_raw().values()

    x = abs(x)
    y = abs(y)
    z = abs(z)

    if x > 1 or y > 1 or z > 1:
		
        while True:
            dir = sense.get_compass()
            dir_inverted = 180 - dir  # So LED appears to follow North
            led_index = int(led_degree_ratio * dir_inverted)
            offset = led_loop[led_index]
            y = offset // 8  # row
            x = offset % 8  # column
            if x != prev_x or y != prev_y:
                sense.set_pixel(prev_x, prev_y, 0, 0, 0)

                sense.set_pixel(x, y, 0, 0, 255)

                prev_x = x
                prev_y = y

    else:
        sense.clear()
    time.sleep(2)

sense.stick.direction_middle = sense.clear()
