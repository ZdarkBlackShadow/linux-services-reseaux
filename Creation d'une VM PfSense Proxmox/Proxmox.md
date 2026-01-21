# 🚀 Proxmox

![Proxmox logo](./images/proxmox.png)

Proxmox Virtual Environment (VE) constitue le socle fondamental de notre projet. C'est une plateforme de virtualisation d'entreprise open-source basée sur Debian Linux.

Contrairement à un logiciel que l'on installe sur Windows (comme VirtualBox), Proxmox est un Hyperviseur de Type 1. Cela signifie qu'il s'installe directement sur le matériel physique, sans système d'exploitation intermédiaire, offrant ainsi des performances quasi-natives.

Ses fonctions clés dans notre architecture sont les suivantes :
## 1. Abstraction et Orchestration des Ressources

Proxmox transforme le serveur physique en un pool de ressources logiques (vCPU, vRAM, Stockage virtuel).

Mutualisation : Il nous permet d'exécuter simultanément des systèmes d'exploitation hétérogènes (FreeBSD pour pfSense, Linux Debian pour la VM Client) sur une seule machine physique.

Isolation : Il garantit que si la VM Client plante ou est compromise, cela n'affecte pas le routeur pfSense ni l'hyperviseur lui-même.

## 2. Commutation Virtuelle

C'est le rôle le plus critique pour notre topologie réseau. Proxmox remplace les switchs et les câbles physiques par des Ponts Virtuels (Linux Bridges) :

Gestion du vmbr0 (WAN) : Il fait le pont entre la carte réseau physique du serveur et l'interface WAN de pfSense.

Création du vmbr1 (LAN) : Il agit comme un switch virtuel totalement isolé, connectant le LAN de pfSense à nos VMs internes. C'est grâce à lui que nous pouvons créer un réseau privé invisible depuis l'extérieur.

Création du vmbr2 (LAN2/DMZ) : Il constitue un second switch virtuel interne, strictement séparé du vmbr1. Il permet de segmenter le réseau pour isoler des zones sensibles ou des invités (DMZ), garantissant qu'une machine compromise sur ce réseau ne puisse pas attaquer le LAN principal.

## 3. Gestion Unifiée et Out-of-Band Management

Proxmox fournit les outils indispensables à la maintenance que nous avons utilisés tout au long du projet :

Accès Console (VNC) : Il permet d'accéder à l'écran des VMs même lorsque le réseau est coupé (indispensable lors de nos pannes de configuration pfSense).

Gestion du Cycle de Vie : Démarrage, arrêt et redémarrage forcé des machines virtuelles.

## 4. Résilience et Sécurité (Snapshots)

Il apporte une couche de sécurité opérationnelle essentielle :

Snapshots (Instantanés) : Avant chaque modification critique (ajout de VPN, changement de règles pare-feu), Proxmox nous permet de figer l'état exact de la VM. En cas d'erreur de configuration, le retour en arrière (Rollback) est instantané, garantissant la continuité de service.
