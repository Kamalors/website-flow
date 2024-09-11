
# Installation de Zabbix avec Docker et Docker Compose (avec MariaDB)

## Pré-requis

1. **Docker** et **Docker Compose** doivent être installés sur votre machine.
   - [Installer Docker](https://docs.docker.com/get-docker/)
   - [Installer Docker Compose](https://docs.docker.com/compose/install/)

## Étapes de mise en place de Zabbix avec Docker et Docker Compose

### 1. Créer un fichier `docker-compose.yml`

Créez un fichier nommé `docker-compose.yml` et ajoutez-y le contenu suivant pour configurer Zabbix avec MariaDB comme serveur de base de données :

```yaml
version: '3.5'

services:
  db:
    image: mariadb:latest
    environment:
      MYSQL_DATABASE: 'zabbix'
      MYSQL_USER: 'zabbix'
      MYSQL_PASSWORD: 'Azerty1*'
      MYSQL_ROOT_PASSWORD: 'Azerty1*'
    volumes:
      - ./zabbix_db_data:/var/lib/mysql
    networks:
      - zabbix-net

  zabbix-server:
    image: zabbix/zabbix-server-mysql:alpine-7.0-latest
    environment:
      DB_SERVER_HOST: 'db'
      MYSQL_DATABASE: 'zabbix'
      MYSQL_USER: 'zabbix'
      MYSQL_PASSWORD: 'Azerty1*'
    volumes:
      - ./zabbix_server_conf:/etc/zabbix/zabbix_server.conf.d
    depends_on:
      - db
    ports:
      - "10051:10051"
    networks:
      - zabbix-net

  zabbix-web:
    image: zabbix/zabbix-web-apache-mysql:alpine-7.0-latest
    environment:
      ZBX_SERVER_HOST: 'zabbix-server'
      DB_SERVER_HOST: 'db'
      MYSQL_DATABASE: 'zabbix'
      MYSQL_USER: 'zabbix'
      MYSQL_PASSWORD: 'Azerty1*'
      PHP_TZ: 'Europe/Paris'
    ports:
      - "8080:8080"
    depends_on:
      - zabbix-server
    networks:
      - zabbix-net

  zabbix-agent:
    image: zabbix/zabbix-agent:alpine-7.0-latest
    environment:
      ZBX_SERVER_HOST: 'zabbix-server'
    ports:
      - "10050:10050"
    networks:
      - zabbix-net

networks:
  zabbix-net:
    driver: bridge
```

### 2. Lancer les services avec Docker Compose

Dans le dossier où vous avez créé le fichier `docker-compose.yml`, lancez la commande suivante pour démarrer les services :

```bash
docker-compose up -d
```

### 3. Accéder à l'interface web de Zabbix

Une fois les services démarrés, ouvrez un navigateur web et accédez à l'URL suivante :

```
http://<Adresse_IP_hôte>:8080
```

#### Configuration initiale

1. Sélectionnez la langue **Français**.
2. Utilisez les informations suivantes pour la configuration de la base de données :
   - **Serveur de base de données** : `db`
   - **Utilisateur** : `zabbix`
   - **Mot de passe** : `Azerty1*`
   - **Nom de la base de données** : `zabbix`
3. Continuez en suivant les étapes d'installation.

### 4. Vérifier l'installation

- **Vérifiez que les conteneurs sont en cours d'exécution** :

  ```bash
  docker ps
  ```

- **Vérifiez les logs des conteneurs** :

  ```bash
  docker-compose logs -f
  ```

### 5. Installation de l'agent Zabbix sur un client Linux

Pour installer un agent Zabbix sur un client Linux, exécutez les commandes suivantes :

```bash
wget https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_7.0-1+ubuntu24.04_all.deb
dpkg -i zabbix-release_7.0-1+ubuntu24.04_all.deb
apt update
apt install zabbix-agent
```

Modifiez le fichier de configuration de l'agent pour pointer vers l'IP du serveur Zabbix :

```bash
nano /etc/zabbix/zabbix_agentd.conf
# Modifier la ligne suivante
Server=<IP_du_serveur_zabbix>
```

Redémarrez l'agent et activez-le au démarrage :

```bash
systemctl restart zabbix-agent
systemctl enable zabbix-agent
```

### 6. Gestion des conteneurs

- **Arrêter les services** :

  ```bash
  docker-compose down
  ```

- **Redémarrer les services** :

  ```bash
  docker-compose restart
  ```
