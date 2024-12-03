#!/bin/bash

# Chemins par défaut
NFT_CONFIG="/etc/nftables.conf"
BACKUP_DIR="/var/backups/nftables"

# Vérifier les permissions root
if [[ $EUID -ne 0 ]]; then
    echo "Ce script doit être exécuté en tant que root."
    exit 1
fi

# Crée le répertoire de sauvegarde si nécessaire
mkdir -p "$BACKUP_DIR"

# Fonction pour afficher le menu
function show_menu() {
    echo "=== Gestion des règles nftables ==="
    echo "1) Ajouter des règles prédéfinies"
    echo "2) Ajouter une règle manuelle"
    echo "3) Lister les règles"
    echo "4) Supprimer une règle"
    echo "5) Sauvegarder la configuration"
    echo "6) Restaurer une configuration"
    echo "7) Quitter"
    echo "==================================="
    echo -n "Choix : "
}

# Ajouter des règles prédéfinies
function add_predefined_rules() {
    echo "=== Ajouter des règles prédéfinies ==="
    echo "1) Deny All (Refuser tout le trafic)"
    echo "2) Autoriser SSH (port 22)"
    echo "3) Autoriser HTTP/HTTPS (ports 80, 443)"
    echo "4) Autoriser ICMP "
    echo "======================================="
    echo -n "Choix : "
    read choice

    case $choice in
        1)
            nft add rule inet filter input drop
            echo "Règle 'Deny All' ajoutée."
            ;;
        2)
            echo -n "Entrez l'adresse IP à autoriser pour SSH : "
            read ip
            nft add rule inet filter input ip saddr $ip tcp dport 22 accept
            echo "Règle SSH ajoutée pour l'IP $ip."
            ;;
        3)
            echo -n "Entrez l'adresse IP à autoriser pour HTTP/HTTPS : "
            read ip
            nft add rule inet filter input ip saddr $ip tcp dport {80, 443} accept
            echo "Règles HTTP/HTTPS ajoutées pour l'IP $ip."
            ;;

        4)
            echo -n "Entrez l'adresse IP à autoriser pour ICMP : "
            read ip
            nft add rule inet filter input ip protocol icmp accept
            echo "Règle ICMP ajoutée pour autoriser les paquets ICMP."
            ;;

        *)
            echo "Choix invalide."
            ;;
    esac
}

# Ajouter une règle manuelle
function add_manual_rule() {
    echo "Entrez la règle nftables manuelle (ex : 'add rule inet filter input ip saddr 192.168.1.1 drop') :"
    read rule
    nft $rule
    echo "Règle ajoutée : $rule"
}

# Lister les règles
function list_rules() {
    nft list ruleset
}

# Supprimer une règle
function delete_rule() {
    echo "Entrez la chaîne contenant la règle à supprimer (ex : 'inet filter input') :"
    read chain
    echo "Entrez le numéro de la règle à supprimer (numéro dans nft list ruleset) :"
    read rule_num
    nft delete rule $chain handle $rule_num
    echo "Règle supprimée de $chain, handle $rule_num."
}

# Sauvegarder la configuration
function backup_config() {
    local backup_file="$BACKUP_DIR/nftables_$(date +%Y%m%d_%H%M%S).conf"
    nft list ruleset > "$backup_file"
    echo "Sauvegarde effectuée dans $backup_file."
}

# Restaurer la configuration
function restore_config() {
    echo "=== Sauvegardes disponibles ==="
    ls -1 "$BACKUP_DIR"
    echo "==============================="
    echo -n "Entrez le nom du fichier de sauvegarde à restaurer : "
    read backup_file

    if [[ -f "$BACKUP_DIR/$backup_file" ]]; then
        nft -f "$BACKUP_DIR/$backup_file"
        echo "Configuration restaurée depuis $backup_file."
    else
        echo "Fichier de sauvegarde introuvable."
    fi
}

# Boucle principale
while true; do
    show_menu
    read choice

    case $choice in
        1)
            add_predefined_rules
            ;;
        2)
            add_manual_rule
            ;;
        3)
            list_rules
            ;;
        4)
            delete_rule
            ;;
        5)
            backup_config
            ;;
        6)
            restore_config
            ;;
        7)
            echo "Au revoir !"
            exit 0
            ;;
        *)
            echo "Choix invalide. Réessayez."
            ;;
    esac
done
