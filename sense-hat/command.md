**Utiliser SENSE HAT pour gérer GéoPoppy**

![gp](https://cloud.githubusercontent.com/assets/6421175/19477013/7c34ac70-953c-11e6-93ea-7f4f46eae5bd.gif)

Ce script vous permet de piloter quelques fonctions de base directement sur le Raspberry Pi avec le joystick du sense-hat. Le résultat de la commande est affiché sur l'afficheur LED.

Fonctions:

* Press: affiche un memo des fonctions
* Haut: Docker-compose up (reconstruction des services BD et websig)
* Droit: Reboot
* Bas: Shutdown
* Gauche: Affiche l'IP

![sensehat](https://cloud.githubusercontent.com/assets/6421175/19476680/bd946978-953a-11e6-9a9e-8cc5e0315c41.png)
![ip](https://cloud.githubusercontent.com/assets/6421175/19476929/051a0964-953c-11e6-9fdd-db5c2fad2e5b.gif)

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
