# Création d'une Virtual Machine pfSense sur Proxmox

## PfSense

Dans le cadre de ce projet de virtualisation sur Proxmox, pfSense agit comme la pierre angulaire du réseau. Il ne s'agit pas simplement d'un logiciel, mais d'une appliance virtuelle de sécurité et de routage basée sur FreeBSD (Packet Filter).

Son rôle est quadruple au sein de notre architecture :
### 1. Segmentation et Isolation Réseau (Edge Router)

pfSense crée une frontière étanche entre deux mondes :

Le WAN (Zone Publique/Physique) : Connecté au réseau de la Box Internet et exposé aux menaces potentielles ou au trafic non contrôlé.

Le LAN (Zone Privée/Virtuelle) : Un réseau totalement isolé (192.168.100.0/24) dédié à nos machines virtuelles. Utilité : Cette segmentation garantit que les VMs ne sont pas directement accessibles depuis le réseau physique, protégeant ainsi l'environnement de production.

### 2. Routage et Translation d'Adresse (NAT)

Puisque nos VMs utilisent un plan d'adressage privé interne, elles ne peuvent pas sortir sur Internet nativement.

Fonction NAT (Network Address Translation) : pfSense masque toutes les adresses IP des VMs derrière sa propre adresse WAN. Il permet ainsi à tout le parc virtuel d'accéder à Internet via une seule IP de sortie.

Routage : Il dirige intelligemment les paquets entre les différents sous-réseaux virtuels.

### 3. Filtrage de Paquets (Firewalling Stateful)

Contrairement à un routeur basique, pfSense inspecte l'état des connexions.

Politique par défaut : Tout ce qui n'est pas explicitement autorisé est interdit.

Contrôle Granulaire : Nous avons défini des règles strictes (ex: Default allow LAN to any) pour contrôler exactement qui a le droit de communiquer avec qui, offrant une sécurité bien supérieure à celle d'une simple Box Internet.

### 4. Gestion des Services Réseaux (Core Network Services)

Il centralise les fonctions vitales pour le fonctionnement du réseau interne, évitant d'avoir à configurer chaque VM manuellement :

Serveur DHCP : Il distribue automatiquement les adresses IP (.100 à .200) aux nouvelles machines qui rejoignent le réseau.

Résolveur DNS : Il assure la traduction des noms de domaine (ex: google.fr) en adresses IP pour l'ensemble du parc, en utilisant des serveurs performants et sécurisés (Cloudflare/Google).

## Proxmox

Proxmox Virtual Environment (VE) constitue le socle fondamental de notre projet. C'est une plateforme de virtualisation d'entreprise open-source basée sur Debian Linux.

Contrairement à un logiciel que l'on installe sur Windows (comme VirtualBox), Proxmox est un Hyperviseur de Type 1. Cela signifie qu'il s'installe directement sur le matériel physique, sans système d'exploitation intermédiaire, offrant ainsi des performances quasi-natives.

Ses fonctions clés dans notre architecture sont les suivantes :
### 1. Abstraction et Orchestration des Ressources

Proxmox transforme le serveur physique en un pool de ressources logiques (vCPU, vRAM, Stockage virtuel).

Mutualisation : Il nous permet d'exécuter simultanément des systèmes d'exploitation hétérogènes (FreeBSD pour pfSense, Linux Debian pour la VM Client) sur une seule machine physique.

Isolation : Il garantit que si la VM Client plante ou est compromise, cela n'affecte pas le routeur pfSense ni l'hyperviseur lui-même.

### 2. Commutation Virtuelle

C'est le rôle le plus critique pour notre topologie réseau. Proxmox remplace les switchs et les câbles physiques par des Ponts Virtuels (Linux Bridges) :

Gestion du vmbr0 (WAN) : Il fait le pont entre la carte réseau physique du serveur et l'interface WAN de pfSense.

Création du vmbr1 (LAN) : Il agit comme un switch virtuel totalement isolé, connectant le LAN de pfSense à nos VMs internes. C'est grâce à lui que nous pouvons créer un réseau privé invisible depuis l'extérieur.

Création du vmbr2 (LAN2/DMZ) : Il constitue un second switch virtuel interne, strictement séparé du vmbr1. Il permet de segmenter le réseau pour isoler des zones sensibles ou des invités (DMZ), garantissant qu'une machine compromise sur ce réseau ne puisse pas attaquer le LAN principal.

### 3. Gestion Unifiée et Out-of-Band Management

Proxmox fournit les outils indispensables à la maintenance que nous avons utilisés tout au long du projet :

Accès Console (VNC) : Il permet d'accéder à l'écran des VMs même lorsque le réseau est coupé (indispensable lors de nos pannes de configuration pfSense).

Gestion du Cycle de Vie : Démarrage, arrêt et redémarrage forcé des machines virtuelles.

### 4. Résilience et Sécurité (Snapshots)

Il apporte une couche de sécurité opérationnelle essentielle :

Snapshots (Instantanés) : Avant chaque modification critique (ajout de VPN, changement de règles pare-feu), Proxmox nous permet de figer l'état exact de la VM. En cas d'erreur de configuration, le retour en arrière (Rollback) est instantané, garantissant la continuité de service.
