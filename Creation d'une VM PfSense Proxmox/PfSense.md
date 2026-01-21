# PfSense

![Pfsense logo](./images/pfsense.png)

Dans le cadre de ce projet de virtualisation sur Proxmox, pfSense agit comme la pierre angulaire du réseau. Il ne s'agit pas simplement d'un logiciel, mais d'une appliance virtuelle de sécurité et de routage basée sur FreeBSD (Packet Filter).

Son rôle est quadruple au sein de notre architecture :
## 1. Segmentation et Isolation Réseau (Edge Router)

pfSense crée une frontière étanche entre deux mondes :

Le WAN (Zone Publique/Physique) : Connecté au réseau de la Box Internet et exposé aux menaces potentielles ou au trafic non contrôlé.

Le LAN (Zone Privée/Virtuelle) : Un réseau totalement isolé (192.168.100.0/24) dédié à nos machines virtuelles. Utilité : Cette segmentation garantit que les VMs ne sont pas directement accessibles depuis le réseau physique, protégeant ainsi l'environnement de production.

## 2. Routage et Translation d'Adresse (NAT)

Puisque nos VMs utilisent un plan d'adressage privé interne, elles ne peuvent pas sortir sur Internet nativement.

Fonction NAT (Network Address Translation) : pfSense masque toutes les adresses IP des VMs derrière sa propre adresse WAN. Il permet ainsi à tout le parc virtuel d'accéder à Internet via une seule IP de sortie.

Routage : Il dirige intelligemment les paquets entre les différents sous-réseaux virtuels.

## 3. Filtrage de Paquets (Firewalling Stateful)

Contrairement à un routeur basique, pfSense inspecte l'état des connexions.

Politique par défaut : Tout ce qui n'est pas explicitement autorisé est interdit.

Contrôle Granulaire : Nous avons défini des règles strictes (ex: Default allow LAN to any) pour contrôler exactement qui a le droit de communiquer avec qui, offrant une sécurité bien supérieure à celle d'une simple Box Internet.

## 4. Gestion des Services Réseaux (Core Network Services)

Il centralise les fonctions vitales pour le fonctionnement du réseau interne, évitant d'avoir à configurer chaque VM manuellement :

Serveur DHCP : Il distribue automatiquement les adresses IP (.100 à .200) aux nouvelles machines qui rejoignent le réseau.

Résolveur DNS : Il assure la traduction des noms de domaine (ex: google.fr) en adresses IP pour l'ensemble du parc, en utilisant des serveurs performants et sécurisés (Cloudflare/Google).