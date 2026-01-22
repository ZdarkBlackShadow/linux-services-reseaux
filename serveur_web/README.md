# Introduction

Je suis partie sur docker parce que c'est plus façile à mettre en place et aussi a nettoyer en cas de problème

Dans le fichier `docker-compose.yml`, il y a 2 services:
- l'application web (app)
- nginx

## L'application web

L'application web est une application de quiz sur le thème des jeux vidéos, elle est dévelopé en **go** et a besoin d'une base de donnée **mysql**. Afin de build l'application web avec **docker**, j'ai fait un `Dockerfile` accompagné d'un fichier **shell** (entrypoint.sh) afin d'éxécuter des command une fois l'application build.

Ce qu'il faut retenir:
- Build de l'application en go dans le Dockefile
- Éxécution des migrations de la base de donnée lorque l'application se build
- Application web éxposé sur le port 8080 en locale (non accesible depuis l'éxtérieur)

Lien de l'applicationn : https://github.com/ZdarkBlackShadow/the-gamers-trial

## Installation de docker 

On télécharge le script d'installation

```bash
curl -fsSL https://get.docker.com -o get-docker.sh
```

on l'éxécute

```bash
sudo sh get-docker.sh
```

on rajoute l'utilisateur actuelle dans le groupe de **docker**

```bash
sudo usermod -aG docker $USER
```

Pour verifier

```bash
docker --version
```

```bash
docker compose version
```

puis on l'active 

```bash
sudo systemctl enable docker
```

```bash
sudo systemctl start docker
```

## Lancer le serveur web

```bash
sudo docker compose up -d --build
```

## Certificat TLS
| ne pas oublier le port 443 à mettre dans le `docker-compose.yml`

on créer un dossier `certs` pour stocker les certificat à l'intérieur du repo
```bash
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout certs/server.key -out certs/server.crt -subj "/C=FR/ST=France/L=Paris/O=Gaming/OU=IT/CN=192.168.200.101"
```

on oublie pas de rajouter cette ligne pour dire à nginx ou sont les certificats
```
- ./certs:/etc/nginx/certs:ro
```

## Load Balancer

Pour le load balancer, comme j'avais déja le Reccord de type A qui pointait sur l'addresse IP de un des serveurs web, je suis parti sur un load balancer maitre esclave (`nginx_master.conf` et `nginx_slave.conf`). Concernant la méthode de load balancing, je suis parti sur **ip_hash** puisque l'application web utilise des sessions en mémoire, ce qui permet que une addresse IP va toujours sur le même serveur web.
