#!/bin/bash

# Variables globales
CONF_NFTABLES="/etc/nftables.conf"
REPERTOIRE_BACKUP="/etc/nftables_backups"

# Fonction pour afficher un message d'erreur
afficher_erreur() {
    printf "Erreur : %s\n" "$1" >&2
}

# Fonction pour afficher un menu principal
menu_principal() {
    printf "\nMenu principal - Gestion de nftables\n"
    printf "1) Ajouter une règle\n"
    printf "2) Supprimer une règle\n"
    printf "3) Lister les règles\n"
    printf "4) Sauvegarder la configuration\n"
    printf "5) Restaurer la configuration\n"
    printf "6) Gérer les backups\n"
    printf "7) Quitter\n"
    printf "Sélectionnez une option : "
}

# Fonction pour ajouter une règle
ajouter_regle() {
    local table chaine regle
    read -p "Nom de la table (ex: filter_ipv4): " table
    read -p "Nom de la chaîne (ex: input): " chaine
    read -p "Règle à ajouter (ex: ip saddr 192.168.1.0/24 accept): " regle

    if nft add rule "$table" "$chaine" $regle; then
        printf "Règle ajoutée avec succès.\n"
    else
        afficher_erreur "Échec de l'ajout de la règle."
    fi
}

# Fonction pour supprimer une règle
supprimer_regle() {
    local table chaine handle
    read -p "Nom de la table (ex: filter): " table
    read -p "Nom de la chaîne (ex: input): " chaine
    read -p "Handle de la règle à supprimer : " handle

    if nft delete rule "$table" "$chaine" handle "$handle"; then
        printf "Règle supprimée avec succès.\n"
    else
        afficher_erreur "Échec de la suppression de la règle."
    fi
}

# Fonction pour lister les règles
lister_regles() {
    if nft list ruleset; then
        printf "\nListe des règles affichée ci-dessus.\n"
    else
        afficher_erreur "Échec de la liste des règles."
    fi
}

# Fonction pour sauvegarder la configuration
sauvegarder_config() {
    if nft list ruleset > "$CONF_NFTABLES"; then
        printf "Configuration sauvegardée dans %s.\n" "$CONF_NFTABLES"
    else
        afficher_erreur "Échec de la sauvegarde de la configuration."
    fi
}

# Fonction pour restaurer la configuration
restaurer_config() {
    if nft -f "$CONF_NFTABLES"; then
        printf "Configuration restaurée à partir de %s.\n" "$CONF_NFTABLES"
    else
        afficher_erreur "Échec de la restauration de la configuration."
    fi
}

# Fonction pour gérer les backups
gerer_backups() {
    mkdir -p "$REPERTOIRE_BACKUP"

    local option
    printf "\nMenu - Gestion des Backups\n"
    printf "1) Sauvegarder dans un fichier backup\n"
    printf "2) Restaurer depuis un fichier backup\n"
    printf "3) Lister les fichiers backup\n"
    printf "4) Quitter\n"
    printf "Sélectionnez une option : "
    read -r option

    case $option in
        1) sauvegarder_backup ;;
        2) restaurer_backup ;;
        3) lister_backups ;;
        4) return ;;
        *) afficher_erreur "Option invalide, veuillez réessayer." ;;
    esac
}

# Fonction pour sauvegarder la configuration dans un fichier de backup
sauvegarder_backup() {
    local nom_fichier
    read -p "Nom du fichier de backup (sans extension): " nom_fichier
    local chemin_fichier="$REPERTOIRE_BACKUP/$nom_fichier.nft"
    
    if nft list ruleset > "$chemin_fichier"; then
        printf "Backup créé : %s\n" "$chemin_fichier"
    else
        afficher_erreur "Échec de la création du backup."
    fi
}

# Fonction pour restaurer une configuration à partir d'un fichier de backup
restaurer_backup() {
    local nom_fichier
    read -p "Nom du fichier de backup à restaurer (sans extension): " nom_fichier
    local chemin_fichier="$REPERTOIRE_BACKUP/$nom_fichier.nft"

    if [[ -f "$chemin_fichier" ]]; then
        if nft -f "$chemin_fichier"; then
            printf "Configuration restaurée depuis %s.\n" "$chemin_fichier"
        else
            afficher_erreur "Échec de la restauration du backup."
        fi
    else
        afficher_erreur "Fichier backup non trouvé : $chemin_fichier"
    fi
}

# Fonction pour lister les fichiers de backup disponibles
lister_backups() {
    printf "\nFichiers de backup disponibles dans %s:\n" "$REPERTOIRE_BACKUP"
    ls -1 "$REPERTOIRE_BACKUP" 2>/dev/null || afficher_erreur "Aucun backup disponible."
}

# Fonction principale
principal() {
    while true; do
        menu_principal
        read -r choix

        case $choix in
            1) ajouter_regle ;;
            2) supprimer_regle ;;
            3) lister_regles ;;
            4) sauvegarder_config ;;
            5) restaurer_config ;;
            6) gerer_backups ;;
            7) printf "Au revoir !\n"; exit 0 ;;
            *) afficher_erreur "Option invalide, veuillez réessayer." ;;
        esac
    done
}

# Exécution du script
principal
