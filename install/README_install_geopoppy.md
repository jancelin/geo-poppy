**Géopoppy installation simple et démo pour Raspberry Pi 3**

![geo-poppy](https://cloud.githubusercontent.com/assets/6421175/7859239/41d9eaa6-053f-11e5-93d1-2056c6cff733.png)



* préparer la SD sous Linux

* Insérer la carte Micro SD dans le PC

* télécharger l'OS Hypriot 32bits: Raspbian + Docker (http://blog.hypriot.com/downloads/) ou 64bits https://github.com/DieterReuter/image-builder-rpi64/releases/

* Flasher raspbian jessie sur une Micro SD avec ETCHER: https://etcher.io/
* insère la sd dans le raspberry
* connecter l'ethernet
* allume.
* connection en ssh:

```
ssh pirate@black-pearl.local
```
ou 

```
ssh pirate@"ton ip"
```

> mot de passe : hypriot

----------------------

* install GeoPoppy:

32bits:

```
sudo -s

curl -fsSL https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy_32bits.sh | sh

```
64bits:

```
sudo -s

curl -fsSL https://raw.githubusercontent.com/jancelin/geo-poppy/master/install/auto_install_geopoppy_64bits.sh | sh

```

* c'est presque fini, un message à la fin (env 15 min):

* enfin redémarrer le raspberry pour activer le wifi direct
```
sudo reboot
```

________________________________________________________________________________

Amusez-vous bien. Et faites remonter les bugs...

