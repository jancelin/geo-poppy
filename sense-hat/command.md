**Utiliser SENSE HAT pour gérer GéoPoppy**

Ce script vous permet de piloter quelques fonctions de base directement sur le Raspberry Pi avec le joystick du sense-hat, le résultat de la commande est affiché sur l'afficheur LED.

Fonction

* Press: affiche un memo des fonctions
* Droit: Reboot
* Bas: Shutdown
* Haut: Docker-compose up (reconstruction des services BD et websig)
* Gauche: Affiche l'IP

------------------------------------------

* 1. Acheter un Sense Hat et le brancher sur le pi3

https://www.raspberrypi.org/products/sense-hat/

* 2. Installer sensehat

```
sudo apt-get update
sudo apt-get install sense-hat
sudo reboot
```

* 3. Récupérer le command.py, le coller dans /home/pirate et attribuer droits d'exécution

```
sudo wget --no-check-certificate -P /home/pirate https://raw.githubusercontent.com/jancelin/geo-poppy/master/sense-hat/command.py
sudo chmod +x /home/pirate/command.py
```

* 4. Editer le /etc/rc.local pour lancer le command.py au démarrage

```
sudo nano /etc/rc.local
```

>Rajouter avant le exit0

```
python /home/pirate/sensehat/shutdown.py
```

* 5. Redémarrer

```.
sudo reboot
```
