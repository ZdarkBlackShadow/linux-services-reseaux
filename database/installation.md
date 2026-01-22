# Introduction

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

## Instalation de la base de donnée

on lance le contener

```bash
sudo docker compose up -d
```

## vérification

```bash
sudo docker ps -a
```

on voit le contener avec le status qui doit être **UP** et on peut aussi vérifier si le port **3306** est ouvert avec

```bash
ss -tnlp
```

et normalemnt on voit un service qui écoute et qui envoie sur le port `3306` en tcp