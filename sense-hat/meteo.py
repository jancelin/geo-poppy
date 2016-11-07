from sense_hat import SenseHat

sense = SenseHat()

sense.show_message("T:%s " % round(sense.temp,1))
sense.show_message("H:%s " % round(sense.humidity,1))
sense.show_message("P:%s " % round(sense.pressure,1))
