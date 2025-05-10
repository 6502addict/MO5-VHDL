# Manuel Technique de l'Implémentation MO5 sur FPGA

## Introduction

Ce document détaille l'implémentation en VHDL de l'ordinateur Thomson MO5 sur une plateforme FPGA Intel/Altera. Le MO5 était un ordinateur domestique français populaire des années 1980, et cette implémentation FPGA reproduit fidèlement ses fonctionnalités en utilisant du matériel moderne.

## Vue d'Ensemble du Système

L'implémentation FPGA du Thomson MO5 est conçue pour la carte de développement DE1 équipée d'un FPGA Intel/Altera. Le système reproduit l'architecture originale du MO5, comprenant :

- CPU compatible 6809
- 32Ko de RAM
- Système ROM avec support de cartouches
- Interface PIA pour clavier, joystick et périphériques
- Sortie vidéo supportant les modes couleur
- Interface clavier PS/2 avec support de plusieurs dispositions
- Génération sonore
- Interface carte SD pour le stockage

## Architecture Matérielle

### Module Principal (DE1_MO5)

Le module principal `DE1_MO5` s'interface avec le matériel de la carte DE1 et connecte tous les composants du système. Il gère :

- La génération et la distribution d'horloge
- La logique de réinitialisation
- Le mappage mémoire entre CPU, RAM, ROM et périphériques
- L'interfaçage des E/S (clavier, vidéo, audio, stockage)

### Implémentation CPU

Le système utilise un cœur CPU compatible 6809 (`MO5_CPU`), qui est un wrapper autour du cœur CPU09 de John Kent. Caractéristiques principales :

- Jeu d'instructions 6809 entièrement compatible
- Espace d'adressage de 64Ko
- Support des modes d'interruption IRQ et FIRQ
- Commutable entre 1MHz et 10MHz

### Système Mémoire

Le système mémoire se compose de :

1. **RAM (MO5_RAM)** : 
   - Mappe le modèle mémoire original de 32Ko sur la SRAM de la carte FPGA
   - Gère la commutation de banques pour la mémoire vidéo et la mémoire principale

2. **ROM (MO5_ROM)** :
   - Mappe la ROM système originale (moniteur) et la ROM cartouche dans la mémoire flash
   - Fournit un mécanisme de sélection de cartouche

3. **Initialisateur RAM** :
   - Initialise la RAM au démarrage du système
   - Assure un état approprié pendant la séquence de démarrage

### Adaptateurs d'Interface Périphérique (MO5_PIA)

Le système inclut une implémentation PIA compatible MC6821 qui gère :

- Le balayage de la matrice de clavier
- Le contrôle de la couleur de bordure
- La sortie du bit sonore
- Le support du crayon optique
- La synchronisation temporelle du système

### Sous-système Vidéo (MO5_VIDEO)

Le système vidéo implémente les capacités graphiques du MO5 avec une sortie VGA améliorée :

