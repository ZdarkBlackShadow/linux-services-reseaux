# Introduction

technitium est open source et simple à mette en place grâce à l'interface web.

# Installation

Liens de la doc : 
- https://technitium.com/dns/
- https://blog.technitium.com/2017/11/running-dns-server-on-ubuntu-linux.html

Commande : 
- commande pour installer 
```bash
curl -sSL https://download.technitium.com/dns/install.sh | sudo bash
```

# Configuration

![config réseau](/serveur_dns/img/image.png)

On configure une zone : `branquignoles.com`
Puis  on rajoute un RECORD de type A (addresse ipv4) avec l'addresse ip du serveur web puis on test le dns:

Vérifier que le serveur dns fonctionne bien

```bash
dig branquignoles.com @addresse IP du serveur dns
```

si le serveur web est déja mis en place :

```bash
curl -v http://branquignoles.com
```
