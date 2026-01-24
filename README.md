DOCUMENTATION GRAFANA

Mise à jour du système

apt update

Paquets de base

apt install -y sudo curl ca-certificates gnupg nftables ufw fail2ban

mkdir -p /etc/apt/keyrings
curl -fsSL https://apt.grafana.com/gpg.key | gpg --dearmor -o /etc/apt/keyrings/grafana.gpg
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" > /etc/apt/sources.list.d/grafana.list
apt update

Installation Grafana

apt install -y grafana

Activation et démarrage du service

systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server

Vérifications

systemctl status grafana-server
ss -tulnp | grep 3000

Accès à Grafana

http://IP_GRAFANA:3000

Identifiants défaut

Utilisateur : admin
Mot de passe : admin

Intégration Prometheus

URL datasource Prometheus :
http://IP_PROMETHEUS:9090

DOCUMENTATION PROMETHEUS

Création de l’utilisateur et des dossiers

mkdir /etc/prometheus
mkdir /var/lib/prometheus
chown prometheus:prometheus /etc/prometheus /var/lib/prometheus

Téléchargement et installation de Prometheus

cd /tmp
curl -LO https://github.com/prometheus/prometheus/releases/download/v2.52.0/prometheus-2.52.0.linux-amd64.tar.gz

tar xvf prometheus-2.52.0.linux-amd64.tar.gz
cp prometheus-2.52.0.linux-amd64/prometheus /usr/local/bin/
cp prometheus-2.52.0.linux-amd64/promtool /usr/local/bin/
cp -r prometheus-2.52.0.linux-amd64/consoles /etc/prometheus/
cp -r prometheus-2.52.0.linux-amd64/console_libraries /etc/prometheus/

Configuration Prometheus

nano /etc/prometheus/prometheus.yml

Contenu du fichier prometheus.yml

global:
scrape_interval: 15s

scrape_configs:

job_name: "prometheus"
static_configs:

targets:

"localhost:9090"

Permissions

chown -R prometheus:prometheus /etc/prometheus
chown prometheus:prometheus /usr/local/bin/prometheus /usr/local/bin/promtool

Service systemd

nano /etc/systemd/system/prometheus.service

Contenu du service

[Unit]
Description=Prometheus
After=network-online.target
Wants=network-online.target

[Service]
User=prometheus
Group=prometheus
ExecStart=/usr/local/bin/prometheus \
--config.file=/etc/prometheus/prometheus.yml \
--storage.tsdb.path=/var/lib/prometheus

[Install]
WantedBy=multi-user.target

Activation et démarrage

systemctl daemon-reload
systemctl enable prometheus
systemctl start prometheus

Vérifications

promtool check config /etc/prometheus/prometheus.yml
ss -tulnp | grep 9090