- Supporte une sortie VGA 1024x768 (configurable pour d'autres résolutions)
- Implémente la résolution originale de 320x200 avec bordure
- Mappages mémoire séparés pour les formes de caractères et les couleurs
- Palette de 16 couleurs correspondant aux couleurs originales du MO5
- Génération matérielle accélérée des pixels

### Interface Clavier (MO5_KBD)

Le sous-système clavier convertit l'entrée d'un clavier PS/2 moderne vers la matrice de clavier originale du MO5 :

- Décodeur de protocole PS/2
- Traduction des codes de balayage
- Support pour plusieurs dispositions de clavier :
  - QWERTY
  - AZERTY (Français)
  - Mappage direct 1-à-1
- Combinaisons de touches spéciales pour le contrôle du système

### Système Sonore (MO5_SOUND)

Le système sonore implémente l'audio 1-bit du MO5 original avec des améliorations :

- Convertit le son numérique 1-bit en analogique via le codec WM8731
- Interface I2C pour la configuration du codec
- Taux d'échantillonnage de 48kHz
- Sortie audio 16-bit

### Interface Carte SD (MO5_SDDRIVE)

Le système inclut une interface carte SD pour le stockage :

- Implémentation du protocole SPI pour la communication avec la carte SD
- Pilote basé sur ROM
- LEDs d'activité pour les opérations de lecture/écriture

## Documentation Détaillée des Signaux

### Système d'Horloge

Le module `MO5_CLOCK` génère quatre horloges critiques :

1. **Horloge CPU** : 1MHz ou 10MHz, sélectionnable via un interrupteur
2. **Horloge VGA** : 25MHz pour VGA standard, plus élevée pour les résolutions améliorées
3. **Horloge SYNLT** : 50Hz pour la synchronisation système
4. **Horloge Sonore** : 48kHz pour l'échantillonnage audio

### Carte Mémoire

La carte mémoire du MO5 est préservée :

- **$0000-$1FFF** : Mémoire vidéo (accédée en fonction du signal 'forme')
- **$2000-$9FFF** : RAM principale
- **$A000-$A7BF** : RAM système
- **$A7C0-$A7C3** : Registres PIA
- **$A7BF** : Interface carte SD
- **$B000-$EFFF** : ROM cartouche
- **$F000-$FFFF** : ROM système (moniteur)

### Signaux de Contrôle

- **reset_n** : Réinitialisation système (actif bas)
- **forme** : Sélection du mode d'accès mémoire (forme vidéo vs données couleur)
- **synlt_clock** : Signal de synchronisation système 50Hz
- **cpu_reset_n** : Signal de réinitialisation CPU

## Implémentation de la Disposition du Clavier

Le système de clavier supporte trois modes sélectionnés par des interrupteurs :

1. **Mode QWERTY (00)** : Mappage standard de clavier US
2. **Mode AZERTY (01)** : Mappage de clavier français
3. **Mode Direct (10/11)** : Mappage direct pour des configurations personnalisées

La conversion des codes de balayage PS/2 vers la matrice de clavier MO5 est gérée en trois étapes :

1. **Décodeur PS/2** : Décode le protocole PS/2 brut
2. **Assembleur de Code de Balayage** : Traite les codes d'appui/relâchement et les touches étendues
3. **Décodeur Clavier MO5** : Mappe les codes de balayage traités à la matrice de clavier MO5

Combinaisons de touches spéciales :
- Ctrl+Alt+Suppr : Réinitialisation système
- Touches de fonction : Mappées aux touches numériques

## Détails du Système Vidéo

Le système vidéo génère une sortie VGA à partir des données d'affichage originales du MO5 en utilisant plusieurs composants :

1. **Contrôleur VGA** : Génère des signaux de synchronisation pour la résolution sélectionnée
2. **Traducteur de Coordonnées** : Mappe les coordonnées VGA à la mémoire vidéo MO5
3. **Mémoire de Forme et de Couleur** : RAMs double port pour les données de pixel et de couleur
4. **Sélecteur de Pixel** : Extrait les pixels individuels de la mémoire
5. **Sélecteur de Couleur** : Détermine la couleur finale du pixel
6. **Palette** : Convertit les codes couleur MO5 en valeurs RGB

Modes d'affichage :
- **Mode Pixel 00** : Zone d'effacement (noir)
- **Mode Pixel 01** : Zone de bordure (couleur de bordure)
- **Mode Pixel 10/11** : Zone d'affichage active (couleur avant-plan/arrière-plan)

## Interface Carte SD

L'interface carte SD fournit une capacité de stockage de masse :

- Implémentation simple du protocole SPI
- Capacités de transfert de commande/données
- Indication de statut via LEDs

## Notes d'Implémentation

### Compatibilité Carte

Cette implémentation est spécifiquement conçue pour la carte de développement FPGA DE1 avec :
- FPGA Altera/Intel
- 8Mo de SDRAM
- 4Mo de mémoire Flash
- CODEC audio I2C
- Port clavier PS/2
- Slot carte SD
- Sortie VGA

### Utilisation des Ressources

L'implémentation nécessite :
- Éléments logiques : ~8 000
- Bits mémoire : ~300 000
- PLLs : 1-2 selon la configuration
- Broches E/S : ~70

## Construction et Configuration

### Exigences de Construction

- Intel Quartus Prime (ou Altera Quartus II)
- ModelSim pour la simulation (optionnel)
- Outils de synthèse compatibles VHDL

### Options de Configuration

Le système fournit plusieurs options de configuration :

1. **Résolution Vidéo** : Configurable dans les paramètres génériques VGA_CTRL
2. **Disposition du Clavier** : Sélectionnable via les interrupteurs SW[1:0]
3. **Vitesse CPU** : Sélectionnable via l'interrupteur SW[2]

## Guide d'Utilisation

1. **Allumez** la carte DE1 avec la configuration FPGA MO5
2. Le système initialisera la RAM et réinitialisera le CPU
3. **Sélection du Mode Clavier** :
   - Réglez SW[1:0] pour sélectionner la disposition du clavier (00=QWERTY, 01=AZERTY, 10/11=Direct)
4. **Sélection de la Vitesse CPU** :
   - Réglez SW[2] pour sélectionner la vitesse CPU (0=1MHz, 1=10MHz)
5. **Réinitialisation** :
   - Appuyez sur KEY[0] pour une réinitialisation matérielle
   - Utilisez Ctrl+Alt+Suppr pour une réinitialisation logicielle

## Limitations Techniques et Améliorations

### Limitations

- Pas d'implémentation d'interface cassette
- Mécanisme de sélection de cartouche limité
- Quelques différences de timing par rapport au matériel original

### Améliorations

- Sortie VGA à plus haute résolution
- Vitesse CPU commutable
- Support de plusieurs dispositions de clavier
- Stockage carte SD au lieu de cassette
- Sortie audio améliorée

## Fonctionnalités de Débogage

- Affichages 7 segments montrant l'adresse CPU
- Indicateurs LED pour l'état du système
- Boutons KEY pour le contrôle manuel

## Crédits

Cette implémentation s'appuie sur plusieurs composants open-source :
- Cœur CPU09 par John Kent
- Architecture de contrôleur VGA
- Logique de décodeur de clavier PS/2
- Contrôleur I2C pour codec audio

## Annexe : Description des Signaux

### Interfaces Externes

| Interface | Description |
|-----------|-------------|
| VGA       | Sortie vidéo (HS, VS, R, G, B) |
| PS/2      | Entrée clavier (CLK, DAT) |
| AUDIO     | Interface codec audio I2C |
| CARTE SD  | Interface de stockage basée sur SPI |

### Signaux Internes Clés

| Signal      | Largeur  | Description |
|-------------|----------|-------------|
| address     | 16 bits  | Bus d'adresse CPU |
| data_in     | 8 bits   | Entrée de données CPU |
| data_out    | 8 bits   | Sortie de données CPU |
| rw          | 1 bit    | Contrôle lecture/écriture |
| vma         | 1 bit    | Adresse mémoire valide |
| irq_n       | 1 bit    | Demande d'interruption |
| firq_n      | 1 bit    | Demande d'interruption rapide |
| reset_n     | 1 bit    | Réinitialisation système |
| forme       | 1 bit    | Sélection du mode mémoire vidéo |
