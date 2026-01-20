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
