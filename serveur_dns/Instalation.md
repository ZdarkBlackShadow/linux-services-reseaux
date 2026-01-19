# Installation de technicium

Machine virtuele debian

## Config
- ISO debian 13
- 2 GB de RAM
- 20 G de stockage

## Config réseau 

![config réseau](/serveur_dns/img/image.png)

![alt text](image.png)

## Installation

Liens de la doc : 
- https://technitium.com/dns/
- https://blog.technitium.com/2017/11/running-dns-server-on-ubuntu-linux.html

Commande : 
- commande pour installer 
```bash
curl -sSL https://download.technitium.com/dns/install.sh | sudo bash
```

![alt text](image.png)


On configure une zone : `darscayailin.local`
Puis  on rajoute un RECORD de type A (addresse ipv4) avec l'addresse ip du serveur web puis on test

exemple :

```
curl -v http://darscayailin.local
```

