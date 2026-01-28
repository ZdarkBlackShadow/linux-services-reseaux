# 🛡️ Infrastructure Réseau Sécurisée : pfSense sur Proxmox

Ce projet documente le déploiement d'une architecture réseau virtualisée et sécurisée, reposant sur **pfSense** en tant que routeur de bordure et pare-feu principal. L'infrastructure est hébergée sur un hyperviseur **Proxmox VE**.

---

## 🏗️ Architecture du Projet

L'objectif est de segmenter le réseau pour isoler les machines critiques (LAN) d'Internet (WAN) et des zones invitées (LAN2).

### Topologie Réseau (Proxmox Bridges)

* **☁️ WAN (`vmbr0`)** : Pont relié à la carte physique. Connecté à la Box Internet (IP Privée `192.168.10.x`).
* **🔒 LAN (`vmbr1`)** : Réseau interne sécurisé (`192.168.100.0/24`). Isolé physiquement d'Internet.
* **🚧 LAN2 / DMZ (`vmbr2`)** : Zone tampon ou invitée (`192.168.200.0/24`).

### Machines Virtuelles
1.  **pfSense (Gateway)** : Le cœur du réseau. Il possède une patte dans chaque zone (`vtnet0`, `vtnet1`, `vtnet2`).
2.  **VM Client "Alexis"** : Poste d'administration situé dans le LAN sécurisé.

---

## ⚙️ Rôle et Configuration de pfSense

pfSense agit comme la pierre angulaire de la sécurité du réseau.

### 1. Services Réseaux
* **Routage & NAT :** Permet aux VMs privées de sortir sur Internet via une adresse IP unique.
* **DHCP Server :** Distribution automatique des adresses IP sur le LAN (`.100` à `.200`).
* **DNS :** Résolution de noms sécurisée (via Cloudflare `1.1.1.1` et Google `8.8.8.8`).

### 2. Gestion du WAN (Double NAT)
Le pfSense étant derrière une Box Internet, deux réglages spécifiques ont été appliqués pour autoriser le trafic entrant :
* Désactivation du blocage **RFC1918** (Private Networks).
* Désactivation du blocage **Bogon Networks**.

### 3. Politique de Sécurité (Firewall Rules)

Le pare-feu fonctionne sur le principe du **"Default Deny"** (Tout ce qui n'est pas autorisé est interdit).

#### 🟢 Interface LAN (Zone de Confiance)
| Règle | Action | Description |
| :--- | :--- | :--- |
| **Anti-Lockout** | `PASS` | Sécurité système : Garantit l'accès à l'interface d'admin (443/80/22) pour éviter de s'enfermer dehors. |
| **Default Allow** | `PASS` | Autorise le LAN à accéder à **TOUT** (Internet). Le retour est géré automatiquement (Stateful). |

#### 🟠 Interface LAN2 (Zone Isolée)
| Règle | Action | Description |
| :--- | :--- | :--- |
| **Block Admin** | `BLOCK` | 🛑 **Prioritaire.** Interdit l'accès vers le réseau `LAN subnets`. Empêche un invité d'attaquer le réseau privé. |
| **Internet OK** | `PASS` | Autorise l'accès vers `Any` (Internet uniquement, puisque le LAN est bloqué juste avant). |

---

## 💻 Configuration du Client d'Administration

La VM graphique (Debian) située dans le LAN est configurée en **IP Statique** pour garantir l'accès au routeur même en cas de panne du service DHCP.

* **Fichier :** `/etc/network/interfaces`
* **IP :** `192.168.100.50`
* **Gateway :** `192.168.100.1` (pfSense)

---

## 🆘 Commandes de Survie (Troubleshooting)

En cas de problème critique ou de perte d'accès, utiliser ces commandes via la **Console Proxmox**.

### Sur pfSense (Shell - Option 8)
* `pfctl -d` : **Désactiver le pare-feu** (Ouvre tout, permet de reprendre la main).
* `pfctl -e` : Réactiver le pare-feu.
* `/etc/rc.restart_webgui` : Redémarrer le service Web (nginx) s'il a planté.
* `kbdcontrol -l fr.iso.acc` : Passer le clavier en AZERTY.

### Sur le Client (Terminal)
* `ip a` : Vérifier l'adresse IP.
* `ping 192.168.100.1` : Tester la liaison avec le routeur.
* `ping 8.8.8.8` : Tester la sortie Internet (IP).
* `cat /etc/resolv.conf` : Vérifier les serveurs DNS utilisés.

---

**Auteur :** Alexis
**Date :** Janvier 2026
**Version :** 2.0