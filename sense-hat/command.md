**Utiliser SENSE HAT pour gérer GéoPoppy**

* Acheter un Sense Hat et le brancher sur le pi3

https://www.raspberrypi.org/products/sense-hat/

* Installer sensehat

```
sudo apt-get update
sudo apt-get install sense-hat
sudo reboot
```

* Récupérer le command.py, le coller dans /home/pirate et attribuer droits d'exécution

```
sudo wget --no-check-certificate -P /home/pirate https://raw.githubusercontent.com/jancelin/geo-poppy/master/sense-hat/command.py
sudo chmod +x /home/pirate/command.py
```

* Editer le 
