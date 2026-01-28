# Guide de Dépannage (Troubleshooting)

Ce guide regroupe les solutions aux problèmes les plus fréquents rencontrés lors de la configuration de l'infrastructure pfSense sur Proxmox.

---

## 1. Dépannage : Console pfSense (Shell)
*Problèmes survenant directement sur l'écran noir (console) de la VM pfSense.*

| Symptôme | Cause / Diagnostic | Solution / Commande à taper (Option 8 Shell) |
| :--- | :--- | :--- |
| **Clavier en QWERTY** | Impossible de taper les caractères spéciaux (`/`, `-`, `a/q`). | `kbdcontrol -l fr.iso.acc` |
| **Interface Web Inaccessible** | Le navigateur charge dans le vide alors que le ping fonctionne. Pare-feu bloqué. | 1. `pfctl -d` (Désactive temporairement le pare-feu).<br>2. Réessayer l'accès Web.<br>3. `pfctl -e` pour réactiver après config. |
| **Service Web planté** | Le serveur web (nginx) ne répond plus. | `/etc/rc.restart_webgui` |
| **Vérifier le service Web** | On ne sait pas si le serveur web tourne. | `sockstat -4 -l` (Chercher la ligne `nginx` sur le port `:80` ou `:443`). |
| **Disque Plein** | Le WebGUI ne démarre pas, erreurs d'écriture. | `df -h` (Si la partition `/` est à 100%, vider les logs ou réinstaller). |
| **Erreur PHP/Config** | Message "Fatal Error" au démarrage. | Dans le menu console (pas le shell), choisir l'**Option 11** (Restart WebConfigurator) ou **Option 16** (Restart PHP-FPM). |

---

## 2. Dépannage : Client VM (Debian/Linux)
*Problèmes de connectivité depuis la machine d'administration.*

| Symptôme | Cause Probable | Solution |
| :--- | :--- | :--- |
| **Ping 192.168.100.1 échoue** | 1. Mauvais pont virtuel.<br>2. Cache réseau corrompu. | 1. Vérifier dans Proxmox que la carte réseau est sur `vmbr1`.<br>2. `ip addr flush dev ens18` puis `systemctl restart networking`. |
| **"Destination Host Unreachable"** | Problème de câblage virtuel ou d'IP. | Vérifier avec `ip a` que l'IP est bien dans le sous-réseau `192.168.100.x` et que l'interface est UP. |
| **Erreur "Job for networking.service failed"** | Erreur de syntaxe dans `/etc/network/interfaces`. | Vérifier le fichier : pas d'espace manquant (ex: `inetdhcp` est faux), fautes de frappe. Utiliser `systemctl status networking.service` pour voir l'erreur. |
| **Internet KO mais Ping 8.8.8.8 OK** | Problème de DNS (Résolution de noms). | Vérifier `/etc/resolv.conf`. Ajouter temporairement `nameserver 1.1.1.1`. Configurer les DNS dans l'interface pfSense. |
| **"Connection Refused" (Web)** | Le serveur pfSense refuse la connexion (port fermé ou service éteint). | Vérifier si pfSense est allumé. Vérifier via la console pfSense si le WebGUI est actif. |
| **Navigateur n'accède pas au GUI** | Problème HTTPS/HSTS ou Cache. | Utiliser la **Navigation Privée**. Vérifier si l'URL est bien `http://...` ou `https://...`. |

---

## 3. Dépannage : Interface Web pfSense (GUI)
*Problèmes une fois connecté à l'interface graphique.*

| Symptôme | Solution |
| :--- | :--- |
| **"Potential DNS Rebind attack detected"** | Vous essayez d'accéder au GUI via un nom de domaine non reconnu ou depuis le WAN. Utilisez strictement l'IP `192.168.100.1` pour administrer. |
| **Lenteur extrême chargement pages** | Souvent un problème de résolution DNS inverse du pfSense. Aller dans **System > General Setup** et décocher *"Allow DNS server list to be overridden"*. |
| **Accès bloqué après modif Pare-feu** | Vous vous êtes enfermé dehors ? Allez sur la **Console Proxmox**, tapez `pfctl -d` pour désactiver le filtrage, connectez-vous au Web, corrigez la règle, et réactivez. |

---

## 4. Dépannage : LAN2 / DMZ (Réseau Secondaire)

| Symptôme | Cause Probable | Solution |
| :--- | :--- | :--- |
| **Les VMs sur LAN2 n'ont pas d'IP** | Serveur DHCP inactif ou mauvais bridge. | 1. Vérifier que la VM est sur `vmbr2`.<br>2. Vérifier dans **Services > DHCP Server > LAN2** que la case "Enable" est cochée. |
| **IP obtenue, mais pas d'Internet** | Manque de règle Firewall (Deny All par défaut). | Vérifier dans **Firewall > Rules > LAN2** qu'il existe une règle *"Pass / Source: LAN2 net / Dest: Any"*. |
| **Impossible de pinger 192.168.200.1** | Interface désactivée. | Vérifier dans **Interfaces > LAN2** que la case "Enable Interface" est bien cochée. |

---

## 5. Commandes de Survie (Mémo Rapide)

### Sur pfSense (Shell)
```bash
pfctl -d                  # Ouvre tout (Désactive le pare-feu)
pfctl -e                  # Réactive le pare-feu
/etc/rc.restart_webgui    # Relance l'interface Web
killall -9 php-fpm; killall -9 nginx  # Tue les processus web plantés
```

### Sur client Linux 
```bash
ip a                      # Voir son IP
ip route                  # Voir la passerelle (Gateway)
cat /etc/resolv.conf      # Voir les DNS
ping 8.8.8.8              # Test connectivité IP
ping google.fr            # Test connectivité DNS
```